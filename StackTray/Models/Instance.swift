//
//  Instance.swift
//  stacktray
//
//  Created by Ruben Cagnie on 3/4/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Cocoa

public enum InstanceState : Int, Printable {
    case Running
    case Stopped
    case Unknown
    
    public var description: String {
        switch self{
        case .Running: return "Running"
        case .Stopped: return "Stopped"
        case .Unknown: return "Unknown"
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
