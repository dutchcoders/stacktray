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
      customCell.color(255, b: 255, c: 255)
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
  
  override func drawTitle(title: NSAttributedString, withFrame frame: NSRect, inView controlView: NSView) -> NSRect {
    /*
    NSDictionary *attributes = [title attributesAtIndex:0 effectiveRange:nil];
    
    NSColor *systemDisabled = [NSColor colorWithCatalogName:@"System"
    colorName:@"disabledControlTextColor"];
    NSColor *buttonTextColor = attributes[NSForegroundColorAttributeName];
    
    if (systemDisabled == buttonTextColor) {
      NSMutableDictionary *newAttrs = [attributes mutableCopy];
      newAttrs[NSForegroundColorAttributeName] = [NSColor orangeColor];
      title = [[NSAttributedString alloc] initWithString:title.string
        attributes:newAttrs];
    }
    
    return [super drawTitle:title
    withFrame:frame
    inView:controlView];
*/
  //  var attributes: NSDictionary = title.attributesAtIndex(0, effectiveRange: nil)
//    var buttonTextColor: NSColor = attributes[NSForegroundColorAttributeName] as! NSColor;

    /*
    */
    var paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = NSTextAlignment.CenterTextAlignment

    let newTitle = NSAttributedString(string:title.string, attributes:
      [NSForegroundColorAttributeName: NSColor.whiteColor(), NSParagraphStyleAttributeName: paragraphStyle])

    return super.drawTitle(newTitle, withFrame: frame, inView: controlView)
  }
  
  override func drawBezelWithFrame(frame: NSRect, inView controlView: NSView) {
    if let ctx: NSGraphicsContext = NSGraphicsContext.currentContext() {var borderColors = []
      var buttonColors = []

      let backgroundColor: NSColor = color(240, b:86, c:49)

      if self.highlighted {
        if self.state == NSOffState {
          borderColors = [color(240, b:86, c:49), color(240, b:86, c:49)]
          buttonColors = [color(240, b:86, c:49), color(240, b:86, c:49)]
        } else {
          borderColors = [color(240, b:86, c:49), color(240, b:86, c:49)]
          buttonColors = [color(240, b:86, c:49), color(240, b:86, c:49)]
        }
      } else {
        if self.state == NSOffState {
          borderColors = [color(200, b:76, c:39), color(240, b:86, c:49)]
          buttonColors = [color(200, b:76, c:49), color(240, b:86, c:49)]
        } else {
          borderColors = [color(200, b:76, c:39), color(240, b:86, c:49)]
          buttonColors = [color(200, b:76, c:49), color(240, b:86, c:49)]
        }
      }
      
      
      ctx.saveGraphicsState()
      
      let outerRect = NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)
      let outerPath = NSBezierPath(roundedRect: outerRect, xRadius: 4, yRadius: 4)
      /*
      let dropShadow = NSShadow()
      dropShadow.shadowBlurRadius = 1.5
      dropShadow.shadowColor = NSColor(deviceWhite: 0, alpha: 0.5)
      dropShadow.shadowOffset = NSSize(width: 0, height: -1)
      dropShadow.set()*/
      buttonColors[0].set()
      buttonColors[0].setFill()
      
      NSBezierPath(roundedRect: outerRect, xRadius: 4.5, yRadius: 4.5).fill()
      
      let borderGradient = NSGradient(colors: [backgroundColor] as [AnyObject])
      borderGradient.drawInBezierPath(outerPath, angle: -90)
      
      //let innerRect = NSMakeRect(outerRect.origin.x + 0.5, outerRect.origin.y + 0.5, outerRect.size.width - 1, outerRect.size.height - 1)
    //  let innerPath = NSBezierPath(roundedRect: innerRect, xRadius: 3.8, yRadius: 3.8)
  //    let innerGradient = NSGradient(colors: [backgroundColor]  as [AnyObject])
//      innerGradient.drawInBezierPath(innerPath, angle: -90)
    }
  }
}