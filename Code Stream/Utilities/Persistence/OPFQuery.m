//
//  OPFQuery.m
//  Code Stream
//
//  Created by Jesper Josefsson on 2013-04-21.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "OPFQuery.h"
#import "OPFIsQuery.h"
#import "OPFInQuery.h"
#import "OPFLikeQuery.h"
#import "OPFRootQuery.h"

static NSString* defaultDB = @"baseDB";

@implementation OPFQuery

@synthesize rootQuery = _rootQuery;

- (FMResultSet*) getResultSetOne {
    [[self rootQuery] setLimit: @(1)];
    FMResultSet* result = [[OPFDatabaseAccess getDBAccess] executeSQL: [self.rootQuery toSQLString] withDatabase: self.dbName];
    return result;
}

- (FMResultSet*) getResultSetMany {
    FMResultSet* result = [[OPFDatabaseAccess getDBAccess] executeSQL: [self.rootQuery toSQLString] withDatabase: self.dbName];
    return result;
}

- (id) getOne
{
    if([self isKindOfClass: [OPFRootQuery class]]) {
        FMResultSet* result = [self getResultSetOne];
        if(self.onGetOne != nil && [result next]) {
            return self.onGetOne([result resultDictionary]);
        } else {
            return nil;
        }
    } else {
        return [self.rootQuery getOne];
    }
}

- (NSArray*) getMany
{
    if([self isKindOfClass: [OPFRootQuery class]]) {
        FMResultSet* result = [self getResultSetMany];
        if(self.onGetMany != nil) {
            return self.onGetMany(result);
        } else {
            return nil;
        }
    } else {
       return [self.rootQuery getMany];
    }
}

- (instancetype) whereColumn: (NSString*) column like: (id) term
{
    OPFLikeQuery* query = [OPFLikeQuery initWithColumn: column term: term rootQuery: self.rootQuery];
    self.andQuery = query;
    return query;
}

- (instancetype) whereColumn: (NSString*) column is: (id) term
{
    OPFIsQuery* query = [OPFIsQuery initWithColumn: column term: term rootQuery: self.rootQuery];
    self.andQuery = query;
    return query;
}

- (instancetype) whereColumn: (NSString*) column in: (id) terms{
    OPFInQuery* query = [OPFInQuery initWithColumn: column terms: terms rootQuery: self];
    self.andQuery = query;
    return query;
}

- (instancetype) andQuery: (OPFQuery*) otherQuery
{
    self.andQuery = otherQuery;
    otherQuery.rootQuery = self.rootQuery;
    return nil;
}

- (instancetype) orQuery: (OPFQuery*) otherQuery
{
    return nil;
}

- (void) setRootQuery:(OPFQuery *)rootQuery
{
    _rootQuery = rootQuery;
}

- (OPFQuery*) rootQuery
{
    if (_rootQuery != nil) {
        return _rootQuery;
    } else {
        return self;
    }
}

- (instancetype) limit: (NSNumber*) n
{
    [[self rootQuery] setLimit:n];
    return self;
}

- (NSString*) toSQLString
{
    if([self andQuery] != nil) {
        return [self sqlForAnd];
    } else {
        return [self baseSQL];
    }
}

- (NSString*) sqlForAnd
{
    NSMutableString* output = [NSMutableString stringWithString:@"("];
    [output appendString:[self baseSQL]];
    [output appendString:@" AND "];
    [output appendString:[[self andQuery] toSQLString]];
    [output appendString:@")"];
    return output;
}

# pragma mark - Factory methods

+ (instancetype) queryWithTableName: (NSString*) tableName
{
    id query = [[self alloc] init];
    [query setTableName: tableName];
    [query setDbName:defaultDB];
    return query;
}

+ (instancetype) queryWithTableName:(NSString *)tableName dbName:(NSString *)dbName
{
    id query = [self queryWithTableName:tableName];
    [query setDbName:dbName];
    return query;
}

+ (instancetype) queryWithTableName:(NSString *)tableName oneCallback:(OnGetOne)oneCallback manyCallback:(OnGetMany)manyCallback
{
    id query = [self queryWithTableName:tableName];
    [query setOnGetOne: oneCallback];
    [query setOnGetMany:manyCallback];
    return query;
}

+ (instancetype) queryWithTableName:(NSString *)tableName dbName:(NSString *)dbName oneCallback:(OnGetOne)oneCallback manyCallback:(OnGetMany)manyCallback
{
    id query = [self queryWithTableName:tableName oneCallback:oneCallback manyCallback:manyCallback];
    [query setDbName:dbName];
    return query;
}

// Subclasses must override this
- (NSString*) sqlConcat:(NSString *)sqlString
{
    return nil;
}

@synthesize dbName = _dbName;

- (NSString* ) dbName
{
    if ([self isKindOfClass:[OPFRootQuery class]]) {
        return _dbName;
    } else {
        return self.rootQuery.dbName;
    }
}

- (void) setDbName:(NSString *)dbName
{
    if (_dbName != dbName) {
        _dbName = dbName;
    }
}

@end
