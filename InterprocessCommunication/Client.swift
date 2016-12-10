//
//  Client.swift
//  InterprocessCommunication
//
//  Created by Grayson Hansard on 12/9/16.
//  Copyright © 2016 From Concentrate Software. All rights reserved.
//

import Foundation

class Client: CommunicationClient {
	typealias MessageReceivedCallback = (String) -> ()
	var onMessageReceived: MessageReceivedCallback = { _ in }

	func receive(message: String) {
		onMessageReceived(message)
	}
}

class ClientListenerDelegate: NSObject, NSXPCListenerDelegate {
	let client: Client

	init(client: Client) {
		self.client = client
	}

	func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
		newConnection.exportedInterface = NSXPCInterface(with: CommunicationClient.self)
		newConnection.exportedObject = client
		newConnection.resume()
		return true
	}
}
