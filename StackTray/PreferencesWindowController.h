//
//  PreferencesWindowController.h
//  StackTray
//
//  Created by Remco on 28/04/14.
//  Copyright (c) 2014 DutchCoders. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

@interface PreferencesWindowController : NSWindowController<NSOutlineViewDelegate,NSOutlineViewDataSource> {
    NSUserDefaults *userDefaults;
    IBOutlet NSOutlineView        *outlineView;
    IBOutlet NSArrayController     *arrayController;
    IBOutlet NSTreeController     *treeController;
    IBOutlet NSTableView          *tableView;
}

+ (PreferencesWindowController *)sharedPreferencesWindowController;
+ (NSString *)nibName;

@end
