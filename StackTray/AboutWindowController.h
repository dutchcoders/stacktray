//
//  AboutWindowController.h
//  StackTray
//
//  Created by Remco on 01/06/14.
//  Copyright (c) 2014 DutchCoders. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

@interface AboutWindowController : NSWindowController {
}

+ (AboutWindowController *)sharedAboutWindowController;
+ (NSString *)nibName;

@end
