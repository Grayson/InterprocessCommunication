//
//  CommunicationClient.swift
//  InterprocessCommunication
//
//  Created by Grayson Hansard on 12/9/16.
//  Copyright © 2016 From Concentrate Software. All rights reserved.
//

import Foundation

@objc protocol CommunicationClient {
	func receive(message: String)
}
