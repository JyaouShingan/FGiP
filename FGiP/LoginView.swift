//
//  LoginView.swift
//  FGiP
//
//  Created by Peter Chen on 2016-04-23.
//  Copyright © 2016 CoreDevo. All rights reserved.
//

import UIKit

protocol LoginViewDelegate: class {
	func loginViewDidCancelLogin()
	func loginViewDidFinishLoginWithUserID(id: String)
}

class LoginView: UIView {
	@IBOutlet var nibView: UIView!
	@IBOutlet weak var promptLabel: UILabel!
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var changeButton: UIButton!

	private var historyUser: String?

	weak var delegate: LoginViewDelegate?

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
		self.changeButton.hidden = true
		self.nameLabel.hidden = true
		self.addSubview(nibView)

		let userDefault = NSUserDefaults.standardUserDefaults()
		if let loggedInUser = userDefault.stringForKey(UserDefaultKeys.LOGGEDIN_USER) {
			self.promptLabel.text = "Do you want to continue with user:"
			self.usernameTextField.hidden = true
			self.nameLabel.hidden = false
			self.nameLabel.text = loggedInUser
			self.historyUser = loggedInUser
			self.changeButton.hidden = false
		}
	}

	@IBAction func changeButtonPressed(sender: AnyObject) {
		self.promptLabel.text = "Please enter a username"
		self.usernameTextField.hidden = false
		self.nameLabel.hidden = true
		self.historyUser = nil
		self.changeButton.hidden = true
	}

	@IBAction func loginButtonPressed(sender: AnyObject) {
		if let hu = self.historyUser {
			self.delegate?.loginViewDidFinishLoginWithUserID(hu)
			return
		}
		if self.usernameTextField.text == "" || self.usernameTextField.text == nil {
			self.usernameTextField.placeholder = "Username cannot be empty"
		} else {
			let user = self.usernameTextField.text!
			let userDefault = NSUserDefaults.standardUserDefaults()
			userDefault.setValue(user, forKey: UserDefaultKeys.LOGGEDIN_USER)
			self.delegate?.loginViewDidFinishLoginWithUserID(user)

		}
	}

	@IBAction func cancelButtonPressed(sender: AnyObject) {
		self.delegate?.loginViewDidCancelLogin()
	}
}
