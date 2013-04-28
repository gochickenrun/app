//
//  OPFProfileViewCell.h
//  Code Stream
//
//  Created by Tobias Deekens on 23.04.13.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OPFProfileSearchViewController, OPFUser, AGMedallionView;

@interface OPFProfileViewCell : UITableViewCell

@property(nonatomic, weak) OPFProfileSearchViewController *profilesViewController;

@property(nonatomic, strong) OPFUser *userModel;

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet AGMedallionView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *userLocation;
@property (weak, nonatomic) IBOutlet UILabel *userWebsite;
@property (weak, nonatomic) IBOutlet UILabel *userReputation;
@property (weak, nonatomic) IBOutlet UILabel *userVotesUp;
@property (weak, nonatomic) IBOutlet UILabel *userVotesDown;

- (void)setModelValuesInView;
- (void)setupFormatters;

@end
