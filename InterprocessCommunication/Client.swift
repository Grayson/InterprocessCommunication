//
//  Client.swift
//  InterprocessCommunication
//
//  Created by Grayson Hansard on 12/9/16.
//  Copyright © 2016 From Concentrate Software. All rights reserved.
//

import Foundation

class Client: CommunicationClient {
	typealias MessageReceivedCallback = (Message) -> ()
	var onMessageReceived: MessageReceivedCallback = { _ in }

	func receive(message: Message) {
		onMessageReceived(message)
	}
}

class ClientListenerDelegate: NSObject, NSXPCListenerDelegate {
	let client: Client

	init(client: Client) {
		self.client = client
	}

	func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
		let interface = NSXPCInterface(with: CommunicationClient.self)
		interface.setClasses([Message.self as AnyObject as! NSObject], for: #selector(CommunicationClient.receive(message:)), argumentIndex: 0, ofReply: false)
		newConnection.exportedInterface = interface
		newConnection.exportedObject = client
		newConnection.resume()
		return true
	}
}
