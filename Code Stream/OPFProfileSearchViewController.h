//
//  OPFProfileSearchViewController.h
//  Code Stream
//
//  Created by Tobias Deekens on 23.04.13.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OPFProfileSearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSArray *userModels;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
