//
//  OPFQuestionSpec.m
//  Code Stream
//
//  Created by Jesper Josefsson on 2013-04-23.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "Specta.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "OPFModelSpecHelper.h"
#import "OPFQuestion.h"
#import "OPFAnswer.h"

SpecBegin(OPFQuestion)

describe(@"Fetching", ^{
    __block OPFQuestion* question;
    
    beforeEach(^{
        question = [[[OPFQuestion query] whereColumn:@"id" is:@(8414075)] getOne];
    });
    it(@"should not fetch an incorrect type of model", ^{
        question = [[[OPFQuestion query] whereColumn: @"id" is: @"8474693"] getOne];
        expect(question).to.beNil();
    });
    
    it(@"should fetch an object of the correct type", ^{
        expect(question).to.beKindOf([OPFQuestion class]);
    });
    
    it(@"should be possible to get the accepted answer", ^{
        expect(question.acceptedAnswer).to.beKindOf([OPFAnswer class]);
    });
    
    it(@"should be possible to get all answers", ^{
        NSArray* answers = question.answers;
        expect([answers count]).to.equal(2);
        for(id answer in answers) {
            expect(answer).to.beKindOf([OPFAnswer class]);
        }
    });
    
});

SpecEnd