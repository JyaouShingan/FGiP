//
//  FisherViewController.swift
//  FGiP
//
//  Created by Peter Chen on 2016-04-23.
//  Copyright © 2016 CoreDevo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SMCalloutView

class FisherViewController: UIViewController, MKMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, AddTrapViewDelegate, PointControllerDelegate, UpdateViewDelegate, UITableViewDelegate, UITableViewDataSource {
	@IBOutlet weak var listPanel: UIVisualEffectView!
	@IBOutlet weak var settingPanel: UIVisualEffectView!
	@IBOutlet weak var returnButton: UIButton!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var crossHair: UIImageView!
	@IBOutlet weak var naviContainer: UIVisualEffectView!
	@IBOutlet weak var naviButton: UIButton!
	@IBOutlet weak var pickerView: UIPickerView!
	@IBOutlet weak var tableView: UITableView!

	var username: String!

	private var listPanelOpen = false
	private var settingPanelOpen = false

	private var locationManager = CLLocationManager()
	private var followMode = false {
		didSet {
			if self.followMode {
				self.crossHair.hidden = true
			} else {
				self.crossHair.hidden = false
			}
		}
	}
	private var mapChangedFromUserInteraction = false

	private var addView: AddTrapView!
	private var pointController = PointController()
	private var annotationDict: [String: MKPointAnnotation] = [:]

	private var myTraps: [String] = []
	private var calloutView: SMCalloutView?

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
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

		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.separatorStyle = .None

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

		self.listPanel.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -self.listPanel.bounds.width, 0)
		self.settingPanel.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, self.settingPanel.bounds.width, 0)

		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
		self.view.addGestureRecognizer(tapRecognizer)

	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		self.settingPanel.hidden = true
		self.listPanel.hidden = true
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.settingPanel.hidden = false
		self.listPanel.hidden = false

		self.mapView.setUserTrackingMode(.Follow, animated: true)
		self.followMode = true
		self.naviButton.setImage(UIImage(named: "Arrow_Filled"), forState: .Normal)

		self.pointController.start()
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		self.saveRegion()
		self.pointController.terminate()
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
		self.followMode = true
		self.mapView.setUserTrackingMode(.Follow, animated: true)
		self.naviButton.setImage(UIImage(named: "Arrow_Filled"), forState: .Normal)
	}

	@IBAction func listButtonPressed(sender: AnyObject) {
		if self.listPanelOpen {
			self.listPanelOpen = false
			self.closeListPanel()
		} else {
			if self.settingPanelOpen {
				self.settingPanelOpen = false
				self.closeSettingPanel()
			}
			self.listPanelOpen = true
			self.openListPanel()
		}
	}

	@IBAction func settingButtonPressed(sender: AnyObject) {
		if self.settingPanelOpen {
			self.settingPanelOpen = false
			self.closeSettingPanel()
		} else {
			if self.listPanelOpen {
				self.listPanelOpen = false
				self.closeListPanel()
			}
			self.settingPanelOpen = true
			self.openSettingPanel()
		}
	}

	@IBAction func addButtonPressed(sender: AnyObject) {
		let alertView = UIAlertController(title: "Add a lobster trap", message: "Where to add?", preferredStyle: .ActionSheet)
		alertView.addAction(UIAlertAction(title: "Current Location", style: .Default, handler: { (action: UIAlertAction) -> () in
			if let location = self.locationManager.location?.coordinate {
				self.openAddView(location)
			} else {
				NSLog("Cannot get location")
			}
		}))
		alertView.addAction(UIAlertAction(title: "Cursor on Map", style: .Default, handler: { (action: UIAlertAction) -> () in
			let location = self.mapView.region.center
			self.openAddView(location)
		}))
		alertView.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		self.presentViewController(alertView, animated: true, completion: nil)
	}

	@objc private func dismissKeyboard() {
		self.addView?.idField.resignFirstResponder()
	}

	@IBAction func returnButtonPressed(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	private func openListPanel() {
		UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
			self.listPanel.transform = CGAffineTransformIdentity
			}, completion: nil)
	}

	private func closeListPanel() {
		UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: {
			self.listPanel.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -self.listPanel.bounds.width, 0)
			}, completion: nil)
	}

	private func openSettingPanel() {
		UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
			self.settingPanel.transform = CGAffineTransformIdentity
			}, completion: nil)
	}

	private func closeSettingPanel() {
		UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseIn, animations: {
			self.settingPanel.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, self.settingPanel.bounds.width, 0)
			}, completion: nil)
	}

	private func openAddView(location: CLLocationCoordinate2D) {
		self.addView = AddTrapView()
		self.addView.delegate = self

		self.addView.translatesAutoresizingMaskIntoConstraints = false
		var mConstraints: [NSLayoutConstraint] = []
		mConstraints.append(NSLayoutConstraint(item: self.addView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
		mConstraints.append(NSLayoutConstraint(item: self.addView, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
		mConstraints.append(NSLayoutConstraint(item: self.addView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 250))
		mConstraints.append(NSLayoutConstraint(item: self.addView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 350))


		self.addView.hidden = true
		self.addView.layer.cornerRadius = 15
		self.addView.layer.masksToBounds = true

		self.addView.setLocation(location)

		self.view.addSubview(self.addView)
		self.view.addConstraints(mConstraints)

		self.addView.popOut()
	}

	// MARK: AddTrapView Delegate

	func addViewDidComfirmAdding(id: String, location: CLLocationCoordinate2D) {
		let trapPoint = TrapPoint(id: id, location: location, user: self.username, updateTime: NSDate().timeIntervalSince1970, modified: false)

		HttpManager.sharedInstance().addNewTrapToServer(trapPoint, username: self.username) { success in
			self.pointController.refresh()
		}
		UIView.animateWithDuration(0.3, animations: {
			self.addView.alpha = 0
		}) { (finished) in
			self.addView.removeFromSuperview()
			self.addView = nil
		}
	}

	func addViewDidCancelAdding() {
		UIView.animateWithDuration(0.3, animations: {
			self.addView.alpha = 0
		}) { (finished) in
			self.addView.removeFromSuperview()
			self.addView = nil
		}
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
				annotationView = FGAnnotationView(annotation: annotation, reuseIdentifier: identifier)
			}
			if self.pointController.trapPointsDict[annotation.title!!]?.user == self.username {
				annotationView?.image = UIImage(named: "MyTrap")
				if !self.myTraps.contains(annotation.title!!) {
					self.myTraps.append(annotation.title!!)
					self.myTraps.sortInPlace()
					self.tableView.reloadData()
				}
			} else {
				annotationView?.image = UIImage(named: "Trap")
			}
			annotationView?.canShowCallout = false
			

			return annotationView
		}
		return nil
	}

	func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
		if let id = view.annotation?.title {
			print(id)
			HttpManager.sharedInstance().requestDetailPoint(id!, callback: { (point) in
				print(point)
				self.calloutView = SMCalloutView.platformCalloutView()
				var frame: CGRect
				var updateView: UpdateView
				if point.user == self.username {
					frame = CGRectMake(0.0,0.0, 200, 200)
					updateView = UpdateView(frame: frame)
					updateView.delegate = self
					updateView.setupEditable(true)
				} else {
					frame = CGRectMake(0.0,0.0, 200, 100)
					updateView = UpdateView(frame: frame)
					updateView.delegate = self
					updateView.setupEditable(false)
				}
				let id = point.id
				updateView.idLabel.text = id
				if let updateTime = point.updateTime {
					let formatter = NSDateFormatter()
					formatter.dateFormat = "yyyy/MM/dd hh:mm"
					updateView.timeLabel.text = formatter.stringFromDate(NSDate(timeIntervalSince1970: updateTime))
				} else {
					updateView.timeLabel.text = "Not available"
				}
				self.calloutView?.contentView = updateView

				self.calloutView?.presentCalloutFromRect(view.bounds, inView: view, constrainedToView: self.view, animated: true)
			})
		}
	}

	func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
		self.calloutView?.dismissCalloutAnimated(true)
	}

	func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		NSLog("Pressed")
	}
	// MARK: PointController Delegate

	func refreshAnnotations(annotationsID: [String]) {
		for id in annotationsID {
			if self.pointController.trapPointsDict[id] == nil {
				self.mapView.removeAnnotation(self.annotationDict[id]!)
				self.annotationDict.removeValueForKey(id)
			} else if self.annotationDict[id] == nil {
				let annotation = MKPointAnnotation()
				annotation.title = id
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

	// MARK: UpdateView Delegate

	func updateViewDidSelectMoveToCurrentLocation() {
		if let cv = self.calloutView {
			if let id = ((cv.contentView as? UpdateView)?.idLabel.text!) {
				if let location = self.locationManager.location {
					let trapPoint = TrapPoint(id: id, location: location.coordinate, user: self.username, updateTime: NSDate().timeIntervalSince1970, modified: true)
					HttpManager.sharedInstance().requestUpdatePoint(trapPoint, username: self.username) { success in
						self.calloutView?.dismissCalloutAnimated(true)
						self.pointController.refresh()
					}
				} else {
					NSLog("Cannot get Location")
				}
			}
		}
	}

	func updateViewDidSelectMoveToCursor() {
		if let cv = self.calloutView {
			if let id = ((cv.contentView as? UpdateView)?.idLabel.text!) {
				let location = self.mapView.region.center
				let trapPoint = TrapPoint(id: id, location: location, user: self.username, updateTime: NSDate().timeIntervalSince1970, modified: true)
				HttpManager.sharedInstance().requestUpdatePoint(trapPoint, username: self.username) { success in
					self.calloutView?.dismissCalloutAnimated(true)
					self.pointController.refresh()
				}
			}
		}
	}

	func updateViewDidSelectDelete() {
		if let cv = self.calloutView {
			if let id = ((cv.contentView as? UpdateView)?.idLabel.text!) {
				HttpManager.sharedInstance().deletePoint(id, callback: { (success) in
					self.calloutView?.dismissCalloutAnimated(true)
					self.pointController.refresh()
					if success {
						self.myTraps.removeAtIndex(self.myTraps.indexOf(id)!)
						self.tableView.reloadData()
					}
				})
			}
		}
	}

	// MARK: TableView Delegate & DataSource

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.myTraps.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("MyTrap")! as UITableViewCell

		cell.backgroundColor = UIColor.clearColor()
		cell.imageView?.image = UIImage(named: "MyTrap")
		cell.textLabel?.text = self.myTraps[indexPath.row]
		cell.textLabel?.textColor = UIColor.whiteColor()

		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let id = self.myTraps[indexPath.row]
		let location = self.pointController.trapPointsDict[id]!.location
		let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
		self.followMode = false
		self.mapView.userTrackingMode = .None
		self.naviButton.setImage(UIImage(named: "Arrow_Empty"), forState: .Normal)
		self.mapView.setRegion(region, animated: true)
	}
}
