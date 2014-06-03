//
//  ConsoleWindowController.h
//  StackTray
//
//  Created by Remco on 03/06/14.
//  Copyright (c) 2014 DutchCoders. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ConsoleWindowController : NSWindowController
{
    IBOutlet NSTextView *textView;
}

@property NSString *output;

+ (ConsoleWindowController *)sharedConsoleWindowController;

@end
