//
//  Account.swift
//  stacktray
//
//  Created by Ruben Cagnie on 3/4/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Cocoa

public enum AccountType : Int, Printable {
    case AWS, DUMMY, Unknown
    
    /** Name of the thumbnail that should be show */
    public var imageName: String {
        switch self{
        case .AWS: return "AWS"
        case .DUMMY: return "DUMMY"
        case .Unknown: return "UNKNOWN"
        }
    }
    
    /** Description */
    public var description: String {
        switch self{
        case .AWS: return "Amazon Web Service"
        case .DUMMY: return "DUMMY Web Service"
        case .Unknown: return "Unknown Web Service"
        }
    }
}

public protocol AccountDelegate {
    func didAddAccountInstance(account: Account, instanceIndex: Int)
    func didUpdateAccountInstance(account: Account, instanceIndex: Int)
    func didDeleteAccountInstance(account: Account, instanceIndex: Int)
    func instanceDidStart(account: Account, instanceIndex: Int)
    func instanceDidStop(account: Account, instanceIndex: Int)
}

/**
An account object represents the connection to a web service
*/
public class Account : NSObject, NSCoding {
    /** Meta Data */
    public var name: String = ""
    
    /** Account Type */
    public var accountType: AccountType = .Unknown
    
    /** Delegate */
    public var delegate : AccountDelegate?
    
    /** Instances */
    public var instances : [Instance] = [] {
        didSet{
            if let d = delegate {
                let oldInstanceIds = oldValue.map{ $0.instanceId }
                let newInstanceIds = instances.map{ $0.instanceId }
                
                for instance in instances {
                    if contains(oldInstanceIds, instance.instanceId) && contains(newInstanceIds, instance.instanceId) {
                        d.didUpdateAccountInstance(self, instanceIndex: find(instances, instance)!)
                    } else if contains(oldInstanceIds, instance.instanceId){
                        d.didDeleteAccountInstance(self, instanceIndex: find(instances, instance)!)
                    } else if contains(newInstanceIds, instance.instanceId){
                        d.didAddAccountInstance(self, instanceIndex: find(instances, instance)!)
                    }
                }
            }
        }
    }
    
    /** Init an Account Object */
    public init(name: String, accountType: AccountType){
        self.name = name
        self.accountType = accountType
        
        super.init()
    }
    
    required public init(coder aDecoder: NSCoder) {
        if let name = aDecoder.decodeObjectForKey("name") as? String {
            self.name = name
        }
        
        if let accountTypeNumber = aDecoder.decodeObjectForKey("accountType") as? NSNumber {
            if let accountType = AccountType(rawValue: accountTypeNumber.integerValue){
                self.accountType = accountType
            }
        }
        
        if let data = aDecoder.decodeObjectForKey("instances") as? NSData {
            if let instances = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Instance] {
                self.instances = instances
            }
        }
        
        super.init()
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(NSNumber(integer: accountType.rawValue), forKey: "accountType")
        aCoder.encodeObject(NSKeyedArchiver.archivedDataWithRootObject(instances), forKey: "instances")
    }
    
    public func addInstance(instance: Instance){
        instances.append(instance)
        if let d = delegate {
            d.didAddAccountInstance(self, instanceIndex: find(instances, instance)!)
        }
    }
    
    public func updateInstanceAtIndex(index: Int, instance: Instance){
        let existingInstance = instances[index]
                
        let beforeState = existingInstance.state
        existingInstance.mergeInstance(instance)
        
        if let d = delegate {
            d.didUpdateAccountInstance(self, instanceIndex: index)
            
            if instance.lastUpdate != nil && instance.state != beforeState {
                if instance.state == .Running {
                    d.instanceDidStart(self, instanceIndex: index)
                } else if instance.state == .Stopped {
                    d.instanceDidStop(self, instanceIndex: index)
                }
            }
        }
    }
    
    public func removeInstances(instanceIds: [String]){
        var toRemove = instances.filter { (instance) -> Bool in
            return contains(instanceIds, instance.instanceId)
        }
        
        for instance in toRemove {
            if let index = find(instances, instance){
                instances.removeAtIndex(index)
                if let d = delegate {
                    d.didDeleteAccountInstance(self, instanceIndex: index)
                }
            }
        }
    }
}

public class AWSAccount : Account {
    
    /** AWS Specific Keys */
    public var accessKey: String = ""
    public var secretKey: String = ""
    public var region: String = ""
 
    /** Init an AWS Account Object */
    public init(name: String, accessKey: String, secretKey: String, region: String){
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.region = region
        
        super.init(name: name, accountType: .AWS)
    }

    required public init(coder aDecoder: NSCoder) {
        if let accessKey = aDecoder.decodeObjectForKey("accessKey") as? String {
            self.accessKey = accessKey
        }
        
        if let secretKey = aDecoder.decodeObjectForKey("secretKey") as? String {
            self.secretKey = secretKey
        }
        
        if let region = aDecoder.decodeObjectForKey("region") as? String{
            self.region = region
        }
        
        super.init(coder: aDecoder)
    }
    public override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(accessKey, forKey: "accessKey")
        aCoder.encodeObject(secretKey, forKey: "secretKey")
        aCoder.encodeObject(region, forKey: "region")
        
        super.encodeWithCoder(aCoder)
    }
}
