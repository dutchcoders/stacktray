//
//  AppMenu.swift
//  stacktray
//
//  Created by Ruben Cagnie on 3/4/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Cocoa

/** DataSource for the app menu */
protocol AppMenuDataSource {
    /** Returns the number of accounts the menu should show */
    func numberOfAccounts(menu: AppMenu) -> Int
    /** Get the account at an index */
    func accountAtIndex(menu: AppMenu, index: Int) -> Account
    /** Get the selector for showing preferences */
    func selectorForPreferences(menu: AppMenu) -> Selector
}

/** Class that represents the app menu */
class AppMenu: NSMenu {
    /** Data Source for the menu */
    var dataSource: AppMenuDataSource!
    
    /** Refresh the menu */
    func refreshMenu(){
        self.removeAllItems()
        
        for var i=0; i<dataSource.numberOfAccounts(self);i++ {
            let account = dataSource.accountAtIndex(self, index: i)
            addItem(AccountMenuItem(account: account, action: Selector("handleItem:")))
        }
        
        self.addItem(NSMenuItem.separatorItem())
        self.addItem(NSMenuItem(title: "Manage Accounts...", action: dataSource.selectorForPreferences(self), keyEquivalent: ""))
        self.addItem(NSMenuItem(title: "Quit", action: Selector("quit:"), keyEquivalent: ""))
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
            submenu?.addItem(InstanceMenuItem(instance: instance, account: account, action: action))
        }
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
    
    init(instance: Instance, account: Account, action: Selector){
        super.init(title: instance.name, action: nil, keyEquivalent: "")
        
        representedObject = instance
        
        let menu = NSMenu(title: instance.name)
        
        /** Details */
        menu.addItemWithTitle("InstanceId: \(instance.instanceId)", action: nil, keyEquivalent: "")
        menu.addItemWithTitle("Type: \(instance.type)", action: nil, keyEquivalent: "")
        menu.addItemWithTitle("State: \(instance.state)", action: nil, keyEquivalent: "")
        
        /** Separator */
        menu.addItem(NSMenuItem.separatorItem())

        /** Clipboard */
        let clipBoardSelector = Selector("saveToClipboard:")

        menu.addItemWithTitle("Clipboard", action: nil, keyEquivalent: "")
        
        menu.addItemWithTitle(instance.privateDnsName, action: clipBoardSelector, keyEquivalent: "")
        menu.addItemWithTitle(instance.privateIpAddress, action: clipBoardSelector, keyEquivalent: "")
        menu.addItemWithTitle(instance.publicDnsName, action: clipBoardSelector, keyEquivalent: "")
        menu.addItemWithTitle(instance.publicIpAddress, action: clipBoardSelector, keyEquivalent: "")
        
        /** Separator */
        menu.addItem(NSMenuItem.separatorItem())

        /** Actions */
        menu.addItemWithTitle("Actions", action: nil, keyEquivalent: "")

        //Connect to the account : RUBEN: Do not know what this is
//        menu.addItem(InstanceActionMenuItem(title: "Connect", instance: instance, account: account, action: Selector("connect:")))
        
        //Browse to the account
        menu.addItem(InstanceActionMenuItem(title: "Browse", instance: instance, account: account, action: Selector("browse:")))
        
        //State (to start, stop)
        if instance.state == .Stopped {
            menu.addItem(InstanceActionMenuItem(title: "Start", instance: instance, account: account, action: Selector("startInstance:")))
        } else if instance.state == .Running {
            menu.addItem(InstanceActionMenuItem(title: "Stop", instance: instance, account: account, action: Selector("stopInstance:")))
        } else {
            menu.addItem(InstanceActionMenuItem(title: instance.state.description, instance: instance, account: account, action: nil))
        }
        
        //Reboot
        menu.addItem(InstanceActionMenuItem(title: "Reboot", instance: instance, account: account, action: Selector("reboot:")))
        
        //Console output
        menu.addItem(InstanceActionMenuItem(title: "Console Output", instance: instance, account: account, action: Selector("console:")))
        
        //Set submenu
        submenu = menu
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
}

class InstanceActionMenuItem: NSMenuItem {
    var instance: Instance {
        return self.representedObject as Instance
    }
    var account: Account
    
    init(title: String, instance: Instance, account: Account, action: Selector){
        self.account = account
        
        super.init(title: title, action: action, keyEquivalent: "")
        
        representedObject = instance
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
}