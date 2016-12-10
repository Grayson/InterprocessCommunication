//
//  Message.swift
//  InterprocessCommunication
//
//  Created by Grayson Hansard on 12/10/16.
//  Copyright © 2016 From Concentrate Software. All rights reserved.
//

import Foundation

@objc(Message) class Message: NSObject, NSSecureCoding {
	static var supportsSecureCoding: Bool { return true }

	let sender: String
	let value: String

	func encode(with aCoder: NSCoder){
		aCoder.encode(sender as NSString, forKey: "sender")
		aCoder.encode(value as NSString, forKey:"value")
	}

	required init?(coder aDecoder: NSCoder) {
		guard
			let sender = aDecoder.decodeObject(of: NSString.self, forKey: "sender") as? String,
			let value = aDecoder.decodeObject(of: NSString.self, forKey: "value") as? String
		else { return nil }

		self.sender = sender
		self.value = value
	}

	init(sender: String, value: String) {
		self.sender = sender
		self.value = value
	}
}
