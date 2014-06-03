//
//  AppDelegate.h
//  StackTray
//
//  Created by Remco on 27/04/14.
//  Copyright (c) 2014 DutchCoders. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>
{
    NSStatusItem *statusItem;
    NSMutableDictionary* instances;
    IBOutlet NSMenu *statusMenu;
}

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)refresh;

@property (assign) IBOutlet NSWindow *window;

- (NSURL *)applicationDocumentsDirectory;

+ (AppDelegate *)sharedAppDelegate;
@end

