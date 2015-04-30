//
//  ClickableTextfield.swift
//  StackTray
//
//  Created by Remco on 30/04/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Cocoa

class StackButton: NSButton {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
  }

  required init?(coder: NSCoder) {

    super.init(coder: coder)
    
      var customCell: StackButtonCell = StackButtonCell()
    
    if let cell: NSButtonCell = self.cell() as? NSButtonCell {
       customCell.bezelStyle =  cell.bezelStyle
      customCell.title =  cell.title
      customCell.font =  cell.font
      customCell.enabled =  cell.enabled
      self.setCell(customCell)
    }

  }
}

class StackButtonCell: NSButtonCell {
  func gray(c: CGFloat) -> NSColor {
    return NSColor(deviceWhite: c/255, alpha: 1)
  }
  
  func color(a: CGFloat, b: CGFloat, c: CGFloat) -> NSColor {
    return NSColor(deviceRed: a/255, green: b/255, blue: c/255, alpha: 1)
  }
  override func drawBezelWithFrame(frame: NSRect, inView controlView: NSView) {
    if let ctx: NSGraphicsContext = NSGraphicsContext.currentContext() {var borderColors = []
      var buttonColors = []
      
      if self.highlighted {
        if self.state == NSOffState {
          borderColors = [gray(104), gray(104)]
          buttonColors = [gray(104), gray(82)]
        } else {
          borderColors = [color(138, b:178, c:122), color(138, b:178, c:122)]
          buttonColors = [color(138, b:178, c:122), color(98, b:138, c:82)]
        }
      } else {
        if self.state == NSOffState {
          borderColors = [gray(82), gray(150)]
          buttonColors = [gray(82), gray(104)]
        } else {
          borderColors = [color(98, b:138, c:82), color(188, b:228, c:172)]
          buttonColors = [color(98, b:138, c:82), color(138, b:178, c:122)]
        }
      }
      
      ctx.saveGraphicsState()
      
      let outerRect = NSMakeRect(frame.origin.x + 6, frame.origin.y + 4, frame.size.width - 12, frame.size.height - 11)
      let outerPath = NSBezierPath(roundedRect: outerRect, xRadius: 4, yRadius: 4)
      
      let dropShadow = NSShadow()
      dropShadow.shadowBlurRadius = 1.5
      dropShadow.shadowColor = NSColor(deviceWhite: 0, alpha: 0.5)
      dropShadow.shadowOffset = NSSize(width: 0, height: -1)
      dropShadow.set()
      
      NSBezierPath(roundedRect: outerRect, xRadius: 4.5, yRadius: 4.5).fill()
      
      let borderGradient = NSGradient(colors: borderColors as [AnyObject])
      borderGradient.drawInBezierPath(outerPath, angle: -90)
      
      let innerRect = NSMakeRect(outerRect.origin.x + 0.5, outerRect.origin.y + 0.5, outerRect.size.width - 1, outerRect.size.height - 1)
      let innerPath = NSBezierPath(roundedRect: innerRect, xRadius: 3.8, yRadius: 3.8)
      let innerGradient = NSGradient(colors: buttonColors  as [AnyObject])
      innerGradient.drawInBezierPath(innerPath, angle: -90)
    }
  }
}