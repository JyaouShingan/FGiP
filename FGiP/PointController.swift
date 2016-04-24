//
//  PointController.swift
//  FGiP
//
//  Created by Peter Chen on 2016-04-23.
//  Copyright © 2016 CoreDevo. All rights reserved.
//

import Foundation
import MapKit

protocol PointControllerDelegate: class {
	func refreshAnnotations(annotationsID: [String])
}

class PointController {
	var trapPointsDict: [String: TrapPoint] = [:]

	private var refreshTimer: NSTimer?

	weak var delegate: PointControllerDelegate?

	func start() {
		if self.refreshTimer == nil {
			self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(8, target: self, selector: #selector(self.serverRefresh), userInfo: nil, repeats: true)
			self.refreshTimer?.fire()
		}
	}

	func terminate() {
		self.refreshTimer?.invalidate()
		self.refreshTimer = nil

	}

	func refresh() {
		self.refreshTimer?.fire()
	}

	@objc private func serverRefresh() {
		HttpManager.sharedInstance().requestTrapPoints { result in
			NSLog("TrapPointRefreshed")
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
				var trapPointsFlag: [String] = []
				for point in result {
					if self.trapPointsDict[point.id] == nil || self.trapPointsDict[point.id]!.location != point.location {
						trapPointsFlag.append(point.id)
						self.trapPointsDict[point.id] = point
					}
				}
				for point in self.trapPointsDict {
					if !result.contains({ $0.id == point.0 }) {
						trapPointsFlag.append(point.0)
						self.trapPointsDict.removeValueForKey(point.0)
					}
				}
				dispatch_async(dispatch_get_main_queue()) {
					self.delegate?.refreshAnnotations(trapPointsFlag)
				}
			}
		}
	}
}