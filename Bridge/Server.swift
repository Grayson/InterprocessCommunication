//
//  Server.swift
//  InterprocessCommunication
//
//  Created by Grayson Hansard on 12/9/16.
//  Copyright © 2016 From Concentrate Software. All rights reserved.
//

import Foundation

class Server: CommunicationServer {
	private var clientConnections = [NSXPCConnection]()

	func register(client endpoint: NSXPCListenerEndpoint) {
		let connection = NSXPCConnection(listenerEndpoint: endpoint)
		let interface = NSXPCInterface(with: CommunicationClient.self)
		interface.setClasses([Message.self as AnyObject as! NSObject], for: #selector(CommunicationClient.receive(message:)), argumentIndex: 0, ofReply: false)
		connection.remoteObjectInterface = interface
		connection.resume()
		if connection.remoteObjectProxy is CommunicationClient {
			clientConnections.append(connection)
			let message = Message(sender: "_server", value: "Registered \(clientConnections.count) connections")
			broadcast(message: message)
		}
	}

	func broadcast(message: Message) {
		clientConnections.forEach {
			($0.remoteObjectProxy as? CommunicationClient)?.receive(message: message)
		}
	}
}
