//
//  OPFQuestionsViewController.h
//  Code Stream
//
//  Created by Martin Goth on 2013-04-18.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPFSingleQuestionPreviewCell.h"

@interface OPFQuestionsViewController : UITableViewController <UISearchBarDelegate, OPFSingleQuestionPreviewCellDelegate>

@property (copy) NSString *searchString;

@end
