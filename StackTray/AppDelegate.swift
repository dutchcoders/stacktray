//
//  AppDelegate.swift
//  stacktray
//
//  Created by Ruben Cagnie on 3/4/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Cocoa
import StackTrayKit
//import AWSiOSSDKv2

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, AppMenuDataSource, AccountControllerObserver {
    
    //Main app directory for storing data
    lazy var appDirectory : String = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let appSupportFile = (urls[urls.count - 1] as NSURL).path!
        
        return appSupportFile.stringByAppendingPathComponent("io.dutchcoders.stacktray")
        }()
    
    //Data Directory
    lazy var dataDirectory : String = {
        return self.appDirectory.stringByAppendingPathComponent("data")
        }()
    
    //Account Controller
    lazy var accountController: AccountController = AccountController(rootURL: self.dataDirectory)
    
    //Preferences
    lazy var preferences : NSWindowController = {
        let window = NSStoryboard(name: "Preferences", bundle: nil)?.instantiateInitialController() as NSWindowController
        
        if let content = window.contentViewController as? PreferencesViewController {
            content.accountController = self.accountController
        }
        
        return window
        }()
    
    /** App Menu */
    lazy var appMenu: AppMenu = {
        let menu = AppMenu()
        
        menu.dataSource = self
        
        return menu
        }()
    
    var statusItem: NSStatusItem!


    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        //Setup status bar item
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
        statusItem.title = String(format: "%C",0x2601)
        statusItem.highlightMode = true
        statusItem.menu = appMenu
        
        //Import Legacy Data
        let importKey = "STACKTRAY_LEGACY_IMPORT_FINISHED"
        let defaults = NSUserDefaults.standardUserDefaults()
        if !defaults.boolForKey(importKey) {
            println("NEED TO IMPORT LEGACY DATA")
            let i = ImportController()
            if i.importLegacyData(accountController) {
                defaults.setBool(true, forKey: importKey)
            }
        }
        
        accountController.addAccountControllerObserver(self)
                
        //Refreh the menu
        appMenu.refreshMenu()

        //Open Preferences if there are no accounts configured
        if accountController.accounts.count == 0 {
            self.preferences(nil)
        }
    }
    
    func didAddAccountAtIndex(accountController: AccountController, index: Int) {
        appMenu.refreshMenu()
    }
    
    func didDeleteAccountAtIndex(accountController: AccountController, index: Int) {
        appMenu.refreshMenu()
    }
    
    func didUpdateAccountAtIndex(accountController: AccountController, index: Int) {
        appMenu.refreshMenu()
    }
    
    //Menu DataSource
    func numberOfAccounts(menu: AppMenu) -> Int {
        return accountController.accounts.count
    }
    
    func accountAtIndex(menu: AppMenu, index: Int) -> Account {
        return accountController.accounts[index]
    }
    
    func selectorForPreferences(menu: AppMenu)->Selector{
        return Selector("preferences:")
    }
    
    //Dummy Poll instances
    func pollInstances(timer: NSTimer){
    }
    
//    func numberOfInstances() -> Int{
//        return instances
//    }
    
    func titleForInstanceAtIndex(index: Int) -> String {
        return "Instance \(index + 1)"
    }
    
    @IBAction func about(sender: AnyObject) {
        println("About")
    }
    
    /** Open the preferences */
    func preferences(sender: AnyObject?) {
        preferences.showWindow(self)
        
        //Focus on window
        NSApp.activateIgnoringOtherApps(true)
        preferences.window!.makeKeyAndOrderFront(nil)
    }
    
    /** Quit the application */
    func quit(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(nil)
    }
    
    /** Save a value to the clipboard */
    func saveToClipboard(menuItem: NSMenuItem){
        println("Save to clipboard: \(menuItem.title)")
        
        let pasteBoard = NSPasteboard.generalPasteboard()
        pasteBoard.clearContents()
        pasteBoard.writeObjects([menuItem.title])
    }
    
    /** Connect to an instance */
    func connect(menuItem: InstanceActionMenuItem){
        println("Connect to \(menuItem.instance.instanceId)")
    }
    
    /** Browse to an instance */
    func browse(menuItem: InstanceActionMenuItem){
        println("Browse to \(menuItem.instance.instanceId)")
    }
    
    /** Stop an instance */
    func stop(menuItem: InstanceActionMenuItem){
        println("Stop \(menuItem.instance.instanceId)")
    }
    
    /** Reboot an instance */
    func reboot(menuItem: InstanceActionMenuItem){
        println("Reboot \(menuItem.instance.instanceId)")
    }
    
    /** Show the console of an instance */
    func console(menuItem: InstanceActionMenuItem){
        println("Show Console for \(menuItem.instance.instanceId)")
    }
}

