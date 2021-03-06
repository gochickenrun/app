//
//  OPFActivityCommentViewCell.m
//  Code Stream
//
//  Created by Tobias Deekens on 05.05.13.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "OPFActivityCommentViewCell.h"
#import "OPFComment.h"
#import "OPFScoreNumberFormatter.h"

@interface OPFActivityCommentViewCell()

@property(nonatomic, strong) OPFScoreNumberFormatter *scoreFormatter;

- (void)opfSetupView;

@end

@implementation OPFActivityCommentViewCell

@synthesize commentModel = _commentModel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self opfSetupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self) {
        [self opfSetupView];
    }
    
    return self;
}

- (void)opfSetupView
{
     self.scoreFormatter = [OPFScoreNumberFormatter new];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCommentModel:(OPFComment *)commentModel
{
    self->_commentModel = commentModel;
    
    [self setModelValuesInView];
}

- (OPFComment *)commentModel
{
    return _commentModel;
}

- (void)setModelValuesInView
{
    self.commentBody.text = self.commentModel.text;
    self.scoreCount.text = [self.scoreFormatter stringFromScore:[self.commentModel.score integerValue]];
}

@end
