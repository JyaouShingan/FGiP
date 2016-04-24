//
//  Serializer.swift
//  FGiP
//
//  Created by Peter Chen on 2016-04-23.
//  Copyright © 2016 CoreDevo. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

class Serializer {
	static func serializeTrapPoint(trapPoint: TrapPoint, username: String) -> NSData? {
		var json = JSON(["id":trapPoint.id,
						 "latitude":trapPoint.location.latitude,
						 "longitude":trapPoint.location.longitude,
						 "test": "TEST",
						 "username":trapPoint.user])
		if let updateTime = trapPoint.updateTime {
			json["updateTime"] = JSON(updateTime)
		}
		if let modified = trapPoint.modified {
			json["modified"] = JSON(modified)
		}
		do {
			let data = try json.rawData()
			return data
		} catch {
			return nil
		}
	}

	static func getTrapPointsFromResponse(data: AnyObject) -> [TrapPoint] {
		let json = JSON(data)
		var result: [TrapPoint] = []
		if let points = json["data"].array {
			for point in points {
				let id = point["_id"]
				let latitude = point["latitude"]
				let longitude = point["longitude"]
				let username = point["username"]
				let updateTime = point["updateTime"].double
				let modified = point["modified"].bool
				result.append(TrapPoint(id: id.stringValue, location: CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue), user: username.stringValue, updateTime: updateTime, modified: modified))
			}
		}
		return result
	}

	static func getTrapPointDetailFromResponse(data: AnyObject) -> TrapPoint {
		let point = JSON(data)
		let id = point["_id"]
		let latitude = point["latitude"]
		let longitude = point["longitude"]
		let username = point["username"]
		let updateTime = point["updateTime"].double
		let modified = point["modified"].bool
		let result = TrapPoint(id: id.stringValue, location: CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue), user: username.stringValue, updateTime: updateTime, modified: modified)
		return result
	}
}