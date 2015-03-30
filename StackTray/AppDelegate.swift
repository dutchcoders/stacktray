//
//  AppDelegate.swift
//  stacktray
//
//  Created by Ruben Cagnie on 3/4/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Cocoa
//import AWSiOSSDKv2

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, AppMenuDataSource, AccountControllerObserver, NSMenuDelegate, NSUserNotificationCenterDelegate {
    
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
        let window = NSStoryboard(name: "Accounts", bundle: nil)?.instantiateInitialController() as NSWindowController
        
        if let content = window.contentViewController as? AccountsViewController {
            content.accountController = self.accountController
        }
        
        
        return window
        }()
    
    //Preferences
    lazy var instances : NSWindowController = {
        let window = NSStoryboard(name: "Preferences", bundle: nil)?.instantiateInitialController() as NSWindowController
        
        if let content = window.contentViewController as? MainViewController {
            content.accountController = self.accountController
        }
        
        
        return window
        }()
    
    //Preferences
    lazy var console : NSWindowController = {
        let window = NSStoryboard(name: "Console", bundle: nil)?.instantiateInitialController() as NSWindowController
        return window
        }()
    
    /** App Menu */
    lazy var appMenu: AppMenu = {
        let menu = AppMenu()
        
        menu.dataSource = self
        menu.delegate = self
        
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
            let i = ImportController()
            if i.importLegacyData(accountController) {
                defaults.setBool(true, forKey: importKey)
            }
        }
        
        accountController.addAccountControllerObserver(self)
                
        //Refreh the menu
        appMenu.initMenu()

        //Open Preferences if there are no accounts configured
//        if accountController.accounts.count == 0 {
//            self.preferences(nil)
        self.instances(nil)
//        }        
    }
    
    func refresh(){
        accountController.refreshAccounts()
    }
    
    func didAddAccountAtIndex(accountController: AccountController, index: Int) {
        appMenu.insertAccount(index, account: accountController.accounts[index])
    }
    
    func didDeleteAccountAtIndex(accountController: AccountController, index: Int) {
        appMenu.deleteAccount(index)
    }
    
    func didUpdateAccountAtIndex(accountController: AccountController, index: Int) {
        appMenu.updateAccount(index, account: accountController.accounts[index])
    }
    
    //MARK - Instances
    func didAddAccountInstance(accountController: AccountController, index: Int, instanceIndex: Int) {
        let instance = accountController.accounts[index].instances[instanceIndex]
        appMenu.addAccountInstance(index, instanceIndex: instanceIndex, instance:instance)
    }
    
    func didUpdateAccountInstance(accountController: AccountController, index: Int, instanceIndex: Int) {
        let instance = accountController.accounts[index].instances[instanceIndex]
        appMenu.updateAccountInstance(index, instanceIndex: instanceIndex, instance: instance)
    }
    
    func didDeleteAccountInstance(accountController: AccountController, index: Int, instanceIndex: Int) {
        let instance = accountController.accounts[index].instances[instanceIndex]
        appMenu.deleteAccountInstance(index, instanceIndex: instanceIndex)
    }
    
    func instanceDidStart(accountController: AccountController, index: Int, instanceIndex: Int) {
        let account = accountController.accounts[index]
        let instance = account.instances[instanceIndex];
        
        NotificationManager.sharedManager().showNotification("Instance \"\(instance.name)\" is started", informativeText: "for account \"\(account.name)\"")        
    }
    
    func instanceDidStop(accountController: AccountController, index: Int, instanceIndex: Int) {
        let account = accountController.accounts[index]
        let instance = account.instances[instanceIndex];
        
        NotificationManager.sharedManager().showNotification("Instance \"\(instance.name)\" is stopped", informativeText: "for account \"\(account.name)\"")        
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
    
    func selectorForInstances(menu: AppMenu)->Selector{
        return Selector("instances:")
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
    
    func instances(sender: AnyObject?) {
        instances.showWindow(self)

        //Focus on window
        NSApp.activateIgnoringOtherApps(true)
        instances.window!.makeKeyAndOrderFront(nil)
}
    
    /** Quit the application */
    func quit(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(nil)
    }
    
    /** Save a value to the clipboard */
    func saveToClipboard(menuItem: NSMenuItem){
        println("Save to clipboard: \(menuItem.title)")
        
        
        NotificationManager.sharedManager().saveToClipBoard(menuItem.title)
    }
    
    /** Connect to an instance */
    func connect(menuItem: InstanceActionMenuItem){
        println("Connect to \(menuItem.instance.instanceId)")
    }
    
    /** Browse to an instance */
    func browse(menuItem: InstanceActionMenuItem){
        println("Browse to \(menuItem.instance.instanceId)")
        
        var dns = menuItem.instance.publicDnsName
        if dns.isEmpty {
            dns = menuItem.instance.privateDnsName
        }
        
        
        if let url = NSURL(string: "http://\(dns)") {
            NSWorkspace.sharedWorkspace().openURL(url)
        }
    }
    
    /** Stop an instance */
    func stopInstance(menuItem: InstanceActionMenuItem){
        let instance = menuItem.instance
        println("Stop \(instance.instanceId)")
        accountController.stopInstance(menuItem.account, instance: instance) { (error) -> Void in
            if error != nil {
                NSApplication.sharedApplication().presentError(error!)
            }
        }
    }
    
    /** Start an instance */
    func startInstance(menuItem: InstanceActionMenuItem){
        let instance = menuItem.instance
        println("Start \(instance.instanceId)")
        accountController.startInstance(menuItem.account, instance: instance) { (error) -> Void in
            if error != nil {
                NSApplication.sharedApplication().presentError(error!)
            }
        }
    }
    
    /** Reboot an instance */
    func reboot(menuItem: InstanceActionMenuItem){
        println("Reboot \(menuItem.instance.instanceId)")
        
        accountController.rebootInstance(menuItem.account, instance: menuItem.instance) { (error) -> Void in
            if error != nil {
                NSApplication.sharedApplication().presentError(error!)
            }
        }
    }
    
    /** Show the console of an instance */
    func console(menuItem: InstanceActionMenuItem){
        println("Show Console for \(menuItem.instance.instanceId)")
        
        if let consoleView = console.contentViewController as? ConsoleViewController {
            consoleView.accountController = accountController
            consoleView.account = menuItem.account
            consoleView.instance = menuItem.instance
            consoleView.reloadForAccount()
        }
        
        console.showWindow(self)
        
        //Focus on window
        NSApp.activateIgnoringOtherApps(true)
        console.window!.makeKeyAndOrderFront(nil)
        
        
    }
    
    
    //MARK - Menu Delegate
    func menuWillOpen(menu: NSMenu){
        //Refreh the list of accounts when the menu opens
        self.refresh()
    }
    
    

}

private let _NotificationManager = NotificationManager()
class NotificationManager : NSObject, NSUserNotificationCenterDelegate {
    
    class func sharedManager() -> NotificationManager {
        return _NotificationManager
    }
    
    func showNotification(title: String, informativeText: String){
        var notification = NSUserNotification()
        
        notification.title = title
        notification.informativeText = informativeText
        notification.deliveryDate = NSDate()
        
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        
        NSUserNotificationCenter.defaultUserNotificationCenter().scheduleNotification(notification)
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
    func saveToClipBoard(string: String){
        let pasteBoard = NSPasteboard.generalPasteboard()
        pasteBoard.clearContents()
        pasteBoard.writeObjects([string])
        
        showNotification("Copy to clipboard", informativeText: string)
    }
}



