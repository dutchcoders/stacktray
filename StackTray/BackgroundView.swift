//
//  BackgroundView.swift
//  stacktray
//
//  Created by Ruben Cagnie on 3/9/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Cocoa

class BackgroundView: NSView {
    var color : NSColor = NSColor.clearColor()
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        color.setFill()
        NSRectFill(dirtyRect)
    }
    
}
