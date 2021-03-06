//
//  OPFSingleQuestionPreviewCell.h
//  Code Stream
//
//  Created by Martin Goth on 2013-04-18.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPFQuestion.h"
#import "OPFScoreNumberFormatter.h"

@class OPFUserPreviewButton;

@class OPFSingleQuestionPreviewCell;
@protocol OPFSingleQuestionPreviewCellDelegate <NSObject>
@optional
- (void)singleQuestionPreviewCell:(OPFSingleQuestionPreviewCell *)cell didSelectTag:(NSString *)tag;

@end


@interface OPFSingleQuestionPreviewCell : UITableViewCell

@property (weak) id<OPFSingleQuestionPreviewCellDelegate> delegate;

// Public: Configure a preview cell with question data
//
// question - The data model that should be represented by the preview cell
- (void) configureWithQuestionData:(OPFQuestion *)question;

// IBOutlet properties linked to SingleQuestionPreviewCell.xib
@property (weak, nonatomic) IBOutlet UILabel *questionTextLabel;
//@property (weak, nonatomic) IBOutlet UITextView *questionTextView;

@property (weak, nonatomic) IBOutlet UIImageView *metadataBackgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *answersLabel;
@property (weak, nonatomic) IBOutlet UIImageView *answersIndicatorImageView;

@end
