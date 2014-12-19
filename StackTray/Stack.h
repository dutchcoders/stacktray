//
//  Stack.h
//  StackTray
//
//  Created by Remco on 01/05/14.
//  Copyright (c) 2014 DutchCoders. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Stack : NSManagedObject

@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSString * secretKey;
@property (nonatomic, retain) NSString * accessKey;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * pemFileLocation;

@end
