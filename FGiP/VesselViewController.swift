//
//  VesselViewController.swift
//  FGiP
//
//  Created by Peter Chen on 2016-04-23.
//  Copyright © 2016 CoreDevo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class VesselViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, PointControllerDelegate {

	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var settingPanel: UIVisualEffectView!
	@IBOutlet weak var pickerView: UIPickerView!
	@IBOutlet weak var returnButton: UIButton!
	@IBOutlet weak var naviContainer: UIVisualEffectView!
	@IBOutlet weak var naviButton: UIButton!

	private var locationManager = CLLocationManager()
	private var settingOpen = false
	private var followMode = false

	private var mapChangedFromUserInteraction = false

	private var pointController = PointController()
	private var annotationDict: [String: MKPointAnnotation] = [:]

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}

	override func prefersStatusBarHidden() -> Bool {
		return false
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setNeedsStatusBarAppearanceUpdate()

		self.locationManager.requestWhenInUseAuthorization()

		self.mapView.delegate = self
		self.mapView.showsUserLocation = true

		self.pickerView.delegate = self
		self.pickerView.dataSource = self

		self.pointController.delegate = self

		self.returnButton.layer.borderWidth = 1
		self.returnButton.layer.borderColor = UIColor.whiteColor().CGColor
		self.returnButton.layer.masksToBounds = false

		self.naviContainer.layer.cornerRadius = 10
		self.naviContainer.layer.masksToBounds = true

		let cache = NSUserDefaults.standardUserDefaults()
		if cache.objectForKey(UserDefaultKeys.CENTER_LATITUDE) == nil { return }
		let centerLatitude = cache.doubleForKey(UserDefaultKeys.CENTER_LATITUDE)
		let centerLongtitude = cache.doubleForKey(UserDefaultKeys.CENTER_LONGITUDE)
		let spanLatitdue = cache.doubleForKey(UserDefaultKeys.SPAN_LATITUDE)
		let spanLongitude = cache.doubleForKey(UserDefaultKeys.SPAN_LONGITUDE)

		self.mapView.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongtitude),
			span: MKCoordinateSpan(latitudeDelta: spanLatitdue, longitudeDelta: spanLongitude))

		self.settingPanel.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, self.settingPanel.bounds.width, 0)
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.mapView.setUserTrackingMode(.Follow, animated: true)
		self.followMode = true
		self.naviButton.setImage(UIImage(named: "Arrow_Filled"), forState: .Normal)
		self.pointController.start()
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		self.pointController.terminate()
		self.saveRegion()
	}

	@objc private func saveRegion() {
		NSLog("Saved Region")
		let cache = NSUserDefaults.standardUserDefaults()
		let region = self.mapView.region
		cache.setDouble(region.center.latitude, forKey: UserDefaultKeys.CENTER_LATITUDE)
		cache.setDouble(region.center.longitude, forKey: UserDefaultKeys.CENTER_LONGITUDE)
		cache.setDouble(region.span.latitudeDelta, forKey: UserDefaultKeys.SPAN_LATITUDE)
		cache.setDouble(region.span.longitudeDelta, forKey: UserDefaultKeys.SPAN_LONGITUDE)
	}

	@IBAction func naviButtonPressed(sender: AnyObject) {
		self.mapView.setUserTrackingMode(.Follow, animated: true)
		self.naviButton.setImage(UIImage(named: "Arrow_Filled"), forState: .Normal)
	}

	@IBAction func settingButtonPressed(sender: AnyObject) {
		if self.settingOpen {
			self.settingOpen = false
			self.closePanel()
		} else {
			self.settingOpen = true
			self.openPanel()
		}
	}

	@IBAction func returnButtonPressed(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	private func openPanel() {
		UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
			self.settingPanel.transform = CGAffineTransformIdentity
			}, completion: nil)
	}

	private func closePanel() {
		UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: {
			self.settingPanel.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, self.settingPanel.bounds.width, 0)
			}, completion: nil)
	}

	// MARK: PickerView Delegate

	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return 3
	}

	func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		var title = ""
		switch row {
		case 0:
			title = "Standard"
		case 1:
			title = "Satellite"
		case 2:
			title = "Hybrid"
		default:
			()
		}
		return NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "Georgia", size: 12.0)!])
	}

	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		switch row {
		case 0:
			self.mapView.mapType = .Standard
		case 1:
			self.mapView.mapType = .Satellite
		case 2:
			self.mapView.mapType = .Hybrid
		default:
			()
		}
	}

	func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
		return 25
	}

	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}

	// MARK: MKMapView Delegate

	private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
		let view = self.mapView.subviews[0]
		if let gestureRecognizers = view.gestureRecognizers {
			for recognizer in gestureRecognizers {
				if( recognizer.state == UIGestureRecognizerState.Began || recognizer.state == UIGestureRecognizerState.Ended ) {
					return true
				}
			}
		}
		return false
	}

	func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
		self.mapChangedFromUserInteraction = self.mapViewRegionDidChangeFromUserInteraction()
		if self.mapChangedFromUserInteraction {
			NSLog("User Moved Map")
			self.followMode = false
			self.mapView.userTrackingMode = .None
			self.naviButton.setImage(UIImage(named: "Arrow_Empty"), forState: .Normal)
		}
	}

	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation is MKUserLocation {
			return nil
		}
		if annotation is MKPointAnnotation {
			let identifier = "TrapPointAnnotation"
			var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
			if annotationView != nil {
				annotationView!.annotation = annotation
			} else {
				annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
			}
			annotationView?.image = UIImage(named: "Trap")
			annotationView?.canShowCallout = false

			return annotationView
		}
		return nil
	}

	// MARK: PointController Delegate

	func refreshAnnotations(annotationsID: [String]) {
		for id in annotationsID {
			if self.pointController.trapPointsDict[id] == nil {
				self.mapView.removeAnnotation(self.annotationDict[id]!)
				self.annotationDict.removeValueForKey(id)
			} else if self.annotationDict[id] == nil {
				let annotation = MKPointAnnotation()
				annotation.coordinate = self.pointController.trapPointsDict[id]!.location
				self.annotationDict[id] = annotation
				self.mapView.addAnnotation(annotation)
			} else {
				var annotation = self.annotationDict[id]!
				self.mapView.removeAnnotation(annotation)
				annotation = MKPointAnnotation()
				annotation.title = id
				annotation.coordinate = self.pointController.trapPointsDict[id]!.location
				self.annotationDict[id] = annotation
				self.mapView.addAnnotation(annotation)
			}
		}
	}
	
}