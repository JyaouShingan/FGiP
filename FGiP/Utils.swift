//
//  Utils.swift
//  FGiP
//
//  Created by Peter Chen on 2016-04-23.
//  Copyright © 2016 CoreDevo. All rights reserved.
//

import UIKit
import AFNetworking
import CoreLocation


struct UserDefaultKeys {
	static let CENTER_LATITUDE = "MapRegionCenterLatitude"
	static let CENTER_LONGITUDE = "MapRegionCenterLongitude"
	static let SPAN_LATITUDE = "MapRegionSpanLatitude"
	static let SPAN_LONGITUDE = "MapRegionSpanLongitude"

	static let LOGGEDIN_USER = "LoggedInUser"
}

extension UIView {
	func popOut(complete: (()->())? = nil) {
		self.hidden = false
		self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001)
		UIView.animateWithDuration(0.3/1.5, animations: {
			self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1)
			}) { (finished) in
				UIView.animateWithDuration(0.3/2, animations: {
					self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)
					}, completion: { (finished) in
						UIView.animateWithDuration(0.3/2, animations: {
							self.transform = CGAffineTransformIdentity
						})
						if let cb = complete {
							cb()
						}
				})
		}
	}
}

extension NSObject {
	var className: String {
		return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last ?? ""
	}
}

extension UIApplication {
	class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
		if let nav = base as? UINavigationController {
			return topViewController(nav.visibleViewController)
		}
		if let tab = base as? UITabBarController {
			if let selected = tab.selectedViewController {
				return topViewController(selected)
			}
		}
		if let presented = base?.presentedViewController {
			return topViewController(presented)
		}
		return base
	}
}

func !=(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
	return lhs.latitude != rhs.latitude || lhs.longitude != rhs.longitude
}