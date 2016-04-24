//
//  LaunchViewController.swift
//  FGiP
//
//  Created by Peter Chen on 2016-04-23.
//  Copyright © 2016 CoreDevo. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController, LoginViewDelegate {
	@IBOutlet weak var iconView: UIView!
	@IBOutlet weak var vesselButton: UIButton!
	@IBOutlet weak var fisherButton: UIButton!

	private var loginView: LoginView!
	private var username: String?

	override func viewDidLoad() {
		super.viewDidLoad()

		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
		self.view.addGestureRecognizer(tapRecognizer)
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.iconView.hidden = true
		self.vesselButton.hidden = true
		self.fisherButton.hidden = true
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		self.iconView.popOut { 
			self.vesselButton.popOut({ 
				self.fisherButton.popOut()
			})
		}
	}

	@IBAction func vesselButtonPressed(sender: AnyObject) {
		self.performSegueWithIdentifier("ToVesselVC", sender: sender)
	}

	@IBAction func fisherButtonPressed(sender: AnyObject) {
		self.loginView = LoginView()
		self.loginView.delegate = self

		self.loginView.translatesAutoresizingMaskIntoConstraints = false
		var mConstraints: [NSLayoutConstraint] = []
		mConstraints.append(NSLayoutConstraint(item: self.loginView, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
		mConstraints.append(NSLayoutConstraint(item: self.loginView, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
		mConstraints.append(NSLayoutConstraint(item: self.loginView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 250))
		mConstraints.append(NSLayoutConstraint(item: self.loginView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 350))


		self.loginView.hidden = true
		self.loginView.layer.cornerRadius = 15
		self.loginView.layer.masksToBounds = true

		self.view.addSubview(loginView)
		self.view.addConstraints(mConstraints)

		self.fisherButton.enabled = false
		self.loginView.popOut()
	}

	@objc private func dismissKeyboard() {
		self.loginView?.usernameTextField.resignFirstResponder()
	}

	func loginViewDidCancelLogin() {
		UIView.animateWithDuration(0.3, animations: { 
			self.loginView.alpha = 0
			}) { (finished) in
				self.loginView.removeFromSuperview()
				self.loginView = nil
				self.fisherButton.enabled = true
		}
	}

	func loginViewDidFinishLoginWithUserID(id: String) {
		NSLog("Login: \(id)")
		self.username = id
		self.performSegueWithIdentifier("ToFisherVC", sender: self)
		UIView.animateWithDuration(0.3, animations: {
			self.loginView.alpha = 0
		}) { (finished) in
			self.loginView.removeFromSuperview()
			self.loginView = nil
			self.fisherButton.enabled = true
		}
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let identifier = segue.identifier {
			switch identifier {
			case "ToFisherVC":
				if let destVC = segue.destinationViewController as? FisherViewController {
					destVC.username = self.username
				}
			default:
				()
			}
		}
	}
}