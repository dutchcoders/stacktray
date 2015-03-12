//
//  ConsoleViewController.swift
//  StackTray
//
//  Created by Ruben Cagnie on 3/11/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Cocoa

class ConsoleViewController: NSViewController {
    var accountController: AccountController!
    var account: Account!
    var instance: Instance!

    @IBOutlet var textView: NSTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.reloadForAccount()
    }
    
    func reloadForAccount(){
        self.view.window?.title = "Console for \(account.name) (\(instance.name))"
        
        accountController.fetchConsoleOutput(account, instance: instance) { (error, output) -> Void in
            if error != nil {
                NSApplication.sharedApplication().presentError(error!)
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.textView.string = output
                })
            }
        }
    }
    
}
