//
//  AboutViewController.swift
//  StackTray
//
//  Created by Remco on 30/04/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Foundation
import ServiceManagement

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
    
    @IBOutlet weak var launchAtStartup: NSButton! {
        didSet{
            launchAtStartup.state = applicationIsInStartUpItems() ? NSOnState : NSOffState
        }
    }
    
    @IBAction func toggleStartup(sender: AnyObject) {
        toggleLaunchAtStartup()
    }
    
    
    func applicationIsInStartUpItems() -> Bool {
        return (itemReferencesInLoginItems().existingReference != nil)
    }
    
    func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItemRef?, lastReference: LSSharedFileListItemRef?) {
        var itemUrl : UnsafeMutablePointer<Unmanaged<CFURL>?> = UnsafeMutablePointer<Unmanaged<CFURL>?>.alloc(1)
        if let appUrl : NSURL = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
            let loginItemsRef = LSSharedFileListCreate(
                nil,
                kLSSharedFileListSessionLoginItems.takeRetainedValue(),
                nil
                ).takeRetainedValue() as LSSharedFileListRef?
            if loginItemsRef != nil {
                let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray
                println("There are \(loginItems.count) login items")
                let lastItemRef: LSSharedFileListItemRef = loginItems.lastObject as! LSSharedFileListItemRef
                for var i = 0; i < loginItems.count; ++i {
                    let currentItemRef: LSSharedFileListItemRef = loginItems.objectAtIndex(i) as! LSSharedFileListItemRef
                    if LSSharedFileListItemResolve(currentItemRef, 0, itemUrl, nil) == noErr {
                        if let urlRef: NSURL =  itemUrl.memory?.takeRetainedValue() {
                            println("URL Ref: \(urlRef.lastPathComponent)")
                            if urlRef.isEqual(appUrl) {
                                return (currentItemRef, lastItemRef)
                            }
                        }
                    } else {
                        println("Unknown login application")
                    }
                }
                //The application was not found in the startup list
                return (nil, lastItemRef)
            }
        }
        return (nil, nil)
    }
    
    func toggleLaunchAtStartup() {
        let itemReferences = itemReferencesInLoginItems()
        let shouldBeToggled = (itemReferences.existingReference == nil)
        let loginItemsRef = LSSharedFileListCreate(
            nil,
            kLSSharedFileListSessionLoginItems.takeRetainedValue(),
            nil
            ).takeRetainedValue() as LSSharedFileListRef?
        if loginItemsRef != nil {
            if shouldBeToggled {
                if let appUrl : CFURLRef = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
                    LSSharedFileListInsertItemURL(
                        loginItemsRef,
                        itemReferences.lastReference,
                        nil,
                        nil,
                        appUrl,
                        nil,
                        nil
                    )
                    println("Application was added to login items")
                }
            } else {
                if let itemRef = itemReferences.existingReference {
                    LSSharedFileListItemRemove(loginItemsRef,itemRef);
                    println("Application was removed from login items")
                }
            }
        }
    }
}