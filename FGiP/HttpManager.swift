//
//  HttpManager.swift
//  FGiP
//
//  Created by Peter Chen on 2016-04-23.
//  Copyright © 2016 CoreDevo. All rights reserved.
//

import Foundation
import AFNetworking

class HttpManager {

	let serverUrl = "http://ec2-54-152-143-50.compute-1.amazonaws.com:4000"

	static var _manager: HttpManager!

	static func sharedInstance() -> HttpManager {
		if self._manager == nil {
			self._manager = HttpManager()
		}
		return self._manager
	}

	private var afManager: AFHTTPSessionManager!

	init() {
		self.afManager = AFHTTPSessionManager(sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration())
		self.afManager.requestSerializer = AFJSONRequestSerializer()
	}

	func addNewTrapToServer(trap: TrapPoint, username: String, callback: ((Bool)->())? = nil) {
		let params = ["Content-Type":"application/json"]
		let	request = self.afManager.requestSerializer.requestWithMethod("PUT", URLString: self.serverUrl + "/update", parameters: params, error: nil)
		request.HTTPBody = Serializer.serializeTrapPoint(trap, username: username)
		let task = self.afManager.dataTaskWithRequest(request) { (response, responseObject, error) in
			if let error = error {
				NSLog("Request Failed: \(error.localizedDescription)")
				callback?(false)
			} else {
				NSLog("Request Succeed")
				callback?(true)
			}
		}
		task.resume()
	}

	func requestTrapPoints(callback: ([TrapPoint]) -> ()) {
		let request = self.afManager.requestSerializer.requestWithMethod("GET", URLString: self.serverUrl + "/queryLocation", parameters: nil, error: nil)
		let task = self.afManager.dataTaskWithRequest(request) { (response, responseObject, error) in
			if let error = error {
				NSLog("Request Failed: \(error.localizedDescription)")
			} else {
				NSLog("Request Succeed")
				if let data = responseObject {
					let result = Serializer.getTrapPointsFromResponse(data)
					callback(result)
				}
			}
		}
		task.resume()
	}

	func requestDetailPoint(id: String, callback: (TrapPoint) -> ()) {
		let request = AFHTTPRequestSerializer().requestWithMethod("GET", URLString: self.serverUrl + "/queryData", parameters: nil, error: nil)
		request.setValue(id, forHTTPHeaderField: "id")
		let task = self.afManager.dataTaskWithRequest(request) { (response, responseObject, error) in
			if let error = error {
				NSLog("Request Failed to get point detail: \(error.localizedDescription)")
			} else {
				NSLog("Request Succeed")
				if let data = responseObject {
					let result = Serializer.getTrapPointDetailFromResponse(data)
					callback(result)
				}
			}
		}
		task.resume()
	}

	func requestUpdatePoint(trap: TrapPoint, username: String, callback: ((Bool)->())? = nil) {
		let params = ["Content-Type":"application/json"]
		let request = self.afManager.requestSerializer.requestWithMethod("PUT", URLString: self.serverUrl + "/update", parameters: params, error: nil)
		request.HTTPBody = Serializer.serializeTrapPoint(trap, username: username)
		let task = self.afManager.dataTaskWithRequest(request) { (response, responseObject, error) in
			if let error = error {
				NSLog("Request Failed: \(error.localizedDescription)")
				callback?(false)
			} else {
				NSLog("Request Succeed")
				callback?(true)
			}
		}
		task.resume()
	}

	func deletePoint(id:String, callback: ((Bool) -> ())? = nil) {
		let request = self.afManager.requestSerializer.requestWithMethod("PUT", URLString: self.serverUrl + "/delete", parameters: nil, error: nil)
		request.setValue(id, forHTTPHeaderField: "id")
		let task = self.afManager.dataTaskWithRequest(request) { (response, responseObject, error) in
			if let error = error {
				NSLog("Request Failed to get point detail: \(error.localizedDescription)")
				callback?(false)
			} else {
				NSLog("Request Succeed")
				callback?(true)
			}
		}
		task.resume()

	}
}