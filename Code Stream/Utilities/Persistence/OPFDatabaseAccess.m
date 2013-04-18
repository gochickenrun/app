//
//  DatabaseAccess.m
//  Code Stream
//
//  Created by Jesper Josefsson on 2013-04-16.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "OPFDatabaseAccess.h"

@implementation OPFDatabaseAccess

//
//  Returns the singleton database instance
+ (instancetype) getDBAccess;
{
	static id _sharedDatabase = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedDatabase = [[self alloc] init];
	});
	return _sharedDatabase;
}

//
//  Inits with the preinstalled database.
- (id) init {
    self = [super init];
    if (self == nil) return nil;
    _baseDB = [FMDatabase databaseWithPath:[[NSBundle mainBundle] pathForResource:@"so" ofType:@"sqlite"]];
    return self;
}

- (FMResultSet *) executeSQL:(NSString *)sql
{
    FMResultSet* result;
    if([_baseDB open]) {
        result = [_baseDB executeQuery:sql];
    }
    return result;
}

@end
