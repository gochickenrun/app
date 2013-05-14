//
//  OPFPostQuestionViewController.h
//  Code Stream
//
//  Created by Marcus Johansson on 2013-05-08.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPFQuestion.h"

@interface OPFPostQuestionViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *bodyField;
@property (weak, nonatomic) IBOutlet UITextField *tagsField;
@property (weak, nonatomic) IBOutlet UILabel *titleWarning;
@property (weak, nonatomic) IBOutlet UILabel *bodyTextWarning;
@property (weak, nonatomic) IBOutlet UILabel *generalWarningLabel;
@end
