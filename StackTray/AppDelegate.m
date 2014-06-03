//
//  AppDelegate.m
//  StackTray
//
//  Created by Remco on 27/04/14.
//  Copyright (c) 2014 DutchCoders. All rights reserved.
//

#import "AppDelegate.h"
#import "PreferencesWindowController.h"
#import "AboutWindowController.h"

#import </Users/remco/Projects/aws-sdk-ios/src/include/EC2/AmazonEC2Client.h>

#import "Stack.h"

@implementation AppDelegate

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *)[[NSApplication sharedApplication] delegate];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

- (void)awakeFromNib
{
    // Build the statusbar menu
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    [statusItem setHighlightMode:YES];
    [statusItem setTitle:[NSString stringWithFormat:@"%C",0x2601]];
    [statusItem setEnabled:YES];
    
    [self updateMenu];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
}


/*
- (NSMenu *)applicationDockMenu:(NSApplication *)sender {
    if (m_menu == nil) {
        m_menu = [[NSMenu alloc] init];
        
        id titleMenuItem = [[NSMenuItem alloc] initWithTitle:@"test" action:@selector(terminate:) keyEquivalent:@"q"];
        
        [m_menu addItem:titleMenuItem];
        [m_menu addItem:[NSMenuItem separatorItem]];
        NSMenuItem *openMenuItem = [[NSMenuItem alloc] initWithTitle:@"Open in Browser" action:@selector(openUrl) keyEquivalent:@""];
        [m_menu addItem:openMenuItem];
        NSMenuItem *copyUrlMenuItem = [[NSMenuItem alloc] initWithTitle:@"Copy link to Clipboard" action:@selector(copyUrl) keyEquivalent:@""];
        [m_menu addItem:copyUrlMenuItem];
        
        // OSX will automatically add the Quit option
        
    }
    return m_menu;
}
*/

- (IBAction)connect:(id)sender {
    NSMenuItem* menuItem= (NSMenuItem*)sender;

    EC2Instance* instance = (EC2Instance*)menuItem.representedObject;

    NSString* address = instance.publicDnsName;
    
    if ([address length]==0) {
        address = instance.privateDnsName;
    }
    
    // get from settings
    NSString *path = [[NSBundle mainBundle] pathForResource:@"connect" ofType:@"scpt"];

    NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSString* username = @"ubuntu";

    NSLog(@"%@", script);
    
    
    NSAppleScript *appleScript =
    [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:script, [instance instanceId], username, address]];

    NSDictionary *error;
    NSAppleEventDescriptor *result =
        [appleScript executeAndReturnError:&error];
    
    if (error!=nil) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Close"];
        [alert setMessageText:@"Error connecting to iTerm."];
        [alert setInformativeText: [error objectForKey:@"NSAppleScriptErrorMessage"]];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }
}

- (IBAction)browse:(id)sender {
    // http://lifehacker.com/5533695/open-links-in-your-macs-current-browser-instead-of-the-default
    
    NSMenuItem* menuItem= (NSMenuItem*)sender;
    
    EC2Instance* instance = (EC2Instance*)menuItem.representedObject;
    
    NSString* address = instance.publicDnsName;
    
    if ([address length]==0) {
        address = instance.privateDnsName;
    }
    
    NSString *script = [NSString stringWithFormat:@"open location \"http://%@/\" \n", address ];
    
    NSAppleScript *appleScript =
    [[NSAppleScript alloc] initWithSource:script];
    
    NSDictionary *error;
    NSAppleEventDescriptor *result =
    [appleScript executeAndReturnError:&error];
}


- (IBAction)reboot:(id)sender {
    NSMenuItem* menuItem= (NSMenuItem*)sender;
    
    AmazonEC2Client* client = (AmazonEC2Client*)[((NSDictionary*)menuItem.representedObject) objectForKey:@"client"];
    EC2Instance* instance = (EC2Instance*)[((NSDictionary*)menuItem.representedObject) objectForKey:@"instance"];
    
    EC2RebootInstancesRequest* rq = [[EC2RebootInstancesRequest alloc] initWithInstanceIds:[[NSMutableArray alloc] initWithObjects: instance.instanceId, nil]];
    
    EC2RebootInstancesResponse* response = [client rebootInstances:(EC2RebootInstancesRequest *)rq];

    // wait for reboot up status, then show notification
    /*
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Server rebooted";
    notification.informativeText = [NSString stringWithFormat:@"Server %@ has been rebooted.", [instance instanceId]];
    notification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    */
}

- (IBAction)consoleOutput:(id)sender {
    NSMenuItem* menuItem= (NSMenuItem*)sender;
    
    AmazonEC2Client* client = (AmazonEC2Client*)[((NSDictionary*)menuItem.representedObject) objectForKey:@"client"];
    EC2Instance* instance = (EC2Instance*)[((NSDictionary*)menuItem.representedObject) objectForKey:@"instance"];
    
    EC2GetConsoleOutputRequest* rq = [[EC2GetConsoleOutputRequest alloc] initWithInstanceId:instance.instanceId];
    
    @try {
        EC2GetConsoleOutputResponse* response = [client getConsoleOutput:(EC2GetConsoleOutputRequest *)rq];
        
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:[response output] options:0];
        NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", decodedString); // foo
    }
    @catch (AmazonClientException *exception) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Close"];
        [alert setMessageText:[exception name]];
        [alert setInformativeText:[exception message]];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}


- (IBAction)start:(id)sender {
    NSMenuItem* menuItem= (NSMenuItem*)sender;

    AmazonEC2Client* client = (AmazonEC2Client*)[((NSDictionary*)menuItem.representedObject) objectForKey:@"client"];
    EC2Instance* instance = (EC2Instance*)[((NSDictionary*)menuItem.representedObject) objectForKey:@"instance"];
    
    EC2StartInstancesRequest* rq = [[EC2StartInstancesRequest alloc] initWithInstanceIds:[[NSMutableArray alloc] initWithObjects: instance.instanceId, nil]];
    
    @try {
        EC2StartInstancesResponse* response = [client startInstances:(EC2StartInstancesRequest *)rq];
    }
    @catch (AmazonClientException *exception) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Close"];
        [alert setMessageText:[exception name]];
        [alert setInformativeText:[exception message]];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}

- (IBAction)stop:(id)sender {
    NSMenuItem* menuItem= (NSMenuItem*)sender;
    
    AmazonEC2Client* client = (AmazonEC2Client*)[((NSDictionary*)menuItem.representedObject) objectForKey:@"client"];
    EC2Instance* instance = (EC2Instance*)[((NSDictionary*)menuItem.representedObject) objectForKey:@"instance"];
    
    EC2StopInstancesRequest* rq = [[EC2StopInstancesRequest alloc] initWithInstanceIds:[[NSMutableArray alloc] initWithObjects: instance.instanceId, nil]];
    
    @try {
        EC2StopInstancesResponse* response = [client stopInstances:(EC2StopInstancesRequest *)rq];
    }
    @catch (AmazonClientException *exception) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Close"];
        [alert setMessageText:[exception name]];
        [alert setInformativeText:[exception message]];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}

- (IBAction)refresh:(id)sender {
    [self updateMenu];
}

- (void)refresh {
    [self updateMenu];
}

- (void)updateMenu {
    statusMenu = [[NSMenu alloc]initWithTitle: @"Tray"];
    
    NSManagedObjectContext *context = [self managedObjectContext];

    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stack" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];

    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects.count>0) {
        for (Stack *stack in fetchedObjects) {
            if (stack.accessKey==nil || [stack.accessKey isEqualToString:@""]) {
                continue;
            }
            
            if (stack.secretKey==nil || [stack.secretKey isEqualToString:@""]) {
                continue;
            }
            
            if (stack.region == nil || [stack.region isEqualToString:@""]) {
                continue;
            }
            
            @try {
                AmazonEC2Client* client = [[AmazonEC2Client alloc] initWithAccessKey:stack.accessKey withSecretKey:stack.secretKey];
                
                client.endpoint =  [@"https://" stringByAppendingString:stack.region];

                NSLog(@"%@ %@ %@", stack.accessKey, stack.secretKey, [@"https://" stringByAppendingString:stack.region]);
                EC2DescribeInstancesRequest* rq = [EC2DescribeInstancesRequest alloc];
                EC2DescribeInstancesResponse* response = [client describeInstances:(EC2DescribeInstancesRequest *)rq];
                
                NSMenu* instancesMenu = [[NSMenu alloc]initWithTitle: stack.title];
                
                NSMenuItem* instancesMenuItem = [[NSMenuItem alloc] initWithTitle:stack.title action:nil keyEquivalent:@"" ];
                [instancesMenuItem setSubmenu:instancesMenu];
                
                for (EC2Reservation* reservation in [response reservations]) {
                    NSLog(@"%@",reservation);
                    
                    for (EC2Instance* instance in [reservation instances]) {
                        [instances setObject:instance forKey:[instance instanceId]];

                        NSLog(@"%@",instance.tags);
                        
                        NSString* title=[instance instanceId];

                        for (EC2Tag* tag in [instance tags]) {
                            if ([tag.key caseInsensitiveCompare:@"Name"]==NSOrderedSame) {
                                title = tag.value;
                            }
                        }
                        
                        NSMenu* instanceMenu = [[NSMenu alloc]initWithTitle: title];
                        
                        NSMenuItem* subMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"InstanceId: %@", [instance instanceId]] action:nil keyEquivalent:@""];
                        subMenuItem.representedObject=[instance instanceId];
                        [instanceMenu addItem:subMenuItem];
                        
                        subMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Type: %@",[instance instanceType]] action:nil keyEquivalent:@""];
                        subMenuItem.representedObject=[instance instanceId];
                        [instanceMenu addItem:subMenuItem];
                        
                        subMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"State: %@", [[instance state] name ]] action:nil keyEquivalent:@""];
                        subMenuItem.representedObject=[instance instanceId];
                        [instanceMenu addItem:subMenuItem];
                        
                        [instanceMenu addItem:[NSMenuItem separatorItem]];

                        subMenuItem = [[NSMenuItem alloc] initWithTitle:@"Clipboard" action:nil keyEquivalent:@""];
                        [instanceMenu addItem:subMenuItem];
                        
                        subMenuItem = [[NSMenuItem alloc] initWithTitle:[instance privateDnsName] action:@selector(copy:) keyEquivalent:@""];
                        subMenuItem.representedObject=[instance privateDnsName];
                        [instanceMenu addItem:subMenuItem];
                        
                        subMenuItem = [[NSMenuItem alloc] initWithTitle:[instance privateIpAddress] action:@selector(copy:) keyEquivalent:@""];
                        subMenuItem.representedObject=[instance privateIpAddress];
                        [instanceMenu addItem:subMenuItem];
                        
                        if ([[instance publicDnsName] length]>0) {
                            subMenuItem = [[NSMenuItem alloc] initWithTitle:[instance publicDnsName] action:@selector(copy:) keyEquivalent:@""];
                            subMenuItem.representedObject=[instance publicDnsName];
                            [instanceMenu addItem:subMenuItem];
                        }
                        
                        if ([[instance publicIpAddress] length]>0) {
                            subMenuItem = [[NSMenuItem alloc] initWithTitle:[instance publicIpAddress] action:@selector(copy:) keyEquivalent:@""];
                            subMenuItem.representedObject=[instance publicIpAddress];
                            [instanceMenu addItem:subMenuItem];
                        }
                        
                        NSMenuItem* instanceMenuItem = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@"" ];
                        
                        if ([[[instance state] name] caseInsensitiveCompare:@"running"]!=NSOrderedSame) {
                            // [instanceMenuItem setAttributedTitle:[[NSAttributedString alloc] initWithHTML:[[NSString stringWithFormat:@"<span style='color: red;'>%@</span>", title] dataUsingEncoding:NSUTF8StringEncoding] baseURL:nil documentAttributes:nil]];
    //                        &#9679;
                        }
                        
                        [instanceMenu addItem:[NSMenuItem separatorItem]];
                        
                        subMenuItem = [[NSMenuItem alloc] initWithTitle:@"Actions" action:nil keyEquivalent:@""];
                        [instanceMenu addItem:subMenuItem];

                        subMenuItem = [[NSMenuItem alloc] initWithTitle:@"Connect" action:@selector(connect:) keyEquivalent:@""];
                        subMenuItem.representedObject=instance;
                        [instanceMenu addItem:subMenuItem];

                        subMenuItem = [[NSMenuItem alloc] initWithTitle:@"Browse" action:@selector(browse:) keyEquivalent:@""];
                        subMenuItem.representedObject=instance;
                        [instanceMenu addItem:subMenuItem];

                        NSDictionary* dict= [[NSDictionary alloc] initWithObjectsAndKeys: instance, @"instance", client, @"client", nil];

                        if ([[[instance state] name ] caseInsensitiveCompare:@"running"]==NSOrderedSame) {
                            subMenuItem = [[NSMenuItem alloc] initWithTitle:@"Stop" action:@selector(stop:) keyEquivalent:@""];
                            subMenuItem.representedObject=dict;
                            [instanceMenu addItem:subMenuItem];
                        } else {
                            subMenuItem = [[NSMenuItem alloc] initWithTitle:@"Start" action:@selector(start:) keyEquivalent:@""];
                            subMenuItem.representedObject=dict;
                            [instanceMenu addItem:subMenuItem];
                        }

                        subMenuItem = [[NSMenuItem alloc] initWithTitle:@"Reboot" action:@selector(reboot:) keyEquivalent:@""];
                        subMenuItem.representedObject=dict;
                        [instanceMenu addItem:subMenuItem];

                        subMenuItem = [[NSMenuItem alloc] initWithTitle:@"Console output" action:@selector(consoleOutput:) keyEquivalent:@""];
                        subMenuItem.representedObject=dict;
                        [instanceMenu addItem:subMenuItem];

                        [instanceMenuItem setSubmenu:instanceMenu];
                        
                        [instancesMenu addItem:instanceMenuItem];
                    }
                }
                
                [statusMenu addItem:instancesMenuItem];
            }
            @catch (AmazonClientException *exception) {
                NSLog(@"%@", exception);
                /*
                NSAlert *alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle:@"Close"];
                [alert setMessageText:[exception name]];
                [alert setInformativeText:[exception message]];
                [alert setAlertStyle:NSWarningAlertStyle];
                [alert runModal];
                 */
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }
        }
    } else {
        NSMenuItem* instancesMenuItem = [[NSMenuItem alloc] initWithTitle:@"No instances added yet" action:nil keyEquivalent:@"" ];
        [statusMenu addItem:instancesMenuItem];

    }
    
    [statusMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* refreshMenuItem = [[NSMenuItem alloc] initWithTitle:@"Refresh..." action:@selector(refresh:) keyEquivalent:@"" ];
    [statusMenu addItem:refreshMenuItem];
    
    NSMenuItem* preferencesMenuItem = [[NSMenuItem alloc] initWithTitle:@"Open Preferences..." action:@selector(preferences:) keyEquivalent:@"" ];
    [statusMenu addItem:preferencesMenuItem];

    [statusMenu addItem:[NSMenuItem separatorItem]];

    NSMenuItem* aboutMenuItem = [[NSMenuItem alloc] initWithTitle:@"About" action:@selector(about:) keyEquivalent:@"" ];
    [statusMenu addItem:aboutMenuItem];

    NSMenuItem* quitMenuItem = [[NSMenuItem alloc] initWithTitle:@"Quit StackTray" action:@selector(quit:) keyEquivalent:@"" ];
    [statusMenu addItem:quitMenuItem];

    [statusItem setMenu:statusMenu];
}

- (IBAction)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}

- (IBAction)preferences:(id)sender {
    PreferencesWindowController* preferencesWindowController = [PreferencesWindowController sharedPreferencesWindowController];
    [preferencesWindowController showWindow:self];
    
    //Focus on window
    [NSApp activateIgnoringOtherApps:YES];
    [[preferencesWindowController window] makeKeyAndOrderFront:nil];
}

- (IBAction)about:(id)sender {
    AboutWindowController* aboutWindowController = [AboutWindowController sharedAboutWindowController];
    [aboutWindowController showWindow:self];
    
    //Focus on window
    [NSApp activateIgnoringOtherApps:YES];
    [[aboutWindowController window] makeKeyAndOrderFront:nil];
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:__managedObjectContext];

    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"StackTray" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"StackTray.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (IBAction)copy:(id)sender {
    // EC2Instance
    
    NSMenuItem* menuItem= (NSMenuItem*)sender;

    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    NSArray *copiedObjects = [NSArray arrayWithObject:(NSString*)menuItem.representedObject];
    [pasteboard writeObjects:copiedObjects];
}


- (void)save:(id)sender {
    NSError* error;
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }

    // AppDelegate * appDelegate = (AppDelegate *) [[NSApplication sharedApplication] delegate];
    [self refresh];
}

- (void)managedObjectContextObjectsDidChange:(NSNotification *)notification;
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(save:) withObject:NULL afterDelay:0.2];
}

@end
