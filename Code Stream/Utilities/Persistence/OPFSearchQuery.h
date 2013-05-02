//
//  OPFSearchQuery.h
//  Code Stream
//
//  Created by Jesper Josefsson on 2013-05-02.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "OPFRootQuery.h"

@interface OPFSearchQuery : OPFRootQuery

@property (strong) NSString* indexTableName;
@property (strong) NSString* searchTerms;

+ (instancetype) searchQueryWithTableName:(NSString *)tableName
                                   dbName: (NSString *) dbName
                              oneCallback: (OnGetOne) oneCallback
                             manyCallback: (OnGetMany) manyCallback
                                 pageSize: (NSNumber*)pageSize
                           indexTableName: (NSString*) indexTableName
                               searchTerm: (NSString*) searchTerm;

@end
