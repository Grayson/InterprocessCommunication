//
//  Ping.swift
//  InterprocessCommunicator
//
//  Created by Grayson Hansard on 12/9/16.
//  Copyright © 2016 From Concentrate Software. All rights reserved.
//

class Ping: PingService {
	func ping(_ pong: () -> ()) {
		print("ping")
		pong()
	}
}
