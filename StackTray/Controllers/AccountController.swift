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
    
    func didAddAccountInstance(accountController: AccountController, index: Int, instanceIndex: Int)
    func didUpdateAccountInstance(accountController: AccountController, index: Int, instanceIndex: Int)
    func didDeleteAccountInstance(accountController: AccountController, index: Int, instanceIndex: Int)
    
    optional func instanceDidStart(accountController: AccountController, index: Int, instanceIndex: Int)
    optional func instanceDidStop(accountController: AccountController, index: Int, instanceIndex: Int)
}

/** Protocol to control accounts of different services (AWS, iCloud...) */
public protocol AccountConnector {
    /** Creates an account based on a template account */
    func createAccount(account: Account, callback: (error: NSError?, account: Account?) -> Void)
    /** Updates an account based on a template account */
    func updateAccount(account: Account, callback: (error: NSError?, account: Account?) -> Void)
    /** Refresh an account */
    func refreshAccount(account: Account, callback: (error: NSError?, account: Account?)->Void)
    /** Start instance */
    func startInstance(account: Account, instance: Instance, callback: (error: NSError?)->Void)
    /** Stop instance */
    func stopInstance(account: Account, instance: Instance, callback: (error: NSError?)->Void)
    /** Reboot instance */
    func rebootInstance(account: Account, instance: Instance, callback: (error: NSError?)->Void)
    /** Fetch the output from a console */
    func fetchConsoleOutput(account: Account, instance: Instance, callback: (error: NSError?, output: String?) -> Void)

}

/** Is in charge of accounts */
public class AccountController: NSObject, AccountDelegate {
    /** Queue used for refreshing accounts */
    let requestQueue = NSOperationQueue()

    /** Update interval for fetching data once in a while */
    let updateInterval: NSTimeInterval = 60 /* minutes */ * 60 /* seconds */
    
    /** Interval for refreshing (e.g. start/stop instance) */
    let refreshInterval: NSTimeInterval = 1 /* seconds */
    var refreshingInstances : [String] = []
    var refreshTimer: NSTimer?
    

    /** Map of account types to the connector */
    public let connectors : Dictionary<AccountType, AccountConnector> = [
        AccountType.AWS : AWSAccountConnector(),
        AccountType.DUMMY : DummyAccountConnector()
    ]

    /** Array of accounts */
    public private(set) var accounts : [Account] = [] {
        didSet{
            self.saveAccounts()
        }
    }
    
    public func saveAccounts(){
        if !NSKeyedArchiver.archiveRootObject(accounts, toFile: accountsFile){
            println("Unable to archive to \(accountsFile)")
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
        
        //Refresh the list once in a while
        var timer = NSTimer.scheduledTimerWithTimeInterval(updateInterval, target: self, selector: Selector("refreshAccounts"), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    /** Read the accounts from disk */
    private func readAccounts(){
        if fileManager.fileExistsAtPath(accountsFile){
            if let accounts = NSKeyedUnarchiver.unarchiveObjectWithFile(accountsFile) as? [Account] {
                self.accounts = accounts
                self.refreshAccounts()
            } else {
                accounts = []
            }
        } else {
            accounts = []
        }
    }
    
    public func refreshAccount(account: Account){
        if let index = find(accounts, account){
            println("Refreshing \(account.name)")
            self.updateAccountAtIndex(index, account: account, callback: { (error, account) -> Void in
                
            })
        }
    }
    
    public func refreshAccounts(){
        for (index, account) in enumerate(accounts) {
            account.delegate = self
            self.updateAccountAtIndex(index, account: account, callback: { (error, account) -> Void in
                
            })
        }
    }
    
    public func didAddAccountInstance(account: Account, instanceIndex: Int) {
        println("Did add account instance!!!")
        notifyObservers { (observer) -> Void in
            observer.didAddAccountInstance(self, index: find(self.accounts, account)!, instanceIndex: instanceIndex)
        }
    }
    
    public func didUpdateAccountInstance(account: Account, instanceIndex: Int) {
        println("Did update account instance!!!")
        notifyObservers { (observer) -> Void in
            observer.didUpdateAccountInstance(self, index: find(self.accounts, account)!, instanceIndex: instanceIndex)
        }
    }
    
    public func didDeleteAccountInstance(account: Account, instanceIndex: Int) {
        println("Did delete account instance!!!")
        notifyObservers { (observer) -> Void in
            observer.didDeleteAccountInstance(self, index: find(self.accounts, account)!, instanceIndex: instanceIndex)
        }
    }
    
    public func instanceDidStart(account: Account, instanceIndex: Int){
        stopRefreshTimerForInstance(account.instances[instanceIndex])

        notifyObservers { (observer) -> Void in
            if observer.instanceDidStart != nil {
                observer.instanceDidStart!(self, index: find(self.accounts, account)!, instanceIndex: instanceIndex)
            }
        }
    }
    
    public func instanceDidStop(account: Account, instanceIndex: Int){
        stopRefreshTimerForInstance(account.instances[instanceIndex])

        notifyObservers { (observer) -> Void in
            if observer.instanceDidStop != nil {
                observer.instanceDidStop!(self, index: find(self.accounts, account)!, instanceIndex: instanceIndex)
            }
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
            callback(error: createUnknownAccountTypeError(account), account: nil)
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
            callback(error: createUnknownAccountTypeError(account), account: nil)
        }
    }
    
    /** Start instance */
    public func startInstance(account: Account, instance: Instance, callback: (error: NSError?) -> Void){
        let index = find(accounts, account)
        if let connector = connectors[account.accountType] {
            requestQueue.addOperationWithBlock({ () -> Void in
                connector.startInstance(account, instance: instance, callback: { (error) -> Void in
                    if error == nil {
                        self.startRefrehTimerForInstance(instance)

                        self.updateAccountAtIndex(index!, account: account, callback: { (error, account) -> Void in
                            callback(error : error)
                        })
                    } else {
                        callback(error: error)
                    }
                })
            })
        } else {
            callback(error: createUnknownAccountTypeError(account))
        }
    }
    
    /** Stop instance */
    public func stopInstance(account: Account, instance: Instance, callback: (error: NSError?) -> Void){
        let index = find(accounts, account)
        if let connector = connectors[account.accountType] {
            requestQueue.addOperationWithBlock({ () -> Void in
                connector.stopInstance(account, instance: instance, callback: { (error) -> Void in
                    if error == nil {
                        self.startRefrehTimerForInstance(instance)
                        
                        self.updateAccountAtIndex(index!, account: account, callback: { (error, account) -> Void in
                            callback(error : error)
                        })
                    } else {
                        callback(error: error)
                    }
                })
            })
        } else {
            callback(error: createUnknownAccountTypeError(account))
        }
    }
    
    /** Reboot instance */
    public func rebootInstance(account: Account, instance: Instance, callback: (error: NSError?) -> Void){
        let index = find(accounts, account)
        if let connector = connectors[account.accountType] {
            requestQueue.addOperationWithBlock({ () -> Void in
                connector.rebootInstance(account, instance: instance, callback: { (error) -> Void in
                    if error == nil {
                        self.updateAccountAtIndex(index!, account: account, callback: { (error, account) -> Void in
                            callback(error : error)
                        })
                    } else {
                        callback(error: error)
                    }
                })
            })
        } else {
            callback(error: createUnknownAccountTypeError(account))
        }
    }
    
    func fetchConsoleOutput(account: Account, instance: Instance, callback: (error: NSError?, output: String?) -> Void){
        let index = find(accounts, account)
        if let connector = connectors[account.accountType] {
            requestQueue.addOperationWithBlock({ () -> Void in
                connector.fetchConsoleOutput(account, instance: instance, callback: callback)
            })
        } else {
            callback(error: createUnknownAccountTypeError(account), output: nil)
        }

    }

    /** Utility function for unknown account types */
    func createUnknownAccountTypeError(account: Account) -> NSError {
        return NSError(domain: "AccountController", code: 0, userInfo: [NSLocalizedDescriptionKey : "Unknown type: \(account.accountType.description)"])
    }
    
    func accountForInstance(instance: Instance) -> Account {
        var filter = accounts.filter { (account) -> Bool in
            return contains(account.instances, instance)
        }
        return filter[0]
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
    
    //MARK - Timer
    /**
    Start the refresh timer if need be (if refreshing queue is not empty and the timer is nil)
    */
    func startRefreshTimerIfNeeded(){
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            if self.refreshingInstances.isEmpty {
                //If the refreshing instances is empty, consider to stop the timer
                self.stopRefreshTimerIfNeeded()
                return
            } else if self.refreshTimer == nil {
                self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(self.refreshInterval, target: self, selector: Selector("refreshAccounts"), userInfo: nil, repeats: true)
                NSRunLoop.mainRunLoop().addTimer(self.refreshTimer!, forMode: NSRunLoopCommonModes)
            }
        }
    }
    
    /**
    Stop the refresh timer if need be (if refreshing queue is empty and the timer is not nil)
    */
    func stopRefreshTimerIfNeeded(){
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            if self.refreshingInstances.isEmpty {
                if self.refreshTimer != nil {
                    self.refreshTimer!.invalidate()
                    self.refreshTimer = nil
                }
            }
        }
    }
    
    /** Stop the timer for an instance */
    func stopRefreshTimerForInstance(instance: Instance){
        if let index = find(refreshingInstances, instance.instanceId){
            refreshingInstances.removeAtIndex(index)
        }
        
        stopRefreshTimerIfNeeded()
    }
    
    /** Start the timer for an instance */
    func startRefrehTimerForInstance(instance: Instance){
        if !contains(self.refreshingInstances, instance.instanceId){
            self.refreshingInstances.append(instance.instanceId)
        }
        self.startRefreshTimerIfNeeded()
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
    
    public func refreshAccount(account: Account, callback: (error: NSError?, account: Account?) -> Void) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            sleep(1)
            callback(error: nil, account: account)
        }
    }
    
    public func startInstance(account: Account, instance: Instance, callback: (error: NSError?) -> Void) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            sleep(1)
            callback(error: nil)
        }
    }
    
    public func stopInstance(account: Account, instance: Instance, callback: (error: NSError?) -> Void) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            sleep(1)
            callback(error: nil)
        }
    }
    
    public func rebootInstance(account: Account, instance: Instance, callback: (error: NSError?) -> Void) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            sleep(1)
            callback(error: nil)
        }
    }
    
    public func fetchConsoleOutput(account: Account, instance: Instance, callback: (error: NSError?, output: String?) -> Void) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            sleep(1)
            callback(error: nil, output: "")
        }
    }
}

/** AWS Account Controller for dev purposes only */
public class AWSAccountConnector: NSObject, AccountConnector {
    
    /** Dictionary that maps region strings to AWSRegionType objects */
    let regionStringToType : Dictionary<String, AWSRegionType> = [
        "ec2.us-east-1.amazonaws.com" : AWSRegionType.USEast1,
        "ec2.us-west-2.amazonaws.com" : AWSRegionType.USWest2,
        "ec2.us-west-1.amazonaws.com" : AWSRegionType.USWest1,
        "ec2.eu-west-1.amazonaws.com" : AWSRegionType.USWest1,
        "ec2.ap-southeast-1.amazonaws.com" : AWSRegionType.APSoutheast1,
        "ec2.ap-southeast-2.amazonaws.com" : AWSRegionType.APSoutheast2,
        "ec2.ap-northeast-1.amazonaws.com" : AWSRegionType.APNortheast1,
        "ec2.sa-east-1.amazonaws.com" : AWSRegionType.SAEast1
        ]
    
    /** Dictionary that maps instance types to strings */
    let instanceTypeToString : Dictionary<AWSEC2InstanceType, String> = [
        .Unknown : "Unknown",
        .T1_micro : "T1 micro",
        .M1_small : "M1 small",
        .M1_medium : "M1 medium",
        .M1_large : "M1 large",
        .M1_xlarge : "M1 xlarge",
        .M3_medium : "M3 medium",
        .M3_large : "M3 large",
        .M3_xlarge : "M3 xlarge",
        .M3_2xlarge : "M3 2xlarge",
        .T2_micro : "T2 micro",
        .T2_small : "T2 small",
        .T2_medium : "T2 medium",
        .M2_xlarge : "M2 xlarge",
        .M2_2xlarge : "M2 2xlarge",
        .M2_4xlarge : "M2 4xlarge",
        .CR1_8xlarge : "CR1 8xlarge",
        .I2_xlarge : "I2 xlarge",
        .I2_2xlarge : "I2 2xlarge",
        .I2_4xlarge : "I2 4xlarge",
        .I2_8xlarge : "I2 8xlarge",
        .HI1_4xlarge : "HI1 4xlarge",
        .HS1_8xlarge : "HS1 8xlarge",
        .C1_medium : "C1 medium",
        .C1_xlarge : "C1 xlarge",
        .C3_large : "C3 large",
        .C3_xlarge : "C3 xlarge",
        .C3_2xlarge : "C3 2xlarge",
        .C3_4xlarge : "C3 4xlarge",
        .C3_8xlarge : "C3 8xlarge",
        .CC1_4xlarge : "CC1 4xlarge",
        .CC2_8xlarge : "CC2 8xlarge",
        .G2_2xlarge : "G2 2xlarge",
        .CG1_4xlarge : "CG1 4xlarge",
        .R3_large : "R3 large",
        .R3_xlarge : "R3 xlarge",
        .R3_2xlarge : "R3 2xlarge",
        .R3_4xlarge : "R3 4xlarge",
        .R3_8xlarge : "R3 8xlarge",
    ]
    

    /** Create an AWS connection object */
    func createAwsConnection(aws: AWSAccount) -> (NSError?, AWSEC2?) {
        let region = regionStringToType[aws.region]
        if region == nil {
            let error = NSError(domain: "AWS", code: 0, userInfo: [NSLocalizedDescriptionKey: "Region is unknown"])
            return (error, nil)
        }
        
        let credentials = AWSStaticCredentialsProvider(accessKey: aws.accessKey, secretKey: aws.secretKey)
        let awsConnection = AWSEC2(configuration: AWSServiceConfiguration(region: region!, credentialsProvider: credentials))
        return (nil, awsConnection)
    }
    
    public func startInstance(account: Account, instance: Instance, callback: (error: NSError?) -> Void) {
        let aws = account as AWSAccount
        let (error, awsConnection) = createAwsConnection(aws)
        if error != nil {
            callback(error: error)
        } else {
            let startRequest = AWSEC2StartInstancesRequest()
            startRequest.instanceIds = [instance.instanceId]
            awsConnection?.startInstances(startRequest).continueWithBlock { (task) -> AnyObject! in
                callback(error: task.error)
                return nil
            }
        }
    }
    
    public func stopInstance(account: Account, instance: Instance, callback: (error: NSError?) -> Void) {
        let aws = account as AWSAccount
        let (error, awsConnection) = createAwsConnection(aws)
        if error != nil {
            callback(error: error)
        } else {
            let stopRequest = AWSEC2StopInstancesRequest()
            stopRequest.instanceIds = [instance.instanceId]
            awsConnection?.stopInstances(stopRequest).continueWithBlock { (task) -> AnyObject! in
                callback(error: task.error)
                return nil
            }
        }
    }
    
    public func rebootInstance(account: Account, instance: Instance, callback: (error: NSError?) -> Void) {
        let aws = account as AWSAccount
        let (error, awsConnection) = createAwsConnection(aws)
        if error != nil {
            callback(error: error)
        } else {
            let rebootRequest = AWSEC2RebootInstancesRequest()
            rebootRequest.instanceIds = [instance.instanceId]
            awsConnection?.rebootInstances(rebootRequest).continueWithBlock { (task) -> AnyObject! in
                callback(error: task.error)
                return nil
            }
        }
    }
    
    public func fetchConsoleOutput(account: Account, instance: Instance, callback: (error: NSError?, output: String?) -> Void){
        let aws = account as AWSAccount
        let (error, awsConnection) = createAwsConnection(aws)
        if error != nil {
            callback(error: error, output: nil)
        } else {
            let consoleRequest = AWSEC2GetConsoleOutputRequest()
            consoleRequest.instanceId = instance.instanceId
            awsConnection?.getConsoleOutput(consoleRequest).continueWithBlock { (task) -> AnyObject! in
                if task.error != nil {
                    callback(error: task.error, output: nil)
                } else {
                    if let output = (task.result as AWSEC2GetConsoleOutputResult).output {
                        println("Result: \(output)")
                        let nsdata: NSData = NSData(base64EncodedString: output, options: NSDataBase64DecodingOptions(rawValue: 0))!
                        let base64Decoded: NSString = NSString(data: nsdata, encoding: NSUTF8StringEncoding)!
                        callback(error: nil, output: base64Decoded)
                    }
                }
                return nil
            }
        }

    }
    
    /** Create an AWS Account */
    public func createAccount(account: Account, callback: (error: NSError?, account: Account?) -> Void) {
        refreshAccount(account, callback: callback)
    }

    /** Update an AWS Account */
    public func updateAccount(account: Account, callback: (error: NSError?, account: Account?) -> Void) {
        refreshAccount(account, callback: callback)
    }
    
    /* Refresh an AWS Account */
    public func refreshAccount(account: Account, callback: (error: NSError?, account: Account?)->Void) {
        let aws = account as AWSAccount
        
        let (error, awsConnection) = createAwsConnection(aws)
        if error != nil {
            callback(error: error, account : nil)
        } else {
            println("AWS Connection Established")
            
            let instancesRequest = AWSEC2DescribeInstancesRequest()
            awsConnection!.describeInstances(instancesRequest).continueWithBlock { (task) -> AnyObject! in
                
                if task.error != nil {
                    println("Error: \(task.error)")
                    callback(error: task.error, account: nil)
                } else {
                    let result = task.result as AWSEC2DescribeInstancesResult
                    
                    var existingInstanceIds = account.instances.map{ $0.instanceId }
                    
                    var atLeastOneInstance = false

                    for reservation in result.reservations as [AWSEC2Reservation] {
                        for instance in reservation.instances as [AWSEC2Instance]{
                            println("Found instance: \(instance.instanceId)")
                            atLeastOneInstance = true
                            
                            var name = instance.instanceId
                            for tag in instance.tags as [AWSEC2Tag] {
                                if tag.key() == "Name" && !tag.value().isEmpty {
                                    name = tag.value()
                                }
                            }
                            
                            let state = instance.state
                            let instanceState = InstanceState(rawValue: instance.state.name.rawValue)
                            let instanceId = instance.instanceId
                            let instanceType = self.instanceTypeToString[instance.instanceType]!
                            
                            let publicDnsName = instance.publicDnsName
                            let publicIpAddress = instance.publicIpAddress
                            let privateDnsName = instance.privateDnsName
                            let privateIpAddress = instance.privateIpAddress
                            
                            let instance = Instance(name: name, instanceId: instanceId, type: instanceType, publicDnsName: publicDnsName == nil ? "" : publicDnsName, publicIpAddress: publicIpAddress == nil ? "" : publicIpAddress, privateDnsName: privateDnsName == nil ? "" : privateDnsName, privateIpAddress: privateIpAddress==nil ? "" : privateIpAddress)
                            instance.state = instanceState!
                            
                            if let index = find(existingInstanceIds, instanceId){
                                account.updateInstanceAtIndex(index, instance: instance)
                                existingInstanceIds.removeAtIndex(index)
                            } else {
                                account.addInstance(instance)
                            }
                        }
                    }

                    //Remove that were not found
                    account.removeInstances(existingInstanceIds)

                    if !atLeastOneInstance {
                        callback(error: NSError(domain: "AWS", code: 0, userInfo: [NSLocalizedDescriptionKey: "No instances found"]), account: nil)
                    } else {
                        callback(error: nil, account: account)
                    }
                }
                return nil
            }
        }
    }

}

