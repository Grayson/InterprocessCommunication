//
//  Message+AttributedString.swift
//  InterprocessCommunication
//
//  Created by Grayson Hansard on 12/10/16.
//  Copyright © 2016 From Concentrate Software. All rights reserved.
//

import Cocoa

extension Message {
	func convertToAttributedString(ownClientName: String) -> NSAttributedString {
		let textColor: NSColor
		let paragraphStyle: NSMutableParagraphStyle = NSParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
		if self.sender.hasPrefix("_") { // server message
			textColor = NSColor.lightGray
			paragraphStyle.alignment = NSTextAlignment.center;
		}
		else if self.sender == ownClientName {
			textColor = NSColor.darkGray
		}
		else {
			textColor = NSColor.textColor
			paragraphStyle.alignment = NSTextAlignment.right;
		}

		return NSAttributedString(string: self.value + "\n", attributes: [NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: textColor])
	}
}
