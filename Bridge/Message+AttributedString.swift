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
		let paragraphStyle: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
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

		return NSAttributedString(string: self.value + "\n", attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): paragraphStyle, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): textColor]))
	}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
