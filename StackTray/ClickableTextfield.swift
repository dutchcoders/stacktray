//
//  ClickableTextfield.swift
//  StackTray
//
//  Created by Remco on 30/04/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Foundation

class ClickableTextfield: NSTextField {
  override func mouseDown(theEvent: NSEvent) {
    self.sendAction(self.action, to: self.target)
  }
}