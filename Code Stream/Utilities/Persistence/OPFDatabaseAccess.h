//
//  DatabaseAccess.h
//  Code Stream
//
//  Created by Jesper Josefsson on 2013-04-16.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface OPFDatabaseAccess : NSObject

+ (instancetype) getDBAccess;

- (FMResultSet *) executeSQL: (NSString *) sql;
- (void) close;

@property(strong, readonly) FMDatabase* baseDB;
@property(strong, readonly) FMDatabaseQueue* baseDBQueue;

@end
