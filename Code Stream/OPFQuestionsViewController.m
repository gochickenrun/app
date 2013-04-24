//
//  OPFQuestionsViewController.m
//  Code Stream
//
//  Created by Martin Goth on 2013-04-18.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "OPFQuestionsViewController.h"
#import "OPFSingleQuestionPreviewCell.h"
#import "OPFQuestion+Mockup.h"

@interface OPFQuestionsViewController ()

@end

@implementation OPFQuestionsViewController

static NSString *const QuestionCellIdentifier = @"QuestionCell";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
	for (int i = 0; i < 10; i++) {
		[array addObject:[OPFQuestion generatePlaceholderQuestion]];
	}
	
	self.questions = array;
	
	[self.tableView registerNib:[UINib nibWithNibName:@"SingleQuestionPreviewCell" bundle:nil] forCellReuseIdentifier:QuestionCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.questions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OPFSingleQuestionPreviewCell *cell = [tableView dequeueReusableCellWithIdentifier:QuestionCellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
	[cell configureWithQuestionData:self.questions[[indexPath indexAtPosition:indexPath.length-1]]];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 150;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
