//
//  Stack.swift
//  stacktray
//
//  Created by Ruben Cagnie on 3/5/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Foundation
import CoreData

@objc(Stack)
class Stack: NSManagedObject {

    @NSManaged var accessKey: String
    @NSManaged var pemFileLocation: String
    @NSManaged var region: String
    @NSManaged var secretKey: String
    @NSManaged var sshUser: String
    @NSManaged var title: String

}
