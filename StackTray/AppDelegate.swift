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
        let appSupportFile = (urls[urls.count - 1] as! NSURL).path!
        
        return appSupportFile.stringByAppendingPathComponent("io.dutchcoders.stacktray")
        }()
    
    //Data Directory
    lazy var dataDirectory : String = {
        return self.appDirectory.stringByAppendingPathComponent("data")
        }()
    
    //Account Controller
    lazy var accountController: AccountController = AccountController(rootURL: self.dataDirectory)
    
    //Accounts
    lazy var accounts : NSWindowController = {
        let window = NSStoryboard(name: "Accounts", bundle: nil)?.instantiateInitialController() as! NSWindowController
        
        if let content = window.contentViewController as? AccountsViewController {
            content.accountController = self.accountController
        }
        
        return window
        }()
    
    //Instances
    lazy var instances : NSWindowController = {
        let window = NSStoryboard(name: "Instances", bundle: nil)?.instantiateInitialController() as! NSWindowController
        
        if let content = window.contentViewController as? InstancesViewController {
            content.accountController = self.accountController
        }
        
        return window
    }()
  
    //About
    lazy var about : NSWindowController = {
        let window = NSStoryboard(name: "About", bundle: nil)?.instantiateInitialController() as! NSWindowController
        return window
    }()
  
    /** App Menu */
    lazy var appMenu: AppMenu = {
        let menu = AppMenu()
        
        menu.dataSource = self
        menu.delegate = self
        
        return menu
        }()
    
    
    /** Status item that represents the cloud icon in the status bar */
    var statusItem: NSStatusItem!
    
    /** Main application launching function */
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
            //Only import legacy data once
            let i = ImportController()
            if i.importLegacyData(accountController) {
                defaults.setBool(true, forKey: importKey)
            }
        }
        
        /** Add an account observer (to refresh the menu) */
        accountController.addAccountControllerObserver(self)
                
        //Refreh the menu
        appMenu.initMenu()
        
        appMenu.addItem(NSMenuItem.separatorItem())
        appMenu.addItem(NSMenuItem(title: "Accounts...", action: Selector("showAccounts:"), keyEquivalent: ""))
        appMenu.addItem(NSMenuItem(title: "Instances...", action: Selector("showInstances:"), keyEquivalent: ""))
        appMenu.addItem(NSMenuItem.separatorItem())
        appMenu.addItem(NSMenuItem(title: "About", action: Selector("showAbout:"), keyEquivalent: ""))
        appMenu.addItem(NSMenuItem(title: "Quit StackTray", action: Selector("quit:"), keyEquivalent: ""))

        //Open Preferences if there are no accounts configured
        if accountController.accounts.count == 0 {
            self.showAccounts(nil)
        }        
    }
    
    /** Refresh the accounts */
    func refresh(){
        accountController.refreshAccounts()
    }
    
    /** Update the menu that an account was added */
    func didAddAccountAtIndex(accountController: AccountController, index: Int) {
        appMenu.insertAccount(index, account: accountController.accounts[index])
    }
    
    /** Update the menu that an account was deleted */
    func didDeleteAccountAtIndex(accountController: AccountController, index: Int) {
        appMenu.deleteAccount(index)
    }
    
    /** Update the menu that an account was updated */
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
    
    /** Add a notification when an instance was started */
    func instanceDidStart(accountController: AccountController, index: Int, instanceIndex: Int) {
        let account = accountController.accounts[index]
        let instance = account.instances[instanceIndex];
        
        NotificationManager.sharedManager().showNotification("Instance \"\(instance.name)\" is started", informativeText: "for account \"\(account.name)\"")        
    }
    
    /** Add a notification when an instance was stopped */
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
    
    func titleForInstanceAtIndex(index: Int) -> String {
        return "Instance \(index + 1)"
    }
    
    @IBAction func showAbout(sender: AnyObject) {
        about.showWindow(self)
  
        //Focus on window
        NSApp.activateIgnoringOtherApps(true)
        about.window!.makeKeyAndOrderFront(nil)
      
    }
    
    /** Show the accounts */
    func showAccounts(sender: AnyObject?) {
        accounts.showWindow(self)
        
        //Focus on window
        NSApp.activateIgnoringOtherApps(true)
        accounts.window!.makeKeyAndOrderFront(nil)
    }
    
    /** Show the instance */
    func showInstances(sender: AnyObject?) {
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
        NotificationManager.sharedManager().saveToClipBoard(menuItem.title)
    }
    
    /** Connect to an instance */
    func connect(menuItem: InstanceActionMenuItem){
        connectToInstance(menuItem.instance)
    }
    
    /** Browse to an instance */
    func browse(menuItem: InstanceActionMenuItem){
        browseToInstance(menuItem.instance)
    }

    /** Stop an instance */
    func stopInstance(menuItem: InstanceActionMenuItem){
        let instance = menuItem.instance
        
        accountController.stopInstance(menuItem.account, instance: instance) { (error) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                if error != nil {
                    presentAWSError(error!)
                }
            })
        }
    }
    
    /** Start an instance */
    func startInstance(menuItem: InstanceActionMenuItem){
        let instance = menuItem.instance
        accountController.startInstance(menuItem.account, instance: instance) { (error) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                if error != nil {
                    presentAWSError(error!)
                }
            })
        }
    }
    
    /** Reboot an instance */
    func reboot(menuItem: InstanceActionMenuItem){
        accountController.rebootInstance(menuItem.account, instance: menuItem.instance) { (error) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                if error != nil {
                    presentAWSError(error!)
                }
            })
        }
    }
    
    /** Show the console of an instance */
    func console(menuItem: InstanceActionMenuItem){
        if let instanceView = instances.contentViewController as? InstancesViewController {
            instanceView.showInstanceConsole(find(accountController.accounts, menuItem.account)!, instanceIndex: find(menuItem.account.instances, menuItem.instance)!)
        }

        instances.showWindow(self)
        
        //Focus on window
        NSApp.activateIgnoringOtherApps(true)
        instances.window!.makeKeyAndOrderFront(nil)
    }
    
    //MARK - Menu Delegate
    func menuWillOpen(menu: NSMenu){
        //Refreh the list of accounts when the menu opens
        self.refresh()
    }
}

//MARK: Notification Manager

private let _NotificationManager = NotificationManager()

/** The NotificationManager is responsible to show notifications on OS level */
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
    
    /** Save to the clipboard and show notification */
    func saveToClipBoard(string: String){
        let pasteBoard = NSPasteboard.generalPasteboard()
        pasteBoard.clearContents()
        pasteBoard.writeObjects([string])
        
        showNotification("Copy to clipboard", informativeText: string)
    }
}

/** Present AWS Error */
func presentAWSError(error: NSError){
    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        if let message = error.userInfo?["Message"] as? String {
            NSApplication.sharedApplication().presentError(NSError(domain: error.domain, code: error.code, userInfo: [ NSLocalizedDescriptionKey : message ]))
        } else {
            NSApplication.sharedApplication().presentError(error)
        }
    })
}


/** Open an instance in the browser */
func browseToInstance(instance: Instance){
    var host = instance.publicDnsName
  
    if host.isEmpty {
        host = instance.privateDnsName
    }
    
    if let url = NSURL(string: "http://\(host)") {
        NSWorkspace.sharedWorkspace().openURL(url)
    }
}

/** Connect to an instance */
func connectToInstance(instance: Instance){
  var cmd: String = "ssh"
  
  if let pemLocation = instance.pemLocation {
    var url: NSURLComponents = NSURLComponents(string: pemLocation)!
    if let path = url.path {
      cmd = cmd.stringByAppendingFormat("-i %@", path)
    }
  }
  
  var host: String = instance.publicDnsName
  
  if host.isEmpty {
    host = instance.privateDnsName
  }

  if let userId = instance.userId {
    cmd = cmd.stringByAppendingFormat(" %@@%@", userId, host)
  } else {
    cmd = cmd.stringByAppendingFormat(" %@", host)
  }
  
  
    var scriptName: String = "scripts/connect"
    
    var path : String = NSBundle.mainBundle().pathForResource(scriptName, ofType: "scpt")!
    
    var error:NSError?
    var source = String(contentsOfFile: path, encoding:NSUTF8StringEncoding, error: &error)!
    if let theError = error {
      let alert = NSAlert()
      alert.addButtonWithTitle("Close")
      alert.messageText = "Error loading script."
      alert.informativeText = "\(theError.localizedDescription)"
      alert.alertStyle = NSAlertStyle.CriticalAlertStyle
      alert.runModal()
    }
    
  source = source.stringByReplacingOccurrencesOfString("$cmd", withString: cmd)

  var scriptToPerform: NSAppleScript? = NSAppleScript(source: source)

  if let script = scriptToPerform {
    var possibleError: NSDictionary?
    script.executeAndReturnError(&possibleError)
    
    if let error = possibleError {
      let alert = NSAlert()
      alert.addButtonWithTitle("Close")
      alert.messageText = "Error connecting to iTerm."
      alert.informativeText = "\(error)"
      alert.alertStyle = NSAlertStyle.CriticalAlertStyle
      alert.runModal()
    }
  }
}

