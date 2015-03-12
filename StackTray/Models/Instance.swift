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
public class Instance {
    
    public var name: String
    public var instanceId: String
    public var type: String
    public var state: InstanceState = .Unknown //Default to unknown
    
    public var publicDnsName : String
    public var publicIpAddress : String
    public var privateDnsName : String
    public var privateIpAddress : String
    
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
}
