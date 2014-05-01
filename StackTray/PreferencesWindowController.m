//
//  PreferencesWindowController.m
//  StackTray
//
//  Created by Remco on 28/04/14.
//  Copyright (c) 2014 DutchCoders. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "AppDelegate.h"
#import "Stack.h"

@interface PreferencesWindowController ()
@end

static PreferencesWindowController *_sharedPreferencesWindowController = nil;


@implementation PreferencesWindowController

+ (PreferencesWindowController *)sharedPreferencesWindowController
{
    _sharedPreferencesWindowController = [[self alloc] initWithWindowNibName:[self nibName]];
	return _sharedPreferencesWindowController;
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
    AppDelegate * appDelegate = (AppDelegate *) [[NSApplication sharedApplication] delegate];
    [appDelegate refresh];
    return (YES);
}

+ (NSString *)nibName
{
    return @"PreferencesWindow";
}

@end
