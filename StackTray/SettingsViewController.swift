//
//  AboutViewController.swift
//  StackTray
//
//  Created by Remco on 30/04/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Foundation

class SettingsViewController: NSViewController {
  var settingsDetail : SettingsDetailViewController!
  
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

  var settingsController: SettingsController! {
    didSet{
      settingsDetail.settingsController = self.settingsController
    }
  }

  /** Prepare for segue */
  override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
    if let destination = segue.destinationController as? SettingsDetailViewController {
      settingsDetail = destination
      settingsDetail.settingsController = settingsController
    }
  }
}

class SettingsDetailViewController : NSViewController {
  override func viewDidAppear() {
    super.viewDidAppear()
  }
  
  
  /** View Will Appear */
  override func viewWillAppear() {
      super.viewWillAppear()
    
    terminalTypesSelector.selectItemWithTitle(settingsController.settings.terminal)
  }

  
  @IBOutlet weak var terminalTypesSelector: NSPopUpButton! {
    didSet{
      terminalTypesSelector.menu!.removeAllItems()
      
      terminalTypesSelector.menu!.addItemWithTitle("Default terminal", action: nil, keyEquivalent: "")
      terminalTypesSelector.menu!.addItemWithTitle("iTerm2", action: nil, keyEquivalent: "")
    }
  }
  
  @IBAction func terminalChanged(sender: NSPopUpButton) {
    settingsController.settings.terminal = sender.selectedItem!.title
    
    settingsController.save()
  }
  
  var settingsController: SettingsController! {
    didSet{
    }
  }
}