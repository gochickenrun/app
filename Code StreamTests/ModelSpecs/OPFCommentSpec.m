//
//  OPFCommentSpec.m
//  Code Stream
//
//  Created by Jesper Josefsson on 2013-04-18.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "Specta.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "OPFComment.h"

SpecBegin(OPFComment)

describe(@"Model creation", ^{
    __block OPFComment* comment;
    __block NSDictionary* properties = @{@"score": @(9), @"text": @"lorem ipsum", @"creationDate": [NSDate date]};
    __block NSString* commentBody = @"a minute later doesn't make you any less right.";
    
    it(@"should be possible using a dictionary", ^{
        NSError* error;
        comment = [[OPFComment alloc] initWithDictionary: properties error: &error];
        expect(comment).toNot.equal(nil);
        expect(comment.score).to.equal(@(9));
        expect(comment.text).to.equal(properties[@"text"]);
        expect(comment.creationDate).to.equal(properties[@"creationDate"]);
    });
    
    it(@"should be possible using the database", ^{
        OPFComment* comment = [OPFComment find: 8894930];
        expect(comment).toNot.equal(nil);
        expect(comment.text).to.equal(commentBody);
        expect(comment.authorId).to.equal(@(378133));
    });
});

describe(@"Pagination", ^{
    it(@"should paginate by ten by default", ^{
        NSArray* result = [OPFComment all:0];
        expect([result count]).to.equal([OPFModel defaultPageSize]);
        expect([[result objectAtIndex:0] identifier]).to.equal(@(8894930));
    });
    
    it(@"should support arbitrary pagination", ^{
        NSArray* result = [OPFComment all:0 per: 500];
        expect([result count]).to.equal(500);
    });
});

describe(@"relations", ^{
    __block OPFComment* comment;
    
    beforeEach(^{
        comment = [[[OPFComment query] whereColumn:@"id" is:@(10405390)] getOne];
    });
    
    it(@"should fetch related objects when needed",  ^{
        expect(comment.author).to.beKindOf([OPFUser class]);
        expect(comment.post).to.beKindOf([OPFPost class]);
    });
});

describe(@"ordering", ^{
    it(@"should be possible to order by a column DESC", ^{
        NSArray* comments = [[[[OPFComment query] orderBy:@"score" order:kOPFSortOrderDescending] page: 0] getMany];
        expect([[comments objectAtIndex: 0] score]).to.equal(@(33));
        expect([[comments objectAtIndex:9] score]).to.equal(@(10));
        expect([[comments objectAtIndex:1] identifier]).to.equal(@(10400555));
    });
    it(@"should be possible to order by a column ASC", ^{
        NSArray* comments = [[[[OPFComment query] orderBy:@"score" order:kOPFSortOrderAscending] page: 0] getMany];
        expect([[comments objectAtIndex: 0] identifier]).to.equal(@(10405390));
        expect([[comments objectAtIndex:9] identifier]).to.equal(@(10412549));
    });
    
    it(@"should be possible to order by date", ^{
        NSArray* comments = [[[[OPFComment query] orderBy:@"creation_date" order:kOPFSortOrderAscending] page: 0] getMany];
        expect([[comments objectAtIndex: 0] identifier]).to.equal(@(213900));
        expect([[comments objectAtIndex:9] identifier]).to.equal(@(10394260));
    });
});

SpecEnd