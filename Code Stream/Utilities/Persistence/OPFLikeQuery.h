//
//  OPFLikeQuery.h
//  Code Stream
//
//  Created by Jesper Josefsson on 2013-04-22.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "OPFQuery.h"

// Represents an SQL LIKE-query
@interface OPFLikeQuery : OPFQuery

// The search term
@property (copy) id term;
@property (assign) BOOL exact;

+ (instancetype) initWithColumn: (NSString *) column term: (id) term rootQuery: (OPFQuery *) otherQuery;
+ (instancetype) initWithColumn: (NSString *) column term: (id) term rootQuery: (OPFQuery *) otherQuery exact: (BOOL) exact;

@end
