//
//  main.swift
//  InterprocessCommunication
//
//  Created by Grayson Hansard on 12/9/16.
//  Copyright © 2016 From Concentrate Software. All rights reserved.
//

import Foundation

class XPCDelegate: NSObject, NSXPCListenerDelegate {
	private let server = Server()

	func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
		newConnection.exportedInterface = NSXPCInterface(with: CommunicationServer.self)
		newConnection.exportedObject = server
		newConnection.resume()
		return true
	}
}

let delegate = XPCDelegate()
let listener = NSXPCListener.service()
listener.delegate = delegate
listener.resume()
