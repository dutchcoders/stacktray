//
//  ModelTests.swift
//  stacktray
//
//  Created by Ruben Cagnie on 3/5/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import XCTest
import StackTray

class ModelTests: XCTestCase {

    func testArchivingAWSAccount(){
        let aws = AWSAccount(name: account1Name, accessKey: account1AccessKey, secretKey: account1SecretKey, region: account1Region)
        let data = NSKeyedArchiver.archivedDataWithRootObject(aws)
        
        aws.instances = [Instance(name: "", instanceId: "", type: "", publicDnsName: "", publicIpAddress: "", privateDnsName: "", privateIpAddress: "")]
        
        XCTAssertNotNil(data)
        
        let aws2 = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! AWSAccount
        XCTAssertEqual(account1Name, aws2.name)
        XCTAssertEqual(account1AccessKey, aws2.accessKey)
        XCTAssertEqual(account1SecretKey, aws2.secretKey)
        XCTAssertEqual(account1Region, aws2.region)
    }
    
    func testArchivingDummyAccount(){
        let aws = Account(name: account1Name, accountType: .DUMMY)
        let data = NSKeyedArchiver.archivedDataWithRootObject(aws)
        
        XCTAssertNotNil(data)
        
        let aws2 = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Account
        XCTAssertEqual(account1Name, aws2.name)
        XCTAssertEqual(AccountType.DUMMY, aws2.accountType)
    }
    
    func testArchivingMultipleAccounts(){
        let aws = AWSAccount(name: account1Name, accessKey: account1AccessKey, secretKey: account1SecretKey, region: account1Region)
        let dummy = Account(name: account2Name, accountType: .DUMMY)
        
        let accounts : [Account] = [aws, dummy]
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(accounts)
        
        XCTAssertNotNil(data)
        
        let accounts2 = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [Account]
        XCTAssertEqual(2, accounts2.count)
        
        let aws2 = accounts2.first! as! AWSAccount
        XCTAssertEqual(account1Name, aws2.name)
        XCTAssertEqual(account1AccessKey, aws2.accessKey)
        XCTAssertEqual(account1SecretKey, aws2.secretKey)
        XCTAssertEqual(account1Region, aws2.region)

        let dummy2 = accounts2.last! as Account
        XCTAssertEqual(account2Name, dummy2.name)
        XCTAssertEqual(AccountType.DUMMY, dummy2.accountType)
    }
    
    func testArchiveAccountWithInstance(){
        let aws = Account(name: account1Name, accountType: .DUMMY)
        aws.instances = [Instance(name: instance1Name, instanceId: instance1Id, type: instance1Type, publicDnsName: instance1PublicDnsName, publicIpAddress: instance1PublicIpAddress, privateDnsName: instance1PrivateDnsName, privateIpAddress: instance1PrivateIpAddress)]
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(aws)
        
        XCTAssertNotNil(data)
        
        let aws2 = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Account
        XCTAssertEqual(account1Name, aws2.name)
        XCTAssertEqual(AccountType.DUMMY, aws2.accountType)
        XCTAssertEqual(1, aws2.instances.count)
        let instance = aws2.instances[0]
        XCTAssertEqual(instance1Name, instance.name)
        XCTAssertEqual(instance1Id, instance.instanceId)
        XCTAssertEqual(instance1Type, instance.type)
        XCTAssertEqual(instance1PublicDnsName, instance.publicDnsName)
        XCTAssertEqual(instance1PublicIpAddress, instance.publicIpAddress)
        XCTAssertEqual(instance1PrivateDnsName, instance.privateDnsName)
        XCTAssertEqual(instance1PrivateIpAddress, instance.privateIpAddress)
    }
    
    func testArchiveAccountWithInstanceWithDate(){
        let aws = Account(name: account1Name, accountType: .DUMMY)
        aws.instances = [Instance(name: instance1Name, instanceId: instance1Id, type: instance1Type, publicDnsName: instance1PublicDnsName, publicIpAddress: instance1PublicIpAddress, privateDnsName: instance1PrivateDnsName, privateIpAddress: instance1PrivateIpAddress)]
        let date = NSDate()
        aws.instances[0].lastUpdate = date
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(aws)
        let aws2 = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Account
        let instance = aws2.instances[0]
        XCTAssertEqual(date, instance.lastUpdate!)
    }
    
    func testInstanceEquality(){
        let instance1 = Instance(name: instance1Name, instanceId: instance1Id, type: instance1Type, publicDnsName: instance1PublicDnsName, publicIpAddress: instance1PublicIpAddress, privateDnsName: instance1PrivateDnsName, privateIpAddress: instance1PrivateIpAddress)
        let instance2 = Instance(name: instance1Name, instanceId: instance1Id, type: instance1Type, publicDnsName: instance1PublicDnsName, publicIpAddress: instance1PublicIpAddress, privateDnsName: instance1PrivateDnsName, privateIpAddress: instance1PrivateIpAddress)
        XCTAssertEqual(instance1, instance2)
    }
    
    func testInstanceWithUserId(){
        let instance1 = Instance(name: instance1Name, instanceId: instance1Id, type: instance1Type, publicDnsName: instance1PublicDnsName, publicIpAddress: instance1PublicIpAddress, privateDnsName: instance1PrivateDnsName, privateIpAddress: instance1PrivateIpAddress)
        instance1.userId = instance1UserId
        let data = NSKeyedArchiver.archivedDataWithRootObject(instance1)
        let instance2 = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Instance
        
        XCTAssertEqual(instance1UserId, instance2.userId!)
    }
    
    func testInstanceWithPemlocation(){
        let instance1 = Instance(name: instance1Name, instanceId: instance1Id, type: instance1Type, publicDnsName: instance1PublicDnsName, publicIpAddress: instance1PublicIpAddress, privateDnsName: instance1PrivateDnsName, privateIpAddress: instance1PrivateIpAddress)
        instance1.pemLocation = instance1PemLocation
        let data = NSKeyedArchiver.archivedDataWithRootObject(instance1)
        let instance2 = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Instance
        
        XCTAssertEqual(instance1PemLocation, instance2.pemLocation!)
    }
    
}
