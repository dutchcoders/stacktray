//
//  ConsoleViewController.swift
//  StackTray
//
//  Created by Ruben Cagnie on 3/11/15.
//  Copyright (c) 2015 dutchcoders. All rights reserved.
//

import Cocoa

class ConsoleViewController: NSViewController {
    var account: Account!
    var instance: Instance!

    @IBOutlet var textView: NSTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        self.view.window?.title = "Console for \(account.name) (\(instance.name))"
    }
    
}
