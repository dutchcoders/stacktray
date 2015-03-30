//
//  AppMenu.swift
//  stacktray
//
//  Created by Ruben Cagnie on 3/4/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Cocoa

var dateFormatter : NSDateFormatter = {
    let formatter = NSDateFormatter()
    
    formatter.dateStyle = .ShortStyle
    formatter.timeStyle = .LongStyle
    
    return formatter
    }()

/** DataSource for the app menu */
protocol AppMenuDataSource {
    /** Returns the number of accounts the menu should show */
    func numberOfAccounts(menu: AppMenu) -> Int
    /** Get the account at an index */
    func accountAtIndex(menu: AppMenu, index: Int) -> Account
    /** Get the selector for showing preferences */
    func selectorForPreferences(menu: AppMenu) -> Selector
    /** Get the selector for showing instances */
    func selectorForInstances(menu: AppMenu) -> Selector
}

/** Class that represents the app menu */
class AppMenu: NSMenu {
    /** Data Source for the menu */
    var dataSource: AppMenuDataSource!

    /**
    Initialize the menu at first
    */
    func initMenu(){
        self.removeAllItems()
        
        for var i=0; i<dataSource.numberOfAccounts(self);i++ {
            let account = dataSource.accountAtIndex(self, index: i)
            insertAccount(i, account: account)
        }
        
        self.addItem(NSMenuItem.separatorItem())
        self.addItem(NSMenuItem(title: "Manage Accounts...", action: dataSource.selectorForPreferences(self), keyEquivalent: ""))
        self.addItem(NSMenuItem(title: "Manage Instances...", action: dataSource.selectorForInstances(self), keyEquivalent: ""))
        self.addItem(NSMenuItem(title: "Quit", action: Selector("quit:"), keyEquivalent: ""))
    }
    
    /** Insert an account */
    func insertAccount(accountIndex: Int, account: Account) {
        insertItem(AccountMenuItem(account: account, action: Selector("handleItem:")), atIndex: accountIndex)
    }
    
    /** Delete an account */
    func deleteAccount(accountIndex: Int){
        removeItemAtIndex(accountIndex)
    }
    
    /* Update an account */
    func updateAccount(accountIndex: Int, account: Account) {
        if let accountMenuItem = itemAtIndex(accountIndex) as? AccountMenuItem {
            accountMenuItem.updateAccount()
        }
    }
    
    /* Update an account instance */
    func updateAccountInstance(accountIndex : Int, instanceIndex: Int, instance: Instance){
        if let accountMenuItem = itemAtIndex(accountIndex) as? AccountMenuItem {
            if let instanceMenuItem = accountMenuItem.submenu?.itemAtIndex(instanceIndex) as? InstanceMenuItem {
                instanceMenuItem.instance = instance
            }
        }
    }
    
    /* Add an account instance */
    func addAccountInstance(accountIndex : Int, instanceIndex: Int, instance: Instance){
        if let accountMenuItem = itemAtIndex(accountIndex) as? AccountMenuItem {
            accountMenuItem.insertInstance(instance, index: instanceIndex)
        }
    }
    
    /* Delete an account instance */
    func deleteAccountInstance(accountIndex: Int, instanceIndex: Int){
        if let accountMenuItem = itemAtIndex(accountIndex) as? AccountMenuItem {
            accountMenuItem.menu?.removeItemAtIndex(instanceIndex)
        }
    }
}

/** Menu item for one account */
class AccountMenuItem: NSMenuItem {
    var account: Account {
        return self.representedObject as Account
    }

    init(account: Account, action: Selector){
        super.init(title: account.name, action: nil, keyEquivalent: "")
        
        representedObject = account
        submenu = NSMenu(title: account.name)
        
        for instance in account.instances {
           insertInstance(instance, index: find(account.instances, instance)!)
        }
    }
    
    func insertInstance(instance: Instance, index: Int){
        submenu?.insertItem(InstanceMenuItem(instance: instance, account: account, action: action), atIndex: index)
    }
    
    func updateAccount(){
        self.title = account.name
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    func saveToClipboard(menuItem: NSMenuItem){
        println("Save to clipboard: \(menuItem.title)")
    }

}

/** Menu item for one instance */
class InstanceMenuItem: NSMenuItem {
    var lastSyncedMenuItem = NSMenuItem()
    var instanceMenuItem = NSMenuItem()
    var typeMenuItem = NSMenuItem()
    var stateMenuItem = NSMenuItem()
    
    var privateDnsMenuItem : NSMenuItem
    var privateIpMenuItem : NSMenuItem
    var publicDnsMenuItem : NSMenuItem
    var publicIpMenuItem : NSMenuItem
    
    var startStopMenuItem : InstanceActionMenuItem
    
    var browseMenuItem : InstanceActionMenuItem
    var rebootMenuItem : InstanceActionMenuItem
    var consoleMenuItem : InstanceActionMenuItem
    
    var instance: Instance {
        get{
            return representedObject as Instance
        }
        set {
            representedObject = newValue
            updateInstance()
        }
    }
    
    init(instance: Instance, account: Account, action: Selector){
        
        let menu = NSMenu(title: instance.name)
        
        
        /** Details */
        menu.addItem(lastSyncedMenuItem)
        menu.addItem(instanceMenuItem)
        menu.addItem(typeMenuItem)
        menu.addItem(stateMenuItem)
        
        /** Separator */
        menu.addItem(NSMenuItem.separatorItem())

        /** Clipboard */
        let clipBoardSelector = Selector("saveToClipboard:")

        menu.addItemWithTitle("Copy to clipboard", action: nil, keyEquivalent: "")
        
        privateDnsMenuItem = menu.addItemWithTitle("", action: clipBoardSelector, keyEquivalent: "")!
        privateIpMenuItem = menu.addItemWithTitle("", action: clipBoardSelector, keyEquivalent: "")!
        publicDnsMenuItem = menu.addItemWithTitle("", action: clipBoardSelector, keyEquivalent: "")!
        publicIpMenuItem = menu.addItemWithTitle("", action: clipBoardSelector, keyEquivalent: "")!
        
        browseMenuItem = InstanceActionMenuItem(title: "Browse", account: account, action: Selector("browse:"))
        rebootMenuItem = InstanceActionMenuItem(title: "Reboot", account: account, action: Selector("reboot:"))
        consoleMenuItem = InstanceActionMenuItem(title: "Console Output", account: account, action: Selector("console:"))
        startStopMenuItem = InstanceActionMenuItem(title: "---", account: account, action: nil)
        
        /** Separator */
        menu.addItem(NSMenuItem.separatorItem())

        /** Actions */
        menu.addItemWithTitle("Actions", action: nil, keyEquivalent: "")
        
        //Browse to the account
        menu.addItem(browseMenuItem)
        
        //State (to start, stop)
        menu.addItem(startStopMenuItem)
        
        //Reboot
        menu.addItem(rebootMenuItem)
        
        //Console output
        menu.addItem(consoleMenuItem)
        
        super.init(title: instance.name, action: nil, keyEquivalent: "")
        
        //Set submenu
        submenu = menu
        
        representedObject = instance
        
        updateInstance()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    func updateInstance(){
        let instance = self.instance
        /** Details */
        if let last = instance.lastUpdate {
            let date = dateFormatter.stringFromDate(last)
            lastSyncedMenuItem.title = "Last Synced: \(date)"
        } else {
            lastSyncedMenuItem.title = "Last Synced: --"
        }
        
        instanceMenuItem.title = "InstanceId: \(instance.instanceId)"
        typeMenuItem.title = "Type: \(instance.type)"
        stateMenuItem.title = "State: \(instance.state)"

        publicDnsMenuItem.title = instance.publicDnsName
        publicIpMenuItem.title = instance.publicIpAddress
        publicDnsMenuItem.hidden = instance.publicDnsName.isEmpty
        publicIpMenuItem.hidden = instance.publicIpAddress.isEmpty
        
        privateDnsMenuItem.title = instance.privateDnsName
        privateIpMenuItem.title = instance.privateIpAddress

        if instance.state == .Stopped {
            startStopMenuItem.title = "Start"
            startStopMenuItem.action = Selector("startInstance:")
        } else if instance.state == .Running {
            startStopMenuItem.title = "Stop"
            startStopMenuItem.action = Selector("stopInstance:")
        } else {
            startStopMenuItem.title = instance.state.description
            startStopMenuItem.action = nil
        }

        
        browseMenuItem.instance = instance
        consoleMenuItem.instance = instance
        rebootMenuItem.instance = instance
        startStopMenuItem.instance = instance
        
//        /** Clipboard */
//        let clipBoardSelector = Selector("saveToClipboard:")
//        
//        menu.addItemWithTitle("Clipboard", action: nil, keyEquivalent: "")
//        
//        menu.addItemWithTitle(instance.privateDnsName, action: clipBoardSelector, keyEquivalent: "")
//        menu.addItemWithTitle(instance.privateIpAddress, action: clipBoardSelector, keyEquivalent: "")
//        menu.addItemWithTitle(instance.publicDnsName, action: clipBoardSelector, keyEquivalent: "")
//        menu.addItemWithTitle(instance.publicIpAddress, action: clipBoardSelector, keyEquivalent: "")
//        
//        /** Separator */
//        menu.addItem(NSMenuItem.separatorItem())
//        
//        /** Actions */
//        menu.addItemWithTitle("Actions", action: nil, keyEquivalent: "")
//        
//        //Connect to the account : RUBEN: Do not know what this is
//        //        menu.addItem(InstanceActionMenuItem(title: "Connect", instance: instance, account: account, action: Selector("connect:")))
//        
//        //Browse to the account
//        menu.addItem(InstanceActionMenuItem(title: "Browse", instance: instance, account: account, action: Selector("browse:")))
//        
//        //State (to start, stop)
//        if instance.state == .Stopped {
//            menu.addItem(InstanceActionMenuItem(title: "Start", instance: instance, account: account, action: Selector("startInstance:")))
//        } else if instance.state == .Running {
//            menu.addItem(InstanceActionMenuItem(title: "Stop", instance: instance, account: account, action: Selector("stopInstance:")))
//        } else {
//            menu.addItem(InstanceActionMenuItem(title: instance.state.description, instance: instance, account: account, action: nil))
//        }
//        
    }
}

class InstanceActionMenuItem: NSMenuItem {
    var instance: Instance {
        get {
            return self.representedObject as Instance
        }
        set {
            representedObject = newValue
        }
    }
    var account: Account!
    
    init(title: String, account: Account, action: Selector){
        self.account = account
        
        super.init(title: title, action: action, keyEquivalent: "")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
}