//
//  OPFQuestionsViewController.h
//  Code Stream
//
//  Created by Martin Goth on 2013-04-18.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OPFQuestionsViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (copy, nonatomic) NSString *searchString;

@end
