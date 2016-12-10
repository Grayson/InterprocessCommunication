//
//  AppDelegate.swift
//  ClientDemo
//
//  Created by Grayson Hansard on 12/10/16.
//  Copyright © 2016 From Concentrate Software. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	let xpcConnection = NSXPCConnection(machServiceName: "com.fromconcentratesoftware.Bridge", options: [])
	let listener = NSXPCListener.anonymous()
	let listenerDelegate: ClientListenerDelegate

	override init() {
		let client = Client()
		listenerDelegate = ClientListenerDelegate(client: client)
		listener.delegate = listenerDelegate
	}

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		listener.resume()

		xpcConnection.remoteObjectInterface = NSXPCInterface(with: CommunicationServer.self)
		xpcConnection.resume()
		(xpcConnection.remoteObjectProxy as? CommunicationServer)?.register(client: listener.endpoint)
	}
	
}
