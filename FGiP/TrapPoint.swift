//
//  TrapPoint.swift
//  FGiP
//
//  Created by Peter Chen on 2016-04-23.
//  Copyright © 2016 CoreDevo. All rights reserved.
//

import Foundation
import CoreLocation

struct TrapPoint {
	var id: String
	var location: CLLocationCoordinate2D
	var user: String
	var updateTime: Double?
	var modified: Bool?
}