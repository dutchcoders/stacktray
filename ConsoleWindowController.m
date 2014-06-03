//
//  ConsoleWindowController.m
//  StackTray
//
//  Created by Remco on 03/06/14.
//  Copyright (c) 2014 DutchCoders. All rights reserved.
//

#import "ConsoleWindowController.h"

@interface ConsoleWindowController ()

@end

static ConsoleWindowController *_sharedConsoleWindowController = nil;

@implementation ConsoleWindowController

+ (ConsoleWindowController *)sharedConsoleWindowController
{
    _sharedConsoleWindowController = [[self alloc] initWithWindowNibName:@"ConsoleWindow"];
    return _sharedConsoleWindowController;
}

- (instancetype)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    [textView setString:[self output]];
}

@end
