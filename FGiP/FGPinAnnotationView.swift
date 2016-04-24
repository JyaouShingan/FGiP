//
//  FGPinAnnotationView.swift
//  FGiP
//
//  Created by Peter Chen on 2016-04-24.
//  Copyright © 2016 CoreDevo. All rights reserved.
//

import MapKit

class FGAnnotationView: MKAnnotationView {
	
	override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
		let hitView = super.hitTest(point, withEvent: event)
		if hitView != nil {
			self.superview?.bringSubviewToFront(self)
		}
		return hitView
	}

	override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
		let rect = self.bounds
		var isInside = CGRectContainsPoint(rect, point)
		if !isInside {
			for view in	self.subviews {
				isInside = CGRectContainsPoint(view.frame, point)
				if isInside { break }
			}
		}
		return isInside
	}
}
