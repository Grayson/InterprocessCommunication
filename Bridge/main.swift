//
//  main.swift
//  InterprocessCommunication
//
//  Created by Grayson Hansard on 12/9/16.
//  Copyright © 2016 From Concentrate Software. All rights reserved.
//

import Foundation

class XPCDelegate: NSObject, NSXPCListenerDelegate {
	func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
		newConnection.exportedInterface = NSXPCInterface(with: PingService.self)
		newConnection.exportedObject = Ping()
		newConnection.resume()
		return true
	}
}

let delegate = XPCDelegate()
let listener = NSXPCListener.service()
listener.delegate = delegate
listener.resume()
