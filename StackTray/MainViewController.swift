//
//  TestViewController.swift
//  StackTray
//
//  Created by Ruben Cagnie on 3/27/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, AccountControllerObserver {

    /** Account Controller */
    var accountController: AccountController! {
        didSet {
            detailInstanceViewController.accountController = accountController
            reloadInstances()
        }
    }
    
    func reloadInstances(){
        instances.removeAll(keepCapacity: false)
        
        for account in accountController.accounts {
            for instance in account.instances {
                instances.append(instance)
            }
        }
        
        
        accountsTableView.reloadData()
        selectInstance(-1)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        accountController.addAccountControllerObserver(self)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        accountController.removeAccountControllerObserver(self)
    }
    
    //MARK - Accounts
    func didAddAccountAtIndex(accountController: AccountController, index: Int){
        reloadInstances()
    }

    func didDeleteAccountAtIndex(accountController: AccountController, index: Int){
        reloadInstances()
    }
    
    func didUpdateAccountAtIndex(accountController: AccountController, index: Int){
    }
    

    
    //MARK - Instances
    func didAddAccountInstance(accountController: AccountController, index: Int, instanceIndex: Int) {
        reloadInstances()
    }
    
    func didUpdateAccountInstance(accountController: AccountController, index: Int, instanceIndex: Int) {
        let account = accountController.accounts[index]
        let instance = account.instances[instanceIndex];
        
        if detailInstanceViewController.instance != nil && detailInstanceViewController.instance == instance {
            detailInstanceViewController.instance = instance
        }
    }
    
    func didDeleteAccountInstance(accountController: AccountController, index: Int, instanceIndex: Int) {
        reloadInstances()
    }
    
    //MARK - Instances Starting/Stopping
    func instanceDidStart(accountController: AccountController, index: Int, instanceIndex: Int) {
        let account = accountController.accounts[index]
        let instance = account.instances[instanceIndex];

        if detailInstanceViewController.instance != nil && detailInstanceViewController.instance == instance {
            detailInstanceViewController.instance = instance
        }
    }
    
    func instanceDidStop(accountController: AccountController, index: Int, instanceIndex: Int) {
        let account = accountController.accounts[index]
        let instance = account.instances[instanceIndex];
        
        if detailInstanceViewController.instance != nil && detailInstanceViewController.instance == instance {
            detailInstanceViewController.instance = instance
        }
    }

    
    private var instances : [Instance] = []

    @IBOutlet weak var accountsTableView: NSTableView!
    @IBOutlet weak var deselectedContentView: NSView!
    @IBOutlet weak var detailContentView: NSView!
    
    @IBOutlet var groupView: MLRadioGroupManager!
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return instances.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return instances[row].name
    }
    
    /** Change the selection of the row */
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        selectInstance(row)
        
        return true
    }
    
    /** User selected a row in the table */
    func tableViewSelectionIsChanging(notification: NSNotification) {
        selectInstance(accountsTableView.selectedRow)
    }
    
    func selectInstance(row: Int){
        if row < 0 {
            detailContentView.hidden = true
            deselectedContentView.hidden = false
        } else {
            detailContentView.hidden = false
            deselectedContentView.hidden = true
            
            let instance = instances[row]
            
            if instance != detailInstanceViewController.instance {
                detailInstanceViewController.instance = instance
            }
        }
    }
    
    @IBAction func addAccount(sender: AnyObject) {
        editOrAddAccount(self, accountController, accountIndex: nil, .AWS)
    }
    
    var detailAccountViewController : DetailAccountViewController!
    var detailInstanceViewController : DetailInstanceViewController!
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if let detail = segue.destinationController as? DetailAccountViewController {
            detailAccountViewController = detail
        } else if let detail = segue.destinationController as? DetailInstanceViewController {
            detailInstanceViewController = detail
        }
    }
}

class DetailAccountViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    var account: AWSAccount! {
        didSet{
            accountNameField.stringValue = account.name
            accessKeyField.stringValue = account.accessKey
            secretKeyField.stringValue = account.secretKey
            regionSelector.stringValue = account.region
            
            instancesTableView.reloadData()
        }
    }
    @IBOutlet weak var accountNameField: MLComboField!
    @IBOutlet weak var accessKeyField: MLComboField!
    @IBOutlet weak var secretKeyField: MLComboField!
    
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
    
    @IBOutlet weak var regionSelector: NSPopUpButton! {
        didSet{
            for region in awsRegions {
                regionSelector.menu!.addItemWithTitle(region, action: nil, keyEquivalent: "")
            }
        }
    }
    
    @IBOutlet weak var instancesTableView: NSTableView! {
        didSet {
            instancesTableView.registerNib(NSNib(nibNamed: "InstanceCell", bundle: nil)!, forIdentifier: "InstanceCell")
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if account == nil {
            return 0
        }
        return account.instances.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return account.instances[row].name
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let instance = account.instances[row]
        
//        if let instanceCell = tableView.makeViewWithIdentifier("InstanceCell", owner: self) as? InstanceCellView {
//            instanceCell.instance = instance
//            return instanceCell
//        } else {
            return nil
//        }
    }
    
    func selectionShouldChangeInTableView(tableView: NSTableView) -> Bool {
        return false
    }
}

class DetailInstanceViewController : NSViewController {
    @IBOutlet weak var detailsButton: NSButton!
    @IBOutlet weak var accountButton: NSButton!
    @IBOutlet weak var consoleButton: NSButton!
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    
    var instance: Instance! {
        didSet {
            tabViewController.instance = instance
            titleLabel.stringValue = instance.name
            updateStateLabel()
        }
    }
    
    var accountController: AccountController! {
        didSet{
            tabViewController.accountController = accountController
        }
    }

    var tabViewController : InstanceTabbarController! {
        didSet {
            tabViewController.accountController = accountController
        }
    }
    
    func updateStateLabel(){
        statusLabel.stringValue = instance.state.description
        switch instance.state {
        case .Running : statusLabel.textColor = NSColor.greenColor()
        case .Stopped : statusLabel.textColor = NSColor.redColor()
        default : statusLabel.textColor = NSColor.blackColor()
            
        }
        
    }
    
    @IBAction func buttonClicked(sender: NSButton) {
        if sender == detailsButton {
            tabViewController.selectedTabViewItemIndex = 0
        } else if sender == accountButton {
            tabViewController.selectedTabViewItemIndex = 1
        } else if sender == consoleButton {
            tabViewController.selectedTabViewItemIndex = 2
        }
        updateCurrentIndex()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        updateCurrentIndex()
    }
    
    func updateCurrentIndex(){
        detailsButton.state = tabViewController.selectedTabViewItemIndex == 0 ? NSOnState : NSOffState
        accountButton.state = tabViewController.selectedTabViewItemIndex == 1 ? NSOnState : NSOffState
        consoleButton.state = tabViewController.selectedTabViewItemIndex == 2 ? NSOnState : NSOffState
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationController as? InstanceTabbarController {
            tabViewController = vc
        }
    }
}

class InstanceTabbarController : NSTabViewController {
    var instance: Instance! {
        didSet{
            for vc in self.tabViewItems as [NSTabViewItem] {
                if let instanceVc = vc.viewController as? InstanceTabViewController {
                    instanceVc.instance = instance
                }
            }
        }
    }
    
    var accountController: AccountController!{
        didSet{
            for vc in self.tabViewItems as [NSTabViewItem] {
                if let instanceVc = vc.viewController as? InstanceTabViewController {
                    instanceVc.accountController = accountController
                }
            }
        }
    }
    
}

class InstanceTabViewController: NSViewController {
    var account: Account!
    var instance: Instance! {
        didSet {
            if accountController != nil {
                account = accountController.accountForInstance(instance)
            }
        }
    }
    var accountController: AccountController!
    
    var active : Bool {
        return self.view.window != nil
    }
}

class InstanceDetailTabViewController : InstanceTabViewController {
}

class InstanceConsoleViewController : InstanceTabViewController {
    
    @IBOutlet var textView: NSTextView!
    
    override var instance: Instance! {
        didSet {
            if active {
                reloadConsoleForAccount()
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.reloadConsoleForAccount()
    }
    
    func reloadConsoleForAccount(){
        self.textView.string = ""
        self.accountController.fetchConsoleOutput(account, instance: instance) { (error, output) -> Void in
            if error != nil {
                NSApplication.sharedApplication().presentError(error!)
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.textView.string = output
                })
            }
        }
    }
    
    @IBAction func refreshConsole(sender: AnyObject) {
        self.reloadConsoleForAccount()
    }

}

class InstanceAccountViewController : InstanceTabViewController {
    @IBOutlet weak var accountNameField: MLComboField!
    @IBOutlet weak var accessKeyField: MLComboField!
    @IBOutlet weak var secretKeyField: MLComboField!
    
    override var account: Account! {
        didSet {
            if active {
                updateAccountFields()
            }
        }
    }
    
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
                a.region = regionSelector.stringValue
                
                
                accountController.updateAccountAtIndex(index, account: a, callback: { (error, account) -> Void in
                    if error != nil {
                        NSApplication.sharedApplication().presentError(error!)
                    }
                })
            }
        }

    }
    
}
