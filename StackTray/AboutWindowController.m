//
//  AboutWindowController.m
//  StackTray
//
//  Created by Remco on 28/04/14.
//  Copyright (c) 2014 DutchCoders. All rights reserved.
//

#import "AboutWindowController.h"
#import "AppDelegate.h"
#import "Stack.h"

@interface AboutWindowController ()
@end

static AboutWindowController *_sharedAboutWindowController = nil;

@implementation AboutWindowController

+ (AboutWindowController *)sharedAboutWindowController
{
    _sharedAboutWindowController = [[self alloc] initWithWindowNibName:[self nibName]];
	return _sharedAboutWindowController;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (BOOL)windowWillClose:(id)sender{
    return (YES);
}

+ (NSString *)nibName
{
    return @"AboutWindow";
}

@end
