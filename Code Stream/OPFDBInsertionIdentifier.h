//
//  OPFDBInsertionIdentifier.h
//  Code Stream
//
//  Created by Marcus Johansson on 2013-05-19.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPFDBInsertionIdentifier : NSObject
+(int) getNextPostId;

+(int) getNextUserId;

+(int) getNextCommentId;

@end
