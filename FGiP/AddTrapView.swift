//
//  AddTrapView.swift
//  FGiP
//
//  Created by Peter Chen on 2016-04-23.
//  Copyright © 2016 CoreDevo. All rights reserved.
//

import UIKit
import CoreLocation

protocol AddTrapViewDelegate: class {
	func addViewDidCancelAdding()
	func addViewDidComfirmAdding(id: String, location: CLLocationCoordinate2D)
}

class AddTrapView: UIView {
	@IBOutlet var nibView: UIView!
	@IBOutlet weak var idField: UITextField!
	@IBOutlet weak var latitudeLabel: UILabel!
	@IBOutlet weak var longitudeLabel: UILabel!

	weak var delegate: AddTrapViewDelegate?
	private var location: CLLocationCoordinate2D?

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.initFromNib()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.initFromNib()
	}

	private func initFromNib() {
		let bundle = NSBundle(forClass: self.dynamicType)
		bundle.loadNibNamed(self.className, owner: self, options: nil)
		nibView.frame = self.bounds
		self.addSubview(nibView)
	}

	func setLocation(location: CLLocationCoordinate2D) {
		self.location = location
		self.latitudeLabel.text = String(location.latitude)
		self.longitudeLabel.text = String(location.longitude)
	}

	@IBAction func confirmButtonPressed(sender: AnyObject) {
		if self.idField.text == "" || self.idField.text == nil {
			let alertView = UIAlertController(title: "Invaild ID", message: "Please enter a valid ID", preferredStyle: .Alert)
			alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
		} else {
			self.delegate?.addViewDidComfirmAdding(self.idField.text!, location: self.location!)
		}
	}

	@IBAction func cancelButtonPressed(sender: AnyObject) {
		self.delegate?.addViewDidCancelAdding()
	}
}
