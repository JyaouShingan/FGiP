//
//  UpdateView.swift
//  FGiP
//
//  Created by Peter Chen on 2016-04-23.
//  Copyright © 2016 CoreDevo. All rights reserved.
//

import UIKit

protocol UpdateViewDelegate: class {
	func updateViewDidSelectMoveToCurrentLocation()
	func updateViewDidSelectMoveToCursor()
	func updateViewDidSelectDelete()
}

class UpdateView: UIView {

	@IBOutlet var nibView: UIView!
	@IBOutlet weak var idLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var currentButton: UIButton!
	@IBOutlet weak var cursorButton: UIButton!
	@IBOutlet weak var deleteButton: UIButton!

	weak var delegate: UpdateViewDelegate?

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
		self.setupView()
	}

	private func setupView() {
		self.cursorButton.titleLabel?.textAlignment = .Center
		self.currentButton.titleLabel?.textAlignment = .Center

		self.cursorButton.layer.borderWidth = 1
		self.cursorButton.layer.borderColor = UIColor.blackColor().CGColor
		self.cursorButton.layer.masksToBounds = false

		self.currentButton.layer.borderWidth = 1
		self.currentButton.layer.borderColor = UIColor.blackColor().CGColor
		self.currentButton.layer.masksToBounds = false

		self.deleteButton.layer.borderWidth = 1
		self.deleteButton.layer.borderColor = UIColor.redColor().CGColor
		self.deleteButton.layer.masksToBounds = false
		
	}

	func setupEditable(editable: Bool) {
		self.cursorButton.hidden = !editable
		self.currentButton.hidden = !editable
		self.deleteButton.hidden = !editable
	}

	@IBAction func currentButtonPressed(sender: AnyObject) {
		self.delegate?.updateViewDidSelectMoveToCurrentLocation()
	}

	@IBAction func cursorButtonPressed(sender: AnyObject) {
		self.delegate?.updateViewDidSelectMoveToCursor()
	}

	@IBAction func deleteButtonPressed(sender: AnyObject) {
		let alertView = UIAlertController(title: "Confirm Deletion", message: "Are you sure want to delete this trap?", preferredStyle: .Alert)
		alertView.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		alertView.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) in
			self.delegate?.updateViewDidSelectDelete()
		}))
		UIApplication.topViewController()?.presentViewController(alertView, animated: true, completion: nil)
	}
}