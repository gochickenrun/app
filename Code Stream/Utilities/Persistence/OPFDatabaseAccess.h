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


#define OPF_DATABASE_ACCESS_DEBUG ((DEBUG && 1) == 1)


@class OPFDatabaseQueue;

@interface OPFDatabaseAccess : NSObject

+ (instancetype) getDBAccess;

- (FMResultSet *) executeSQL: (NSString *) sql;
- (BOOL) executeUpdate:(NSString *) sql withArgumentsInArray:(NSArray *)arguments auxiliaryUpdate: (BOOL) auxUpdate;
- (void) attachAuxDB;
- (void) close;
- (int) lastInsertRowId;

@property(strong, readonly) OPFDatabaseQueue* combinedQueue;
@property(strong, readonly) OPFDatabaseQueue* auxCombinedQueue;
@property(assign) BOOL auxAttached;


@end

@interface OPFDatabaseQueue : FMDatabaseQueue
@property (strong, readonly) dispatch_queue_t queue;
@end
