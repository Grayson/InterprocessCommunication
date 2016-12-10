//
//  ViewController.swift
//  InterprocessCommunication
//
//  Created by Grayson Hansard on 12/9/16.
//  Copyright © 2016 From Concentrate Software. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

	@IBOutlet var textView: NSTextView?
	@IBOutlet weak var textField: NSTextField?

	private var server: CommunicationServer { return (NSApp.delegate as! AppDelegate).xpcConnection.remoteObjectProxy as! CommunicationServer }
	private lazy var name: String = { return ProcessInfo().processName }()

	override func viewDidLoad() {
		super.viewDidLoad()
		(NSApp.delegate as! AppDelegate).listenerDelegate.client.onMessageReceived = { [textView] msg in
			DispatchQueue.main.async {
				textView?.textStorage?.append(NSAttributedString(string: msg + "\n"))
				textView?.scrollToEndOfDocument(nil)
			}
		}
	}

	@IBAction func send(_ sender: Any) {
		guard let msg = textField?.stringValue else { return }
		server.broadcast(message: Message(sender: name, value: msg))
	}
}

