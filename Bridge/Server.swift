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
		connection.remoteObjectInterface = NSXPCInterface(with: CommunicationClient.self)
		connection.resume()
		if let client = connection.remoteObjectProxy as? CommunicationClient {
			clientConnections.append(connection)
			broadcast(message: "Registered \(clientConnections.count) connections")
		}
	}

	func broadcast(message: String) {
		clientConnections.forEach {
			($0.remoteObjectProxy as? CommunicationClient)?.receive(message: message)
		}
	}
}
