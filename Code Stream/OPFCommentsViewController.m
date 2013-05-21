//
//  OPFCommentViewController.m
//  Code Stream
//
//  Created by Tobias Deekens on 16.04.13.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "OPFCommentsViewController.h"
#import "OPFCommentViewCell.h"
#import "OPFCommentViewHeaderView.h"
#import "UIView+AnimationOptionsForCurve.h"
#import "OPFPost.h"
#import "OPFComment.h"
#import "OPFUserProfileViewController.h"
#import "OPFAppState.h"
#import "OPFUpdateQuery.h"
#import "OPFUser.h"
#import "UIFont+OPFAppFonts.h"
#import "OPFAppState.h"
#import "NSString+OPFStripCharacters.h"
#import "NSString+OPFEscapeStrings.h"
#import "NSDateFormatter+OPFDateFormatters.h"
#import "OPFBarGradientView.h"
#import "OPFDBInsertionIdentifier.h"

#define INPUT_HEIGHT 44.0f

@interface OPFCommentsViewController ()

@property(nonatomic, strong) NSArray *commentModels;

- (void)opfSetupView;
- (OPFComment *)commentForIndexPath:(NSIndexPath *)indexPath;

@end

@implementation OPFCommentsViewController

@synthesize delegate;
static NSString *const OPFCommentTableCell = @"OPFCommentTableCell";
static NSString *const OPFCommentTableHeader = @"OPFCommentTableHeader";
static CGFloat const OPFCommentTableCellOffset = 60.0f;

- (id)init
{
    self = [super initWithNibName:@"OPFCommentsViewTable" bundle:nil];

    if(self) {
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
    self.title = NSLocalizedString(@"Comments", @"Comments view controller title");
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:CDStringFromClass(OPFCommentViewHeaderView) bundle:nil] forHeaderFooterViewReuseIdentifier:OPFCommentTableHeader];
    [self.tableView registerNib:[UINib nibWithNibName:CDStringFromClass(OPFCommentViewCell) bundle:nil] forCellReuseIdentifier:OPFCommentTableCell];

	self.inputView.shouldDrawBottomBorder = NO;
}

- (void)setPostModel:(OPFPost *)postModel
{
    _postModel = postModel;

    [self performInitialDatabaseFetch];

    [self.tableView reloadData];
}

- (OPFPost *)commentForIndexPath:(NSIndexPath *)indexPath
{
    return self.commentModels[indexPath.row];
}

- (void)commentSavePressed:(UIButton *)sender
{
    // Comment is inserted into db and view is updated
    // I will change how the OPFUpdateQuery works, so some things are going to be changed here
    if(![self.inputTextField.text isEqualToString:@""]){
       //[OPFUpdateQuery updateWithCommentText:self.inputTextField.text PostID:[self.postModel.identifier integerValue] ByUser:[OPFAppState.sharedAppState.user.identifier integerValue]];

        
        // Current date
        NSString *date = [NSDateFormatter opf_currentDateAsStringWithDateFormat:@"yyyy-MM-dd"];
        
        int id = [OPFDBInsertionIdentifier getNextCommentId];
        
        // Query to the SO db
        NSArray* args = @[@(id), @([self.postModel.identifier integerValue]), @0, self.inputTextField.text, date, @([OPFAppState.sharedAppState.user.identifier integerValue])];
        NSArray* col = @[@"id", @"post_id", @"score", @"text", @"creation_date", @"user_id"];
        
        
        [OPFUpdateQuery insertInto:@"comments" forColumns:col values:args auxiliaryDB:NO];

        
        __strong OPFPost *post = [[[OPFPost query] whereColumn:@"id" is:self.postModel.identifier] getOne];
        self.postModel=post;

        [self.inputTextField setText:nil];
        [self.inputTextField resignFirstResponder];
        [self scrollToBottomAnimated:YES];
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)performInitialDatabaseFetch
{
    self.commentModels = self.postModel.comments;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Returning 1 because we only display one post's comments
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commentModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OPFCommentViewCell *cell = (OPFCommentViewCell *)[tableView dequeueReusableCellWithIdentifier:OPFCommentTableCell forIndexPath:indexPath];

    [cell configureForComment:[self.commentModels objectAtIndex:indexPath.row]];
    
    
    // Check if user alreade have voted on a comment
    __block int voteNum = kOPFPostUserVoteStateNone;
    if (OPFAppState.sharedAppState.isLoggedIn) {
        [[[OPFDatabaseAccess getDBAccess] combinedQueue] inDatabase:^(FMDatabase* db){
            FMResultSet *result = [db executeQuery:@"SELECT * FROM 'auxDB'.'comments_votes' WHERE 'comments_votes'.'user_id' = ? AND 'comments_votes'.'comment_id' = ?" withArgumentsInArray:@[ OPFAppState.sharedAppState.user.identifier, cell.commentModel.identifier]];
            [result next];
            voteNum = [result intForColumn:@"user_id"];
        }];
    }
    
    // Set the state of the comment
    cell.commentVoteUp.selected = voteNum != kOPFPostUserVoteStateNone;
    cell.commentVoteUp.enabled = OPFAppState.sharedAppState.isLoggedIn;
    
    
    cell.commentsViewController = self;

    return cell;
}

- (void)voteUpComment:(OPFCommentVoteButton *)sender
{
    [self updateVoteWithUserID:[OPFAppState.sharedAppState.user.identifier integerValue] comment:sender];
    
    [self.delegate commentsViewController:self didUpvoteComment:sender.comment];
}

- (void)didSelectDisplayName:(UIButton *)sender :(OPFUser *)userModel
{
	OPFUserProfileViewController *userProfileViewController = OPFUserProfileViewController.newFromStoryboard;
    userProfileViewController.user = userModel;

    [self.navigationController pushViewController:userProfileViewController animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = nil;

    OPFCommentViewHeaderView *commentHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:OPFCommentTableHeader];

    [commentHeaderView configureForPost:self.postModel];

    headerView = commentHeaderView;

	return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	OPFComment *commentModel = [self.commentModels objectAtIndex:indexPath.row];

    NSString *text = [commentModel.text.opf_stringByStrippingHTML.opf_stringByTrimmingWhitespace OPF_escapeWithScheme:OPFStripAscii];

    CGSize textSize = [text sizeWithFont:[UIFont opf_appFontOfSize:14.0f] constrainedToSize:CGSizeMake(250.f, 1000.f) lineBreakMode:NSLineBreakByWordWrapping];

    return textSize.height + OPFCommentTableCellOffset;
}

- (void)viewWillAppear:(BOOL)animated
{
    if(OPFAppState.sharedAppState.isLoggedIn){
        self.inputTextField.enabled=YES;
        self.inputSendButton.enabled=YES;
    }
    else{
        self.inputTextField.enabled=NO;
        self.inputSendButton.enabled=NO;
    }

    [self scrollToBottomAnimated:NO];

	[[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(handleWillShowKeyboard:)
		name:UIKeyboardWillShowNotification
        object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(handleWillHideKeyboard:)
		name:UIKeyboardWillHideNotification
        object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Keyboard notifications
- (void)handleWillShowKeyboard:(NSNotification *)notification
{
    [self keyboardWillShowHide:notification];
}

- (void)handleWillHideKeyboard:(NSNotification *)notification
{
    [self keyboardWillShowHide:notification];
}

- (void)keyboardWillShowHide:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
	double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    [UIView animateWithDuration:duration delay:0.0f options:[UIView animationOptionsForCurve:curve]
        animations:^{
            CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;

            CGRect inputViewFrame = self.inputView.frame;
            CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;

            // for ipad modal form presentations
            CGFloat messageViewFrameBottom = self.view.frame.size.height - INPUT_HEIGHT;
            if(inputViewFrameY > messageViewFrameBottom)
                inputViewFrameY = messageViewFrameBottom;

            self.inputView.frame = CGRectMake(inputViewFrame.origin.x, inputViewFrameY, inputViewFrame.size.width, inputViewFrame.size.height);

            UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 0.0f, self.view.frame.size.height - self.inputView.frame.origin.y - INPUT_HEIGHT, 0.0f);

            self.tableView.contentInset = insets;
            self.tableView.scrollIndicatorInsets = insets;
        }
        completion:^(BOOL finished) {
        }];
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger rows = [self.tableView numberOfRowsInSection:0];

    if(rows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                        atScrollPosition:UITableViewScrollPositionBottom
                        animated:animated];
    }
}

- (BOOL) updateVoteWithUserID:(NSInteger)userID comment: (OPFCommentVoteButton *) comment
{
    BOOL auxSucceeded = NO;
    BOOL succeeded = NO;
    
	NSInteger totalVotes = [[OPFComment find:[comment.comment.identifier integerValue]].score integerValue];
	
    NSNumber *n = comment.comment.author.identifier;
    NSNumber *user = OPFAppState.sharedAppState.user.identifier;
    
    if(comment.isSelected && comment.comment.author.identifier!=OPFAppState.sharedAppState.user.identifier){
        NSArray *args = @[ @(totalVotes-1), comment.comment.identifier ];
        NSString *query = [NSString stringWithFormat:@"UPDATE comments SET score=? WHERE id=?;"];
        succeeded = [[OPFDatabaseAccess getDBAccess] executeUpdate:query withArgumentsInArray:args auxiliaryUpdate:NO];
        
        args = @[OPFAppState.sharedAppState.user.identifier, comment.comment.identifier ];
		NSString *auxQuery = @"DELETE FROM comments_votes WHERE 'comments_votes'.'user_id' = ? AND 'comments_votes'.'comment_id' = ?;";
		auxSucceeded = [[OPFDatabaseAccess getDBAccess] executeUpdate:auxQuery withArgumentsInArray:args auxiliaryUpdate:YES];
        comment.selected = !(succeeded && auxSucceeded);
    }
    else if(!comment.isSelected && [comment.comment.author.identifier integerValue]!=[OPFAppState.sharedAppState.user.identifier integerValue]){
        NSArray *args = @[ @(totalVotes+1), comment.comment.identifier ];
        NSString *query = [NSString stringWithFormat:@"UPDATE comments SET score=? WHERE id=?;"];
        succeeded = [[OPFDatabaseAccess getDBAccess] executeUpdate:query withArgumentsInArray:args auxiliaryUpdate:NO];
        
        args = @[ OPFAppState.sharedAppState.user.identifier, comment.comment.identifier];
        NSArray* col = @[@"user_id",@"comment_id"];
        auxSucceeded = [OPFUpdateQuery insertInto:@"comments_votes" forColumns:col values:args auxiliaryDB:YES];
        comment.selected=YES;
    }
    OPFPost *post = [OPFPost find:[self.postModel.identifier integerValue]];
    [self setPostModel:post];
    
    return succeeded && auxSucceeded;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self commentSavePressed:self.inputSendButton];

    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

@end
