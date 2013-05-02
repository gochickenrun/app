//
//  OPFAppState.m
//  Code Stream
//
//  Created by Tobias Deekens on 30.04.13.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "OPFAppState.h"
#import "OPFUser.h"

@implementation OPFAppState

static OPFUser *userModel;

+ (OPFUser *)userModel
{
    //self.userModel = [[[OPFUser query] whereColumn:@"id" is:@"797"] getOne];
    
    //To lazy to cache the response here
    return userModel;
}

+ (void)setUserModel:(OPFUser *)userModel
{
    self.userModel = userModel;
}

+ (BOOL)login:(NSString *)displayName
{
    OPFUser *loggedInUserModel = [[[OPFUser query] whereColumn:@"display_name" is:displayName] getOne];
    
    if (userModel) {
        userModel = loggedInUserModel;
        
        return YES;
    }
    
    return NO;
}

+ (BOOL)isLoggedIn
{
    return userModel != nil ? true : false;
}

@end