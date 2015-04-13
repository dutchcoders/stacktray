//
//  STAccountControllerTests.swift
//  stacktray
//
//  Created by Ruben Cagnie on 3/5/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import XCTest
import StackTray


class AccountControllerTests: XCTestCase {
    lazy var rootURL : String = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let appSupportFile = (urls[urls.count - 1] as! NSURL).path!
        
        return appSupportFile.stringByAppendingPathComponent("io.dutchcoders.stacktray/test-data")
        }()
    
    var accountController: AccountController!
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        NSFileManager.defaultManager().removeItemAtPath(rootURL, error: nil)
        accountController = AccountController(rootURL: rootURL)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testShouldNotCreateUnknownAccount(){
        
        let unknown = Account(name: account1Name, accountType: .Unknown)
        
        let expectation = expectationWithDescription("Create Unknown Account")

        accountController.createAccount(unknown, callback: { (error, account) -> Void in
            XCTAssertNotNil(error)
            XCTAssertNil(account)
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(1, handler: { (error) -> Void in
            XCTAssertNil(error)
        })
    }
    
    func testCreateNewAccount(){
        let dummy = Account(name: account1Name, accountType: .DUMMY)
        
        let expectation = expectationWithDescription("Create Dummy Account")
        accountController.createAccount(dummy, callback: { (error, account) -> Void in
            XCTAssertNil(error)
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
            XCTAssertNil(error)
        })
        
        XCTAssertEqual(accountController.accounts.count, 1)
        
        XCTAssertEqual(1, accountController.accounts.count)
        let account = accountController.accounts[0]
        XCTAssertNotNil(account)
        XCTAssertEqual(account1Name, account.name)
    }
    
    /** Test if the accounts are correctly persisted */
    func testPersistCreationOfNewAccount(){
        let dummy = Account(name: account1Name, accountType: .DUMMY)
        let expectation = expectationWithDescription("Create Dummy Account")
        accountController.createAccount(dummy, callback: { (error, account) -> Void in
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
        })

        //Reset account controller
        accountController = AccountController(rootURL: rootURL)
        XCTAssertEqual(1, accountController.accounts.count)
        
        let account = accountController.accounts[0]
        XCTAssertNotNil(account)
        XCTAssertEqual(account1Name, account.name)
    }

    /** Test deleting an account */
    func testDeleteAccount(){
        let dummy = Account(name: account1Name, accountType: .DUMMY)
        let expectation = expectationWithDescription("Create Dummy Account")
        
        accountController.createAccount(dummy, callback: { (error, account) -> Void in
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
        })
        
        
        let dummy2 = accountController.deleteAccountAtIndex(0)
        XCTAssertNotNil(dummy2)
        XCTAssertEqual(0, accountController.accounts.count)
    }
    
    /** Test persisting deleting an account */
    func testPersistDeleteAccount(){
        let dummy = Account(name: account1Name, accountType: .DUMMY)
        let expectation = expectationWithDescription("Create Dummy Account")
        
        accountController.createAccount(dummy, callback: { (error, account) -> Void in
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
        })
        
        accountController.deleteAccountAtIndex(0)
        
        
        //Reset account controller
        accountController = AccountController(rootURL: rootURL)
        XCTAssertEqual(0, accountController.accounts.count)
    }


    /** Test Update Account */
    func testUpdateAccount(){
        let dummy = Account(name: account1Name, accountType: .DUMMY)
        let expectation = expectationWithDescription("Create Dummy Account")
        
        accountController.createAccount(dummy, callback: { (error, account) -> Void in
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
        })
        
        let dummy2 = accountController.accounts[0]
        dummy2.name = account2Name
//        accountController.updateAccountAtIndex(0, account: dummy2)
        
        XCTAssertEqual(account2Name, accountController.accounts[0].name)
    }
    
    /** Test persisting updating an account */
    func testPersistUpdateAccount(){
        let dummy = Account(name: account1Name, accountType: .DUMMY)
        let expectation = expectationWithDescription("Create Dummy Account")
        
        accountController.createAccount(dummy, callback: { (error, account) -> Void in
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
        })
        
        let dummy2 = accountController.accounts[0]
        dummy2.name = account2Name
        
        let expectation2 = expectationWithDescription("Update Dummy Account")

        accountController.updateAccountAtIndex(0, account: dummy2) { (error, account) -> Void in
            expectation2.fulfill()
        }
        
        waitForExpectationsWithTimeout(5, handler: { (error) -> Void in
        })

        //Reset account controller
        accountController = AccountController(rootURL: rootURL)
        XCTAssertEqual(1, accountController.accounts.count)
        XCTAssertEqual(account2Name, accountController.accounts[0].name)
    }
    
    
    func testCreateNewAWSAccount(){
        /*
        let accountController = AccountController(rootURL: rootURL)
        
        let aws = AWSAccount(name: account1Name, accessKey: account1AccessKey, secretKey: account1SecretKey, region: account1Region)
        
        let expectation = expectationWithDescription("Create AWS Account")
        accountController.createAccount(aws, callback: { (error, account) -> Void in
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(1, handler: { (error) -> Void in
            XCTAssertNil(error)
        })
        
        XCTAssertEqual(accountController.accounts.count, 1)
        
        for account in accountController.accounts {
            if account.name == account1Name {
                if let awsAccount = account as? AWSAccount {
                    XCTAssertEqual(account1AccessKey, awsAccount.accessKey)
                    XCTAssertEqual(account1SecretKey, awsAccount.secretKey)
                    XCTAssertEqual(account1Region, awsAccount.region)
                } else {
                    XCTFail("Account should be an AWS account")
                }
            }
        }
*/
    }

}
