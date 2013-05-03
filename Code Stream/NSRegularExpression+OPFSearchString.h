//
//  NSRegularExpression+OPFSearchString.h
//  Code Stream
//
//  Created by Aron Cedercrantz on 02-05-2013.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSRegularExpression (OPFSearchString)

+ (NSRegularExpression *)opf_tagsFromSearchStringRegularExpression;
+ (NSRegularExpression *)opf_usersFromSearchStringRegularExpression;
+ (NSRegularExpression *)opf_nonKeywordsFromSearchStringRegularExpression;

@end
