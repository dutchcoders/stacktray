//
//  AboutViewController.swift
//  StackTray
//
//  Created by Remco on 30/04/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Foundation

class AboutViewController: NSViewController {
  override func viewDidAppear() {
    super.viewDidAppear()

    if let window = self.view.window {
      window.titleVisibility =  NSWindowTitleVisibility.Visible ;
      window.movableByWindowBackground = true;
      window.titlebarAppearsTransparent = true;
      window.styleMask |= NSFullSizeContentViewWindowMask;
      window.center()
    }
  }
  
  @IBAction func gotoWebsite(sender: AnyObject) {
    NSWorkspace.sharedWorkspace().openURL(NSURL(string:"http://dutchcoders.io/")!)
  }

  @IBAction func gotoGithub(sender: AnyObject) {
    NSWorkspace.sharedWorkspace().openURL(NSURL(string:"https://github.com/dutchcoders/stacktray/")!)
  }

  @IBAction func gotoIcons8(sender: AnyObject) {
    NSWorkspace.sharedWorkspace().openURL(NSURL(string:"https://icons8.com/license/")!)
  }

  
  @IBAction func gotoTwitter(sender: AnyObject) {
NSWorkspace.sharedWorkspace().openURL(NSURL(string:"https://twitter.com/dutchcoders")!)
  }
}
