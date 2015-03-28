//
//  TestViewController.swift
//  StackTray
//
//  Created by Ruben Cagnie on 3/27/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    /** Account Controller */
    var accountController: AccountController! {
        didSet {
            accountsTableView.reloadData()
        }
    }

    @IBOutlet weak var accountsTableView: NSTableView!
    @IBOutlet weak var deselectedContentView: NSView!
    @IBOutlet weak var detailContentView: NSView!
    
    @IBOutlet var groupView: MLRadioGroupManager!
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if accountController == nil {
            return 0
        }

        return accountController.accounts.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return accountController?.accounts[row].name
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
            detailContentView.hidden = true
            deselectedContentView.hidden = false
        } else {
            detailContentView.hidden = false
            deselectedContentView.hidden = true
            detailAccountViewController.account = accountController?.accounts[row] as AWSAccount
        }
    }
    
    var detailAccountViewController : DetailAccountViewController!
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if let detail = segue.destinationController as? DetailAccountViewController {
            detailAccountViewController = detail
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
        
        if let instanceCell = tableView.makeViewWithIdentifier("InstanceCell", owner: self) as? InstanceCellView {
            instanceCell.instance = instance
            return instanceCell
        } else {
            return nil
        }
    }
    
    func selectionShouldChangeInTableView(tableView: NSTableView) -> Bool {
        return false
    }
}