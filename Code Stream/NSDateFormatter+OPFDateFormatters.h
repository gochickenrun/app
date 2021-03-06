//
//  NSDateFormatter+OPFDateFormatters.h
//  Code Stream
//
//  Created by Aron Cedercrantz on 20-05-2013.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (OPFDateFormatters)

+ (instancetype)opf_dateFormatterWithFormat:(NSString *)format;

+ (NSString *)opf_currentDateAsStringWithDateFormat:(NSString *)format;

@end
