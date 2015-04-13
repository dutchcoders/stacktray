//
//  Instance.swift
//  stacktray
//
//  Created by Ruben Cagnie on 3/4/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Cocoa

public enum InstanceState : Int, Printable {
    case Unknown, Pending, Running, ShuttingDown, Terminated, Stopping, Stopped

    public var description: String {
        switch self{
        case .Unknown: return "Unknown"
        case .Pending: return "Pending"
        case .Running: return "Running"
        case .ShuttingDown: return "ShuttingDown"
        case .Terminated: return "Terminated"
        case .Stopping: return "Stopping"
        case .Stopped: return "Stopped"
        }
    }
}

/** An Instance object represents a server instance that belongs to an account */
public class Instance : NSObject, NSCoding, Equatable {
    
    public var name: String
    public var instanceId: String
    public var type: String
    public var state: InstanceState = .Unknown //Default to unknown
    
    public var publicDnsName : String
    public var publicIpAddress : String
    public var privateDnsName : String
    public var privateIpAddress : String
    
    public var userId : String?
    public var pemLocation : String?
    
    public var lastUpdate: NSDate?
    
    /** Extra meta data */
    public var availabilityZone: String?
    public var architecture: String?
    public var imageId: String?
    public var instanceGroup: String?
    public var keyName: String?
    public var launchTime: NSDate?
    public var placementGroup: String?
    public var platform: String?
    public var vpcId: String?
    

    /** Default constructor for an Instance object */
    public init(name: String, instanceId: String, type: String, publicDnsName : String, publicIpAddress : String, privateDnsName : String, privateIpAddress : String){
        self.name = name
        self.instanceId = instanceId
        self.type = type
        
        self.publicDnsName = publicDnsName
        self.publicIpAddress = publicIpAddress
        
        self.privateDnsName = privateDnsName
        self.privateIpAddress = privateIpAddress
    }
    
    public required init(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.instanceId = aDecoder.decodeObjectForKey("instanceId") as! String
        self.type = aDecoder.decodeObjectForKey("type") as! String
        self.publicDnsName = aDecoder.decodeObjectForKey("publicDnsName") as! String
        self.publicIpAddress = aDecoder.decodeObjectForKey("publicIpAddress") as! String
        self.privateDnsName = aDecoder.decodeObjectForKey("privateDnsName") as! String
        self.privateIpAddress = aDecoder.decodeObjectForKey("privateIpAddress") as! String
        
        if let lastUpdate = aDecoder.decodeObjectForKey("lastUpdate") as? NSDate {
            self.lastUpdate = lastUpdate
        }

        if let userId = aDecoder.decodeObjectForKey("userId") as? String {
            self.userId = userId
        }

        if let pemLocation = aDecoder.decodeObjectForKey("pemLocation") as? String {
            self.pemLocation = pemLocation
        }

        super.init()
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.instanceId, forKey: "instanceId")
        aCoder.encodeObject(self.type, forKey: "type")
        aCoder.encodeObject(self.publicDnsName, forKey: "publicDnsName")
        aCoder.encodeObject(self.publicIpAddress, forKey: "publicIpAddress")
        aCoder.encodeObject(self.privateDnsName, forKey: "privateDnsName")
        aCoder.encodeObject(self.privateIpAddress, forKey: "privateIpAddress")
        
        if lastUpdate != nil {
            aCoder.encodeObject(self.lastUpdate, forKey: "lastUpdate")
        }
        
        if userId != nil {
            aCoder.encodeObject(self.userId, forKey: "userId")
        }

        if pemLocation != nil {
            aCoder.encodeObject(self.pemLocation, forKey: "pemLocation")
        }
    }
    
    func mergeInstance(instance: Instance){
        self.name = instance.name
        self.instanceId = instance.instanceId
        self.type = instance.type
        self.publicDnsName = instance.publicDnsName
        self.publicIpAddress = instance.publicIpAddress
        self.privateDnsName = instance.privateDnsName
        self.privateIpAddress = instance.privateIpAddress
        
        self.state = instance.state
        
        self.lastUpdate = NSDate()
        
        self.availabilityZone = instance.availabilityZone
        self.architecture = instance.architecture
        self.imageId = instance.imageId
        self.instanceGroup = instance.instanceGroup
        self.keyName = instance.keyName
        self.launchTime = instance.launchTime
        self.placementGroup = instance.placementGroup
        self.platform = instance.platform
        self.vpcId = instance.vpcId
    }
}

public func ==(lhs: Instance, rhs: Instance) -> Bool{
    return lhs.name == rhs.name && lhs.instanceId==rhs.instanceId && lhs.type==rhs.type && lhs.publicDnsName==rhs.publicDnsName && lhs.publicIpAddress==rhs.publicIpAddress && lhs.privateDnsName==rhs.privateDnsName && lhs.privateIpAddress==rhs.privateIpAddress && lhs.privateIpAddress==rhs.privateIpAddress && lhs.lastUpdate == rhs.lastUpdate
}
