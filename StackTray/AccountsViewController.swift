//
//  AccountsViewController.swift
//  StackTray
//
//  Created by Ruben Cagnie on 3/29/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Cocoa

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

class AccountsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, AccountControllerObserver {
    /** Account Controller */
    var accountController: AccountController! {
        didSet{
            accountsDetail.accountController = accountController
            
            accountsTableView.reloadData()
        }
    }
    @IBOutlet weak var accountDetailView: NSView!
    @IBOutlet weak var noAccountDetailView: NSView!
    
    @IBOutlet weak var accountsTableView: NSTableView!

    override func viewWillAppear() {
        super.viewWillAppear()
        accountController.addAccountControllerObserver(self)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        accountController.removeAccountControllerObserver(self)
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return accountController == nil ? 0 : accountController.accounts.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return accountController.accounts[row].name
    }
    
    var accountsDetail : AccountsDetailViewController!
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if let detail = segue.destinationController as? AccountsDetailViewController {
            accountsDetail = detail
            accountsDetail.accountController = accountController
        }
    }
    
    @IBAction func addAccount(sender: AnyObject) {
        editOrAddAccount(self, accountController, accountIndex: nil, .AWS)
    }
    
    /** Change the selection of the row */
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        selectAccount(row)
        
        return true
    }
    
    /** User selected a row in the table */
    func tableViewSelectionIsChanging(notification: NSNotification) {
        selectAccount(accountsTableView.selectedRow)
    }
    
    func selectAccount(row: Int){
        if row < 0 {
            accountDetailView.hidden = true
            noAccountDetailView.hidden = false
        } else {
            let account = accountController.accounts[row]
            accountsDetail.account = account

            accountDetailView.hidden = false
            noAccountDetailView.hidden = true
        }
    }
    
    //MARK: AccountControllerObserver
    //MARK - Accounts
    func didAddAccountAtIndex(accountController: AccountController, index: Int) {
        accountsTableView.reloadData()
    }
    
    func didDeleteAccountAtIndex(accountController: AccountController, index: Int) {
        accountsTableView.reloadData()
    }
    
    func didUpdateAccountAtIndex(accountController: AccountController, index: Int) {
        accountsTableView.reloadData()
    }
    
    
    
    //MARK - Instances
    func didAddAccountInstance(accountController: AccountController, index: Int, instanceIndex: Int) {
    }
    
    func didUpdateAccountInstance(accountController: AccountController, index: Int, instanceIndex: Int) {
    }
    
    func didDeleteAccountInstance(accountController: AccountController, index: Int, instanceIndex: Int) {
    }
    
    //MARK - Instances Starting/Stopping
    func instanceDidStart(accountController: AccountController, index: Int, instanceIndex: Int) {
    }
    
    func instanceDidStop(accountController: AccountController, index: Int, instanceIndex: Int) {
    }
}

class AccountsDetailViewController : NSViewController {
    @IBOutlet weak var accountNameField: MLComboField!
    @IBOutlet weak var accessKeyField: MLComboField!
    @IBOutlet weak var secretKeyField: MLComboField!
    
    var account: Account! {
        didSet {
            updateAccountFields()
        }
    }
    
    var accountController: AccountController!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        updateAccountFields()
    }
    
    func updateAccountFields(){
        accountNameField.stringValue = account.name
        if let aws = account as? AWSAccount {
            accessKeyField.stringValue = aws.accessKey
            secretKeyField.stringValue = aws.secretKey
            regionSelector.selectItemWithTitle(aws.region)
        }
    }
    
    @IBOutlet weak var regionSelector: NSPopUpButton! {
        didSet{
            for region in awsRegions {
                regionSelector.menu!.addItemWithTitle(region, action: nil, keyEquivalent: "")
            }
        }
    }
    
    @IBAction func deleteAccount(sender: AnyObject) {
        //Remove
        let alert = NSAlert()
        alert.addButtonWithTitle("Delete")
        alert.addButtonWithTitle("Cancel")
        alert.messageText = "Are you sure you want to delete \"\(account.name)\"?"
        alert.informativeText = "Deleting this account will remove it from the StackTray menu bar"
        
        alert.alertStyle = .WarningAlertStyle
        
        alert.beginSheetModalForWindow(view.window!, completionHandler: { (response) -> Void in
            if response == NSAlertFirstButtonReturn {
                self.accountController.deleteAccountAtIndex(find(self.accountController.accounts, self.account)!)
            }
        })
    }
    
    @IBAction func saveAccount(sender: AnyObject) {
        if let index = find(self.accountController.accounts, account){
            if let a = self.account as? AWSAccount {
                a.name = accountNameField.stringValue
                a.accessKey = accessKeyField.stringValue
                a.secretKey = secretKeyField.stringValue
                a.region = regionSelector.selectedItem!.title
                
                accountController.updateAccountAtIndex(index, account: a, callback: { (error, account) -> Void in
                    if error != nil {
                        NSApplication.sharedApplication().presentError(error!)
                    }
                })
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
