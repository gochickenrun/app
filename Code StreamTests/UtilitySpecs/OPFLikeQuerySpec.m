//
//  OPFLikeQuerySpec.m
//  Code Stream
//
//  Created by Jesper Josefsson on 2013-04-22.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "Specta.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "OPFLikeQuery.h"
#import "OPFRootQuery.h"
#import "OPFComment.h"


SpecBegin(OPFLikeQuery)

describe(@"fetching and SQL-strings", ^{
    __block OPFRootQuery* rootQuery;
    __block id likeQuery;
    __block FMResultSet* result;
    
    before(^{
        rootQuery = [OPFComment query];
        likeQuery = [rootQuery whereColumn:@"text" like: @"CSS"];
    });
    
    it(@"returns the correct amount of objects for the given query", ^{
        result = [likeQuery getResultSetMany];
        int i = 0;
        while([result next]) {
            i++;
        }
        expect(i).to.equal(140);
    });
    
    it(@"returns the correct amount of objects for an exact query", ^{
        [likeQuery setExact: YES];
        NSArray* result = [likeQuery getMany];
        expect(result.count).to.equal(@(0));
        
    });
    
    afterEach(^{
        if(result != nil) {
            [result close];
        }
    });
});

SpecEnd
