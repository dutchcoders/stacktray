//
//  AccountsViewController.swift
//  StackTray
//
//  Created by Ruben Cagnie on 3/29/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Cocoa

/** List of AWS regions */
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

/**
    The main accounts view controller.
    Contains a table on the left and a detailed viewcontroller on the right.
    When no account is selected, an appropriate viewcontroller is shown
*/
class AccountsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, AccountControllerObserver {
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
  
    /** Account Controller */
    var accountController: AccountController! {
        didSet{
            //Update the account detail controller with the right account controller
            accountsDetail.accountController = accountController
            
            //Reload the table view
            accountsTableView.reloadData()
        }
    }
  
    /** View that represents an account */
    @IBOutlet weak var accountDetailView: NSView!
    
    /** View that represents the view when no account is selected */
    @IBOutlet weak var noAccountDetailView: NSView!
    
    /** Table view that show the accounts */
    @IBOutlet weak var accountsTableView: NSTableView!

    /** View Will Appear */
    override func viewWillAppear() {
        super.viewWillAppear()
        
        //When the view appears, register an account observer, so this controller received update events
        accountController.addAccountControllerObserver(self)
    }
    
    /** View Will Disappear */
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        // When the view disappears, remove the observer
        accountController.removeAccountControllerObserver(self)
    }
    
    /** Returns the number of accounts */
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return accountController == nil ? 0 : accountController.accounts.count
    }
    
    /** Return the name of the account */
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return accountController.accounts[row].name
    }
    
    /** Detail View Controller that is used to show the details of an account */
    var noAccounts : NoAccountsViewController!
    var accountsDetail : AccountsDetailViewController!
    
    /** Prepare for segue */
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationController as? AccountsDetailViewController {
            accountsDetail = destination
            accountsDetail.accountController = accountController
            accountsDetail.accountsViewController = self
        }
      
      if let destination = segue.destinationController as? NoAccountsViewController {
        noAccounts = destination
        noAccounts.accountController = accountController
        noAccounts.accountsViewController = self
      }
    }
  
    /** Called when the user clicks on the add account button */
    @IBAction func addAccount(sender: AnyObject) {
        let edit = NSStoryboard(name: "Accounts", bundle: nil)?.instantiateControllerWithIdentifier("addAccount") as! AddAccountViewController
        
        edit.accountController = accountController
        
        self.presentViewControllerAsSheet(edit)
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
    
    /** Select the correct account (if -1, no account was selected */
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
    func didAddAccountAtIndex(accountController: AccountController, index: Int) {
        //Update the table
        accountsTableView.endUpdates()
        accountsTableView.reloadData()
    }
    
    func didDeleteAccountAtIndex(accountController: AccountController, index: Int) {
        //Update the table
        accountsTableView.endUpdates()
        accountsTableView.reloadData()
        accountsTableView.deselectAll(nil)
        selectAccount(-1)
    }
    
    func didUpdateAccountAtIndex(accountController: AccountController, index: Int) {
        //Update the table
        accountsTableView.reloadDataForRowIndexes(NSIndexSet(index: index), columnIndexes: NSIndexSet(index: 0))
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

class NoAccountsViewController : NSViewController {
  var accountController: AccountController!
  var accountsViewController: AccountsViewController!

  /** Called when the user clicks on the add account button */
@IBAction func addAccount(sender: AnyObject) {
  let edit = NSStoryboard(name: "Accounts", bundle: nil)?.instantiateControllerWithIdentifier("addAccount") as! AddAccountViewController
  
  edit.accountController = accountController
  
  self.presentViewControllerAsSheet(edit)
}
}

/** View Controller that shows the details of an account */
class AccountsDetailViewController : NSViewController {
    
    var accountsViewController: AccountsViewController!
    
    /** Account Name */
    @IBOutlet weak var accountNameField: MLComboField!
    /** Access Key */
    @IBOutlet weak var accessKeyField: MLComboField!
    /** Secret Key */
    @IBOutlet weak var secretKeyField: NSSecureTextField!
    
    /** Region Selector */
    @IBOutlet weak var regionSelector: NSPopUpButton! {
        didSet{
            for region in awsRegions {
                regionSelector.menu!.addItemWithTitle(region, action: nil, keyEquivalent: "")
            }
        }
    }
    
    /** The account of which the details needs to be shown */
    var account: Account! {
        didSet {
            //Update the account fields
            updateAccountFields()
        }
    }
    
    /** Account Controller */
    var accountController: AccountController!
    
    /** View Will Appear */
    override func viewWillAppear() {
        super.viewWillAppear()
        
        //Update the accounts fields
        updateAccountFields()
    }
    
    /** Update the UI fields for this account */
    func updateAccountFields(){
        accountNameField.stringValue = account.name
        if let aws = account as? AWSAccount {
            accessKeyField.stringValue = aws.accessKey
            secretKeyField.stringValue = aws.secretKey
            regionSelector.selectItemWithTitle(aws.region)
        }
    }
    
    /** Invoked when the user clicks on delete account button */
    @IBAction func deleteAccount(sender: AnyObject) {
        //Show the remove alert
        let alert = NSAlert()
        alert.addButtonWithTitle("Delete")
        alert.addButtonWithTitle("Cancel")
        alert.messageText = "Are you sure you want to delete \"\(account.name)\"?"
        alert.informativeText = "Deleting this account will remove it from the StackTray menu bar."
        
        alert.alertStyle = .WarningAlertStyle
        
        alert.beginSheetModalForWindow(view.window!, completionHandler: { (response) -> Void in
            if response == NSAlertFirstButtonReturn {
                self.accountsViewController.accountsTableView.beginUpdates()
                //Do the deletion of the account
                self.accountController.deleteAccountAtIndex(find(self.accountController.accounts, self.account)!)
            }
        })
    }
    
    /** Invoked when the user clicks on save account button */
    @IBAction func saveAccount(sender: AnyObject) {
        if let index = find(self.accountController.accounts, account){
            if let a = self.account as? AWSAccount {
                a.name = accountNameField.stringValue
                a.accessKey = accessKeyField.stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                a.secretKey = secretKeyField.stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                a.region = regionSelector.selectedItem!.title
                
                accountController.updateAccountAtIndex(index, account: a, callback: { (error, account) -> Void in
                    if error != nil {
                        presentAWSError(error!)
                    }
                })
            }
        }
        
    }
    
}

/** View Controller that will allow the user to create or edit an account */
class AddAccountViewController : NSViewController {
    
    /** Account Controller */
    var accountController: AccountController!
    
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
    
    /** View Will Appear */
    override func viewWillAppear() {
        super.viewWillAppear()
        
        setupButton.title = "Setup"
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
        
        let aws = AWSAccount(name: name, accessKey: accessKey, secretKey: secretKey, region: region)
        accountController.createAccount(aws, callback: { (error, account) -> Void in
            self.progressIndicator.stopAnimation(nil)
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                if error != nil {
                    presentAWSError(error!)
                } else {
                    self.closeSheet(sender)
                }
            })
        })
    }
    
    /** Close the sheet */
    @IBAction func closeSheet(sender: AnyObject) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.dismissViewController(self)
        }
    }
    
}
