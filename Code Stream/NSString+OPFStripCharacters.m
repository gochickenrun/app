//
//  NSString+OPFStripCharacters.m
//  Code Stream
//
//  Created by Aron Cedercrantz on 23-04-2013.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "NSString+OPFStripCharacters.h"

@implementation NSString (OPFStripCharacters)

- (NSString *)opf_stringByTrimmingWhitespace
{
	return [self stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}

@end