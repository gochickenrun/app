//
//  OPFProfileViewCell.m
//  Code Stream
//
//  Created by Tobias Deekens on 23.04.13.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "OPFProfileViewCell.h"

@implementation OPFProfileViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModelValuesInView
{
    //    self.commentBody.text = self.commentModel.commentBody;
    //    self.commentDate.text = [self.dateFormatter stringFromDate:self.commentModel.lastEditDate];
    //    self.commentTime.text = [self.timeFormatter stringFromDate:self.commentModel.lastEditDate];
    //    self.commentVoteUp.titleLabel.text = [@(self.commentModel.score) stringValue];
    //    self.commentUserName.text = self.commentModel.userName;
    //    self.userAvatar.text = self.commentModel.userAvatar;
}

- (void)setupDateformatters
{
    self.dateFormatter = [NSDateFormatter new];
    
    [self.dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
}
@end
