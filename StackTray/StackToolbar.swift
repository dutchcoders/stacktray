//
//  StackToolbar.swift
//  StackTray
//
//  Created by Ruben Cagnie on 6/6/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

class StackToolbar: NSView {
    var backgroundColor: NSColor = NSColor.whiteColor()
    
    override func drawRect(dirtyRect: NSRect) {
        NSGraphicsContext.saveGraphicsState()
        
        let borderPath = NSBezierPath(roundedRect: bounds, xRadius: 5, yRadius: 5)
        self.backgroundColor.set()
        borderPath.fill()
        
        println(bounds)
        
        NSGraphicsContext.restoreGraphicsState()
    }
}
