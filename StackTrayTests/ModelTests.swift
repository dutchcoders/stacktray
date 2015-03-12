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
        
        let aws2 = NSKeyedUnarchiver.unarchiveObjectWithData(data) as AWSAccount
        XCTAssertEqual(account1Name, aws2.name)
        XCTAssertEqual(account1AccessKey, aws2.accessKey)
        XCTAssertEqual(account1SecretKey, aws2.secretKey)
        XCTAssertEqual(account1Region, aws2.region)
    }
    
    func testArchivingDummyAccount(){
        let aws = Account(name: account1Name, accountType: .DUMMY)
        let data = NSKeyedArchiver.archivedDataWithRootObject(aws)
        
        XCTAssertNotNil(data)
        
        let aws2 = NSKeyedUnarchiver.unarchiveObjectWithData(data) as Account
        XCTAssertEqual(account1Name, aws2.name)
        XCTAssertEqual(AccountType.DUMMY, aws2.accountType)
    }
    
    func testArchivingMultipleAccounts(){
        let aws = AWSAccount(name: account1Name, accessKey: account1AccessKey, secretKey: account1SecretKey, region: account1Region)
        let dummy = Account(name: account2Name, accountType: .DUMMY)
        
        let accounts : [Account] = [aws, dummy]
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(accounts)
        
        XCTAssertNotNil(data)
        
        let accounts2 = NSKeyedUnarchiver.unarchiveObjectWithData(data) as [Account]
        XCTAssertEqual(2, accounts2.count)
        
        let aws2 = accounts2.first! as AWSAccount
        XCTAssertEqual(account1Name, aws2.name)
        XCTAssertEqual(account1AccessKey, aws2.accessKey)
        XCTAssertEqual(account1SecretKey, aws2.secretKey)
        XCTAssertEqual(account1Region, aws2.region)

        let dummy2 = accounts2.last! as Account
        XCTAssertEqual(account2Name, dummy2.name)
        XCTAssertEqual(AccountType.DUMMY, dummy2.accountType)
    }
    
}
