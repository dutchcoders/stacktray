//
//  AccountController.swift
//  stacktray
//
//  Created by Ruben Cagnie on 3/5/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Cocoa

@objc public protocol AccountControllerObserver {
    func didAddAccountAtIndex(accountController: AccountController, index: Int)
    func didDeleteAccountAtIndex(accountController: AccountController, index: Int)
    func didUpdateAccountAtIndex(accountController: AccountController, index: Int)
}

/** Protocol to control accounts of different services (AWS, iCloud...) */
public protocol AccountConnector {
    /** Creates an account based on a template account */
    func createAccount(account: Account, callback: (error: NSError?, account: Account?) -> Void)
    /** Updates an account based on a template account */
    func updateAccount(account: Account, callback: (error: NSError?, account: Account?) -> Void)
}

/** Is in charge of accounts */
public class AccountController: NSObject {
    
    let requestQueue = NSOperationQueue()
    
    /** Map of account types to the connector */
    public let connectors : Dictionary<AccountType, AccountConnector> = [
        AccountType.AWS : AWSAccountConnector(),
        AccountType.DUMMY : DummyAccountConnector()
    ]

    /** Array of accounts */
    public private(set) var accounts : [Account] = [] {
        didSet{
            if !NSKeyedArchiver.archiveRootObject(accounts, toFile: accountsFile){
                println("Unable to archive to \(accountsFile)")
            }
        }
    }
    
    /** Root to store objects */
    private var accountsFile: String

    /** Root to store objects */
    private var instancesFile: String
    
    let fileManager = NSFileManager.defaultManager()

    /** Init an account controller based on a root directory */
    public init(rootURL: String){
        self.accountsFile = rootURL.stringByAppendingPathComponent("accounts.bin")
        self.instancesFile = rootURL.stringByAppendingPathComponent("instances.bin")
        
        super.init()
        
        var isDir : ObjCBool = false
        if !fileManager.fileExistsAtPath(rootURL, isDirectory: &isDir) {
            fileManager.createDirectoryAtPath(rootURL, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
        
        readAccounts()
    }
    
    /** Read the accounts from disk */
    private func readAccounts(){
        if fileManager.fileExistsAtPath(accountsFile){
            if let accounts = NSKeyedUnarchiver.unarchiveObjectWithFile(accountsFile) as? [Account] {
                self.accounts = accounts
            } else {
                accounts = []
            }
        } else {
            accounts = []
        }
    }
    
    /** Creates an account based on a template account */
    public func createAccount(account: Account, callback: (error: NSError?, account: Account?) -> Void){
        if let connector = connectors[account.accountType] {
            requestQueue.addOperationWithBlock({ () -> Void in
                connector.createAccount(account, callback: { (error, account) -> Void in
                    if error != nil {
                        callback(error: error, account: nil)
                    } else {
                        self.accounts.append(account!)
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            //Notify
                            self.notifyObservers({ (observer) -> Void in
                                observer.didAddAccountAtIndex(self, index: find(self.accounts, account!)!)
                            })
                            
                            callback(error: nil, account: account)
                        })
                    }
                    
                })
            })
        } else {
            callback(error: NSError(domain: "AccountController", code: 0, userInfo: [NSLocalizedDescriptionKey : "Unknown type: \(account.description)"]), account: nil)
        }
    }
    
    /** Delete an account at index */
    public func deleteAccountAtIndex(index: Int) -> Account? {
        if index < 0 || index > accounts.count - 1 {
            return nil
        }
        
        let account = accounts.removeAtIndex(index)

        //Notify
        self.notifyObservers({ (observer) -> Void in
            observer.didDeleteAccountAtIndex(self, index: index)
        })

        return account
    }

    /** Update an account at index */
    public func updateAccountAtIndex(index: Int, account: Account, callback: (error: NSError?, account: Account?) -> Void) -> Void {
        if index < 0 || index > accounts.count - 1 {
            callback(error: NSError(domain: "AccountController", code: 0, userInfo: [NSLocalizedDescriptionKey : "Not a valid account index: \(index)"]), account: nil)
            
            return
        }
        
        if let connector = connectors[account.accountType] {
            requestQueue.addOperationWithBlock({ () -> Void in
                connector.updateAccount(account, callback: { (error, account) -> Void in
                    if error != nil {
                        callback(error: error, account: nil)
                        return
                    }
                    
                    
                    self.accounts[index] = account!
                    
                    //Notify
                    self.notifyObservers({ (observer) -> Void in
                        observer.didUpdateAccountAtIndex(self, index: find(self.accounts, account!)!)
                    })
                    
                    callback(error: nil, account: account)
                })
            })
        } else {
            callback(error: NSError(domain: "AccountController", code: 0, userInfo: [NSLocalizedDescriptionKey : "Unknown type: \(account.description)"]), account: nil)
        }
    }
    
    //MARK: Observers
    
    /** Observers */
    var observers = [NSObject]()
    
    public func addAccountControllerObserver(observer: NSObject){
        if !contains(observers, observer) {
            observers.append(observer)
        }
    }
    
    public func removeAccountControllerObserver(observer: NSObject){
        if let index = find(observers, observer){
            observers.removeAtIndex(index)
        }
    }
    
    /** Notify observers */
    internal func notifyObservers(callback: ((observer: AccountControllerObserver) -> Void)) {
        NSOperationQueue.mainQueue().addOperationWithBlock { ()  in
            for observer in self.observers {
                if let o = observer as? AccountControllerObserver {
                    callback(observer: o)
                }
            }
        }
    }

}

/** Dummy Account Controller for dev purposes only */
public class DummyAccountConnector: NSObject, AccountConnector {
    public func createAccount(account: Account, callback: (error: NSError?, account: Account?) -> Void){
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            sleep(1)
            callback(error: nil, account: account)
        }
    }
    
    public func updateAccount(account: Account, callback: (error: NSError?, account: Account?) -> Void) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            sleep(1)
            callback(error: nil, account: account)
        }
    }
}

/** AWS Account Controller for dev purposes only */
public class AWSAccountConnector: NSObject, AccountConnector {
    public func createAccount(account: Account, callback: (error: NSError?, account: Account?) -> Void) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            sleep(1)
            callback(error: nil, account: account)
        }
    }
    
    public func updateAccount(account: Account, callback: (error: NSError?, account: Account?) -> Void) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            sleep(1)
            callback(error: nil, account: account)
        }
    }

}

