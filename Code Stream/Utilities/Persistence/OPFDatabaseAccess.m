//
//  DatabaseAccess.m
//  Code Stream
//
//  Created by Jesper Josefsson on 2013-04-16.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "OPFDatabaseAccess.h"

static NSString* OPFDefaultDBFilename = @"so.sqlite";
static NSString* OPFAuxDBFilename = @"auxiliary.sqlite";
static NSString* OPFWritableBaseDBPath;
static NSString* OPFWritableAuxDBPath;

@interface OPFDatabaseAccess(/*private*/)
+ (void) copyDatabaseIfNeeded;
@end

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

+ (void) setDBPaths
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    OPFWritableBaseDBPath = [documentsDirectory stringByAppendingPathComponent: OPFDefaultDBFilename];
    OPFWritableAuxDBPath = [documentsDirectory stringByAppendingPathComponent: OPFAuxDBFilename];
}

+ (void) copyDatabaseIfNeeded
{
    // First, test for existence.
    BOOL successBase;
    BOOL successAux;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    successBase = [fileManager fileExistsAtPath: OPFWritableBaseDBPath];
    successAux = [fileManager fileExistsAtPath:OPFWritableAuxDBPath];
    if (!successBase) {
        NSString* defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:OPFDefaultDBFilename];
        successBase = [fileManager copyItemAtPath:defaultDBPath toPath: OPFWritableBaseDBPath error: &error];
    }
    if (!successAux) {
        NSString* auxDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:OPFAuxDBFilename];
        successAux = [fileManager copyItemAtPath:auxDBPath toPath: OPFWritableAuxDBPath error: &error];
    }
    if(!successBase) {
        NSLog(@"Failed to copy base db to documents directory");
    }
    if(!successAux) {
        NSLog(@"Failed to copy aux db to documents directory");
    }
}

//
//  Inits with the preinstalled database.
- (id) init {
    self = [super init];
    if (self == nil) return nil;
    _auxAttached = NO;
    [OPFDatabaseAccess setDBPaths];
    [OPFDatabaseAccess copyDatabaseIfNeeded];
    _combinedQueue = [FMDatabaseQueue databaseQueueWithPath:OPFWritableBaseDBPath];
    [self attachAuxDB];
    return self;
}

//
// Executes an SQL string and returns the result.
// Returns nil if result is empty.
// Returns nil if db is unavailable.
- (FMResultSet *) executeSQL:(NSString *)sql
{
    [self attachAuxDB];
    __block FMResultSet* result;
    [_combinedQueue inDatabase: ^(FMDatabase* db) {
        NSLog(@"Executing query %@", sql);
        result = [db executeQuery:sql];
    }];
    return result;
}

-(void) attachAuxDB
{
    if (!self.auxAttached) {
        [_combinedQueue inDatabase:^(FMDatabase* db){
            BOOL result = [db executeUpdate:@"ATTACH DATABASE ? AS 'auxDB'" withArgumentsInArray:@[OPFWritableAuxDBPath]];
            if (result) {
                NSLog(@"Successfully attached aux db");
                self.auxAttached = YES;
            } else {
                NSLog(@"Failed to attach aux db");
                self.auxAttached = NO;
            }
        }];
    }
}

-(void) close
{
    self.auxAttached = NO;
    [_combinedQueue close];
}

@end
