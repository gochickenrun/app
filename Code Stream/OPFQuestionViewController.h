//
//  OPFQuestionViewController.h
//  Code Stream
//
//  Created by Aron Cedercrantz on 16-04-2013.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPFUserPreviewButton.h"
#import "GCTagList.h"
#import "OPFPostAnswerViewController.h"

@class OPFPost;
@class OPFQuestion;

@interface OPFQuestionViewController : UITableViewController <GCTagListDelegate, UIWebViewDelegate, PostAnswerDelegate>

@property (strong) OPFQuestion *question;

@end
