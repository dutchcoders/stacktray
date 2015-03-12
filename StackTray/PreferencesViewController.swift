//
//  PreferencesViewController.swift
//  stacktray
//
//  Created by Ruben Cagnie on 3/5/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Cocoa

/** Class that controls the Preferences */
class PreferencesViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, AccountControllerObserver {

    /** Account Controller */
    var accountController: AccountController! {
        didSet {
            accountController.addAccountControllerObserver(self)
            accountTableView.reloadData()
            
            addAccountsViewController.accountController = accountController
            accountDetailViewController.accountController = accountController
        }
    }
    
    func didAddAccountAtIndex(accountController: AccountController, index: Int) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.accountTableView.insertRowsAtIndexes(NSIndexSet(index: index), withAnimation: .SlideDown)
            self.accountTableView.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: true)
            self.accountTableView.scrollRowToVisible(index)
            self.accountDetailViewController.accountIndex = index
            self.updateViewVisibility()
        }
    }
    
    func didDeleteAccountAtIndex(accountController: AccountController, index: Int) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.accountTableView.removeRowsAtIndexes(NSIndexSet(index: index), withAnimation: .SlideDown)
            self.updateViewVisibility()
        }
    }
    
    func didUpdateAccountAtIndex(accountController: AccountController, index: Int) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.accountTableView.reloadDataForRowIndexes(NSIndexSet(index: index), columnIndexes: NSIndexSet(index: 0))
            self.accountDetailViewController.accountIndex = index
        }
    }

    /* Accounts TableView */
    @IBOutlet weak var accountTableView: NSTableView! {
        didSet {
            accountTableView.registerNib(NSNib(nibNamed: "AccountCell", bundle: nil)!, forIdentifier: "account")
        }
    }

    /** Number of rows */
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if accountController == nil {
            return 0
        }
        return accountController.accounts.count
    }
    
    /** View for accounts table view */
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let view = tableView.makeViewWithIdentifier("account", owner: self) as? AccountCellView {
            view.account = accountController.accounts[row]
            return view
        } else {
            return nil
        }
    }
    
    //MARK - Buttons
    let addAccountsVCSegue = "addAccountsVC" //The segue to the actual viewcontroller
    let accountDetailVCSegue = "accountDetailVC" //The segue to the detail viewcontroller
    
    private var addAccountsViewController: AddAccountsViewController! {
        didSet {
            addAccountsViewController.accountController = accountController
        }
    }
    
    private var accountDetailViewController: AccountDetailViewController! {
        didSet {
            accountDetailViewController.accountController = accountController
        }
    }
    
    
    @IBOutlet weak var addAccountButton: NSButton!
    @IBAction func addAccount(sender: AnyObject) {
        //Add
        accountTableView.deselectAll(sender)
        updateViewVisibility()
    }
    
    @IBOutlet weak var deleteAccountButton: NSButton!
    @IBAction func deleteAccount(sender: AnyObject) {
        //Remove
        let selectedRow = accountTableView.selectedRow
        if selectedRow >= 0 {
            let account = accountController.accounts[selectedRow]
            
            let alert = NSAlert()
            alert.addButtonWithTitle("Delete")
            alert.addButtonWithTitle("Cancel")
            alert.messageText = "Are you sure you want to delete \"\(account.name)\"?"
            alert.informativeText = "Deleting this account will remove it from the StackTray menu bar"
            
            alert.alertStyle = .WarningAlertStyle
            
            alert.beginSheetModalForWindow(view.window!, completionHandler: { (response) -> Void in
                if response == NSAlertFirstButtonReturn {
                    self.accountController.deleteAccountAtIndex(selectedRow)
                }
            })
        }
    }
    
    /** Change the selection of the row */
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        accountDetailViewController.editAccountsViewController = addAccountsViewController
        accountDetailViewController.accountIndex = row
        
        return true
    }
    
    /** User selected a row in the table */
    func tableViewSelectionIsChanging(notification: NSNotification) {
        updateViewVisibility()
    }
    
    /** Update the visibility. 
        If an account is selected, show the details
        If not, show the add account controller
    */
    func updateViewVisibility(){
        let rowSelected = accountTableView.selectedRow >= 0
        
        addAccountsViewController.view.hidden = rowSelected
        accountDetailViewController.view.hidden = !rowSelected
        addAccountButton.enabled = rowSelected
        deleteAccountButton.enabled = rowSelected
    }
    
    //MARK - Segue
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == addAccountsVCSegue {
            addAccountsViewController = segue.destinationController as AddAccountsViewController
        } else if segue.identifier == accountDetailVCSegue {
            accountDetailViewController = segue.destinationController as AccountDetailViewController
        }
    }
}

/**
Edit or add an account
*/
func editOrAddAccount(fromViewController: NSViewController, accountController: AccountController, accountIndex: Int? = nil, accountType: AccountType){
    let edit = NSStoryboard(name: "Preferences", bundle: nil)?.instantiateControllerWithIdentifier("addAccount") as AddAccountViewController
    edit.accountController = accountController
    edit.editAccountIndex = accountIndex
    fromViewController.presentViewControllerAsSheet(edit)
}

/** Controller to allow adding accounts */
class AddAccountsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    var accountController: AccountController! {
        didSet {
            accountsTableView?.reloadData()
        }
    }
    var accountToEditIndex: Int?
    
    /** Tableview that holds the different type of accounts */
    @IBOutlet weak var accountsTableView: NSTableView! {
        didSet{
            accountsTableView.registerNib(NSNib(nibNamed: "AddAccountCell", bundle: nil)!, forIdentifier: "AddAccountCell")
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if accountController == nil {
            return 0
        }
        return Array(accountController.connectors.keys).count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let view = tableView.makeViewWithIdentifier("AddAccountCell", owner: self) as? AddAccountCellView {
            let type = Array(accountController.connectors.keys)[row]
            view.accountType = type
            return view
        } else {
            return nil
        }
    }
    
    /** When a row is selected: show the add dialog */
    func tableViewSelectionIsChanging(notification: NSNotification) {
        if accountsTableView.selectedRow >= 0 {
            let type = Array(accountController.connectors.keys)[accountsTableView.selectedRow]
            editOrAddAccount(self, accountController, accountIndex: nil, type)
        }
        accountsTableView.deselectAll(self)
    }
}

/** Add Account Cell */
class AddAccountCellView: NSTableCellView {
    @IBOutlet weak var accountImageView: NSImageView!
    @IBOutlet weak var accountLabel: NSTextField!
    
    var accountType: AccountType = .Unknown {
        didSet{
            accountImageView.image = NSImage(named: accountType.imageName)
            accountLabel.stringValue = "Add \(accountType.description)"
        }
    }
}

/** Controller to view account details */
class AccountDetailViewController : NSViewController {
    var accountController: AccountController!
    var editAccountsViewController: AddAccountsViewController!
    
    var accountIndex: Int = 0 {
        didSet{
            if let a = accountController.accounts[accountIndex] as? AWSAccount {
                nameLabel.stringValue = a.name
                accessKeyLabel.stringValue = a.accessKey
                secretKeyLabel.stringValue = a.secretKey
                regionLabel.stringValue = a.region
            }
        }
    }
    
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var thumbnailView: NSImageView!
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var accessKeyLabel: NSTextField!
    @IBOutlet weak var secretKeyLabel: NSTextField!
    @IBOutlet weak var regionLabel: NSTextField!
    
    @IBAction func editAccount(sender: AnyObject) {
        editOrAddAccount(self, accountController, accountIndex: accountIndex, accountController.accounts[accountIndex].accountType)
    }
}

/** Cell that represents an account */
class AccountCellView: NSTableCellView {
    @IBOutlet weak var thumbnailView: NSImageView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var instancesLabel: NSTextField!
    
    var account: Account? {
        didSet {
            if let a = account {
                titleLabel.stringValue = a.name
                thumbnailView.image = NSImage(named: a.accountType.imageName)

                //Update the instances
                let instancesString = a.instances.count == 1 ? "instance" : "instances"
                instancesLabel.stringValue = "\(a.instances.count) \(instancesString)"
            }
        }
    }
    
    override var backgroundStyle: NSBackgroundStyle {
        didSet {
            println("Updated background Style: \(backgroundStyle.rawValue)")
            if let row = self.superview as? NSTableRowView {
                println("Is selected: \(row.selected)")
                titleLabel.textColor = row.selected ? NSColor.whiteColor() : NSColor.blackColor()
            }
        }
    }

}

//MARK - Add Account View
class AddAccountViewController : NSViewController {
    
    /** Account Controller */
    var accountController: AccountController!
    
    /** Use this variable to edit an account */
    var editAccountIndex : Int?
    
    /** List of regions */
    let awsRegions  = [
        "ec2.us-east-1.amazonaws.com",
        "ec2.us-west-2.amazonaws.com",
        "ec2.us-west-1.amazonaws.com",
        "ec2.eu-west-1.amazonaws.com",
        "ec2.ap-southeast-1.amazonaws.com",
        "ec2.ap-southeast-2.amazonaws.com",
        "ec2.ap-northeast-1.amazonaws.com",
        "ec2.sa-east-1.amazonaws.com"
    ]
    
    /** Name */
    @IBOutlet weak var nameTextField: NSTextField!
    
    /** Access Key */
    @IBOutlet weak var accessKeyTextField: NSTextField!
    
    /** Secret Key */
    @IBOutlet weak var secretKeyTextField: NSTextField!
    
    /** Region */
    @IBOutlet weak var regionPopupButton: NSPopUpButton!{
        didSet{
            for region in awsRegions {
                regionPopupButton.menu!.addItemWithTitle(region, action: nil, keyEquivalent: "")
            }
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        if let index = editAccountIndex {
            let a = accountController.accounts[index] as AWSAccount
            
            nameTextField.stringValue = a.name
            accessKeyTextField.stringValue = a.accessKey
            secretKeyTextField.stringValue = a.secretKey
            if let regionIndex = find(awsRegions, a.region) {
                regionPopupButton.selectItemAtIndex(regionIndex)
            }
            
            setupButton.title = "Update"
        } else {
            setupButton.title = "Setup"
        }
    }
    
    /** Progress */
    @IBOutlet weak var progressIndicator: NSProgressIndicator!

    /** Setup Button */
    @IBOutlet weak var setupButton: NSButton!
    
    /** Setup Account */
    @IBAction func setupAccount(sender: NSButton) {
        progressIndicator.startAnimation(nil)
        
        let name = nameTextField.stringValue
        let accessKey = accessKeyTextField.stringValue
        let secretKey = secretKeyTextField.stringValue
        let region = regionPopupButton.selectedItem!.title

        if let index = editAccountIndex {
            let a = accountController.accounts[index] as AWSAccount
            a.name = name
            a.accessKey = accessKey
            a.secretKey = secretKey
            a.region = region
            
            accountController.updateAccountAtIndex(index, account: a, callback: { (error, account) -> Void in
                self.progressIndicator.stopAnimation(nil)
                
                if error != nil {
                    NSApplication.sharedApplication().presentError(error!)
                } else {
                    self.closeSheet(sender)
                }
            })
            
        } else {
            let aws = AWSAccount(name: name, accessKey: accessKey, secretKey: secretKey, region: region)
            accountController.createAccount(aws, callback: { (error, account) -> Void in
                self.progressIndicator.stopAnimation(nil)
                
                if error != nil {
                    NSApplication.sharedApplication().presentError(error!)
                } else {
                    self.closeSheet(sender)
                }
            })
        }        
    }
    
    @IBAction func closeSheet(sender: AnyObject) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.dismissViewController(self)
        }
    }
    
}