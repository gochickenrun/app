//
//  OPFQuestionViewController.m
//  Code Stream
//
//  Created by Aron Cedercrantz on 16-04-2013.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "OPFQuestionViewController.h"
#import "OPFPostBodyTableViewCell.h"
#import "OPFPostMetadataTableViewCell.h"
#import "OPFPostTagsTableViewCell.h"
#import "OPFQuestionHeaderView.h"
#import "NSCache+OPFSubscripting.h"
#import "OPFTag.h"
#import "OPFPost.h"
#import "OPFQuestion.h"
#import "OPFComment.h"
#import "OPFCommentsViewController.h"
#import "OPFScoreNumberFormatter.h"
#import "UIImageView+KHGravatar.h"
#import "UIImageView+AFNetworking.h"
#import "OPFUserPreviewButton.h"
#import "OPFUserProfileViewController.h"
#import "OPFQuestionsViewController.h"
#import "NSString+OPFEscapeStrings.h"
#import "UIWebView+OPFHtmlView.h"
#import "OPFWebViewController.h"
#import "OPFPostAnswerViewController.h"
#import "OPFQuestionAnswerSeparatorCell.h"
#import "NSString+OPFSearchString.h"
#import "OPFUpdateQuery.h"
#import "OPFAppState.h"
#import "OPFDatabaseAccess.h"


enum {
	kOPFQuestionBodyCell = 0,
	kOPFQuestionMetadataCell = 1,
	kOPFQuestionTagsCell = 2,
	kOPFQuestionCommentsWithTagsCell = 3,
	kOPFQuestionCommentsWithoutTagsCell = 2,
	kOPFQuestionAnswerSeparatorWithTagsCell = 4,
	kOPFQuestionAnswerSeparatorWithoutTagsCell = 3,
};

static const NSInteger kOPFQuestionSection = 0;
static const CGFloat kOPFQuestionSectionHeight = 44.f;
static const CGFloat kOPFAnswerSeparatorHeight = 22.f;

static const CGFloat kOPFQuestionBodyInset = 20.f;

static const NSInteger kOPFRowsInQuestionSection = 5;
static const NSInteger kOPFRowsInAnswerSection = 4;


@interface OPFQuestionViewController ()
@property (strong) NSMutableArray *rowHeights;
@property (strong, readonly) NSCache *cache;
// TEMP (start):
@property (strong) NSMutableArray *posts;
- (OPFPost *)questionPost;
- (NSArray *)answerPosts;
// TEMP (end)
@end

@implementation OPFQuestionViewController

#pragma mark - Reuse Identifiers
static NSString *const BodyCellIdentifier = @"PostBodyCell";
static NSString *const MetadataCellIdentifier = @"PostMetadataCell";
static NSString *const TagsCellIdentifier = @"PostTagsCell";
static NSString *const CommentsCellIdentifier = @"PostCommentsCell";
static NSString *const AnswerSeparatorCellIdentifier = @"AnswerSeparatorCellIdentifier";

static NSString *const QuestionHeaderViewIdentifier = @"QuestionHeaderView";

#pragma mark - Object Lifecycle
- (void)questionViewControllerSharedInit
{
	_posts = [[NSMutableArray alloc] init];
}

- (id)init
{
	self = [super init];
	if (self) {
		[self questionViewControllerSharedInit];
	}
	return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if (self) {
		[self questionViewControllerSharedInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self questionViewControllerSharedInit];
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		[self questionViewControllerSharedInit];
	}
	return self;
}

#pragma mark - WebViewDelegate
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
	
	if (![self.rowHeights[webView.tag] isEqual: @5])
		return;
	
	NSNumberFormatter *format = NSNumberFormatter.new;
	[format setNumberStyle:NSNumberFormatterDecimalStyle];
	NSString* height = [webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
	
	[self.rowHeights replaceObjectAtIndex:webView.tag withObject:[format numberFromString:height]];
	
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kOPFQuestionBodyCell inSection:webView.tag]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if(navigationType==UIWebViewNavigationTypeLinkClicked) {
        // If the link is to a stackoverflow question
		if([[request.URL absoluteString] rangeOfString:@"stackoverflow.com/questions/"].location != NSNotFound){
			
            // Strip out the questionID
            NSUInteger n = [[request.URL absoluteString] rangeOfString:@"stackoverflow.com/questions/"].location + 28;
            NSString *questionId = [[request.URL absoluteString] substringFromIndex:n];
            questionId = [questionId substringToIndex:[questionId rangeOfString:@"/"].location];
            
            //Query question and see if it exist in the database
            OPFQuestion *question = [[OPFQuestion.query whereColumn:@"id" is:questionId] getOne];
            
            // If our question exist in our local DB
            if(question != nil){
                OPFQuestionViewController *questionView = OPFQuestionViewController.new;
                questionView.question = question;
                [self.navigationController pushViewController:questionView animated:YES];
            }
			return NO;
		}
		
		// Link is another website or a SO Answer not found in our DB
		
		OPFWebViewController *webBrowser = [OPFWebViewController new];
        webBrowser.page = request.URL;
        [self.navigationController pushViewController:webBrowser animated:YES];
        return NO;
	}
    else
        return YES;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"Question", @"Question view controller title");
	
	self.view.backgroundColor = UIColor.clearColor;
	
	[self.tableView registerNib:[UINib nibWithNibName:CDStringFromClass(OPFPostBodyTableViewCell) bundle:nil] forCellReuseIdentifier:BodyCellIdentifier];
	[self.tableView registerNib:[UINib nibWithNibName:CDStringFromClass(OPFPostMetadataTableViewCell) bundle:nil] forCellReuseIdentifier:MetadataCellIdentifier];
	[self.tableView registerNib:[UINib nibWithNibName:CDStringFromClass(OPFPostTagsTableViewCell) bundle:nil] forCellReuseIdentifier:TagsCellIdentifier];
	[self.tableView registerNib:[UINib nibWithNibName:@"OPFPostCommentTableViewCell" bundle:nil] forCellReuseIdentifier:CommentsCellIdentifier];
	[self.tableView registerNib:[UINib nibWithNibName:CDStringFromClass(OPFQuestionAnswerSeparatorCell) bundle:nil] forCellReuseIdentifier:AnswerSeparatorCellIdentifier];
	
	[self.tableView registerNib:[UINib nibWithNibName:CDStringFromClass(OPFQuestionHeaderView) bundle:nil] forHeaderFooterViewReuseIdentifier:QuestionHeaderViewIdentifier];
	
	UIBarButtonItem *composeAnswer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(postNewAnswer:)];
	self.navigationItem.rightBarButtonItem = composeAnswer;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    // If user is logged out, disable button, otherwise enable it
    self.navigationItem.rightBarButtonItem.enabled = OPFAppState.sharedAppState.isLoggedIn;
    
	[self updatePostsFromQuestion];
}


#pragma mark - 
- (void)refreshQuestion
{
	OPFQuestion *question = [OPFQuestion find:self.question.identifier.integerValue];
	self.question = question;
}

- (void)updatePost:(OPFPost *)post
{
	OPFPost *refreshedPost = [post refreshedObject];
	if (refreshedPost != nil) {
		NSUInteger postIndex = [self.posts indexOfObject:post];
		[self.posts replaceObjectAtIndex:postIndex withObject:refreshedPost];
		
//		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:postIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
//		NSIndexPath *metadataCellIndexPath = [NSIndexPath indexPathForRow:kOPFQuestionMetadataCell inSection:postIndex];
//		[self.tableView reloadRowsAtIndexPaths:@[ metadataCellIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
		
		if (refreshedPost.postType == KOPF_POST_TYPE_QUESTION) {
			OPFQuestionHeaderView *questionHeaderView = (OPFQuestionHeaderView *)[self.tableView headerViewForSection:kOPFQuestionSection];
			questionHeaderView.scoreLabel.text = [[OPFScoreNumberFormatter new] stringFromScoreNumber:refreshedPost.score];
			[questionHeaderView setNeedsLayout];
		}
	} else {
		ALog(@"The given post seems to have been removed from the database, post = %@", post);
	}
}

- (void)updatePostsFromQuestion
{
	[self.posts removeAllObjects];
	[self.posts addObject:self.question];
	[self.posts addObjectsFromArray:self.question.answers];
	
	self.rowHeights = [NSMutableArray arrayWithCapacity:self.posts.count];
	for (NSUInteger i = 0; i < self.posts.count; i++) {
		[self.rowHeights addObject:@5];
	}
	
	[self.tableView reloadData];
}

- (OPFPost *)questionPost
{
	return self.posts.count > 0 ? self.posts[0] : nil;
}

- (NSArray *)answerPosts
{
	NSArray *answerPosts = self.cache[@"answerPosts"];
	// Posts count must be larger than one (1) as the first post (index 0) is
	// the question post.
	if (answerPosts == nil && self.posts.count > 1) {
		answerPosts = [self.posts sortedArrayUsingComparator:^NSComparisonResult(OPFPost *post1, OPFPost *post2) {
			if (post1.score == post2.score) return NSOrderedSame;
			return (post1.score > post2.score ? NSOrderedDescending : NSOrderedAscending);
		}];
		self.cache[@"answerPosts"] = answerPosts;
	} else {
		answerPosts = NSArray.array;
	}
	
	return answerPosts;
}

- (OPFPost *)postForIndexPath:(NSIndexPath *)indexPath
{
	NSInteger section = indexPath.section;
	return self.posts[section];
}

- (BOOL)isPostQuestionPost:(OPFPost *)post
{
	return post == self.questionPost;
}


#pragma mark -
- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
	NSParameterAssert(indexPath);
	
	NSString *cellIdentifier = nil;
	if (indexPath.row == kOPFQuestionBodyCell) {
		cellIdentifier = BodyCellIdentifier;
	} else if (indexPath.row == kOPFQuestionMetadataCell) {
		cellIdentifier = MetadataCellIdentifier;
	} else {
		if (indexPath.section == kOPFQuestionSection) {
			if (indexPath.row == kOPFQuestionTagsCell) {
				cellIdentifier = TagsCellIdentifier;
			} else if (indexPath.row == kOPFQuestionCommentsWithTagsCell) {
				cellIdentifier = CommentsCellIdentifier;
			} else if (indexPath.row == kOPFQuestionAnswerSeparatorWithTagsCell) {
				cellIdentifier = AnswerSeparatorCellIdentifier;
			}
		} else {
			if (indexPath.row == kOPFQuestionCommentsWithoutTagsCell) {
				cellIdentifier = CommentsCellIdentifier;
			} else if (indexPath.row == kOPFQuestionAnswerSeparatorWithoutTagsCell) {
				cellIdentifier = AnswerSeparatorCellIdentifier;
			} else {
				NSAssert(NO, @"Unknown section/row combination, no known cell identifier found for %@", indexPath);
			}
		}
	}
	return cellIdentifier;
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Each post gets its own section and then we have a section for the
    return self.posts.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// The first section corresponds the question which has an extra row for tags.
	NSInteger rows = kOPFRowsInAnswerSection;
	if (section == kOPFQuestionSection) {
		rows = kOPFRowsInQuestionSection;
	} else if (section == [self numberOfSectionsInTableView:tableView] - 1) {
		// Lets not show the answer separator cell if it’s the last section.
		rows -= 1;
	}
    return rows;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *headerView = nil;
	if (section == kOPFQuestionSection) {
		OPFQuestionHeaderView *questionHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:QuestionHeaderViewIdentifier];
		OPFQuestion *question = self.posts[section];
		[questionHeaderView configureForQuestion:question];
		headerView = questionHeaderView;
	}
	return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
	
	
    OPFPost *post = [self postForIndexPath:indexPath];
	
    if ([cellIdentifier isEqualToString:BodyCellIdentifier]) {
		OPFPostBodyTableViewCell* htmlCell = (OPFPostBodyTableViewCell*)cell;
		htmlCell.bodyTextView.tag = indexPath.section;
		htmlCell.bodyTextView.delegate = self;
		[htmlCell.bodyTextView opf_loadHTMLString:post.body];
		
	} else if ([cellIdentifier isEqualToString:MetadataCellIdentifier]) {
		OPFPostMetadataTableViewCell *metadataCell = (OPFPostMetadataTableViewCell *)cell;
		
		metadataCell.userPreviewButton.iconAlign = kOPFIconAlignRight;
		metadataCell.userPreviewButton.user = post.owner;
		[metadataCell.userPreviewButton addTarget:self action:@selector(pressedUserPreviewButton:) forControlEvents:UIControlEventTouchUpInside];
		
        metadataCell.voteUpButton.post = post;
        metadataCell.voteUpButton.buttonTypeUp = YES;
		[metadataCell.voteUpButton addTarget:self action:@selector(pressedUserVoteButton:) forControlEvents:UIControlEventTouchUpInside];
		
        metadataCell.voteDownButton.post = post;
        metadataCell.voteDownButton.buttonTypeUp = NO;
        [metadataCell.voteDownButton addTarget:self action:@selector(pressedUserVoteButton:) forControlEvents:UIControlEventTouchUpInside];
		
		metadataCell.voteDownButton.siblingVoteButton = metadataCell.voteUpButton;
		metadataCell.voteUpButton.siblingVoteButton = metadataCell.voteDownButton;
        
		__block int voteNum = kOPFPostUserVoteStateNone;
		if (OPFAppState.sharedAppState.isLoggedIn) {
			[[[OPFDatabaseAccess getDBAccess] combinedQueue] inDatabase:^(FMDatabase* db){
				FMResultSet *result = [db executeQuery:@"SELECT * FROM 'auxDB'.'users_votes' WHERE 'users_votes'.'user_id' = ? AND 'users_votes'.'post_id' = ?" withArgumentsInArray:@[ OPFAppState.sharedAppState.user.identifier, post.identifier ]];
				[result next];
				voteNum = [result intForColumn:@"upvote"];
			}];
		}
        
		metadataCell.voteUpButton.selected = voteNum == kOPFPostUserVoteStateUp;
		metadataCell.voteDownButton.selected = voteNum == kOPFPostUserVoteStateDown;
		metadataCell.voteDownButton.enabled = OPFAppState.sharedAppState.isLoggedIn;
		metadataCell.voteUpButton.enabled = OPFAppState.sharedAppState.isLoggedIn;
	} else if ([cellIdentifier isEqualToString:TagsCellIdentifier]) {
		OPFPostTagsTableViewCell *tagsCell = (OPFPostTagsTableViewCell *)cell;
		tagsCell.tags = self.question.tags;
		tagsCell.didSelectTagBlock = ^(NSString *tagName) {
			[self didSelectTagNamed:tagName];
		};
	} else if ([cellIdentifier isEqualToString:CommentsCellIdentifier]) {
		if (post.comments.count > 0) { 
			cell.detailTextLabel.text = ((OPFComment*)post.comments[0]).text;
		} else {
			cell.detailTextLabel.text = NSLocalizedString(@"Add the first comment", @"No comments on post summary label.");
		}
	} else if ([cellIdentifier isEqualToString:AnswerSeparatorCellIdentifier]) {
		cell.textLabel.text = (indexPath.section == kOPFQuestionSection ? NSLocalizedString(@"ANSWERS", @"Question/answers separator label text") : @"");
	} else {
		NSAssert(NO, @"Unknonw cell identifier '%@'", cellIdentifier);
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([[self cellIdentifierForIndexPath:indexPath] isEqualToString:AnswerSeparatorCellIdentifier] == NO) {
		cell.backgroundColor = UIColor.whiteColor;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat height = 0.f;
	if (indexPath.row == kOPFQuestionBodyCell) {
		height = ((NSNumber*)self.rowHeights[indexPath.section]).floatValue;
	} else if ([[self cellIdentifierForIndexPath:indexPath] isEqualToString:AnswerSeparatorCellIdentifier]) {
		height = kOPFAnswerSeparatorHeight;
	} else {
		height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
	}
	return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	CGFloat height = (section == kOPFQuestionSection ? kOPFQuestionSectionHeight : 0.f);
	return height;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self cellIdentifierForIndexPath:indexPath] isEqualToString:CommentsCellIdentifier]) {
		OPFCommentsViewController *commentViewController = OPFCommentsViewController.new;
		OPFPost *post = [self postForIndexPath:indexPath];
		commentViewController.postModel = post;
        commentViewController.delegate=self;
		
		[self.navigationController pushViewController:commentViewController animated:YES];
	}
}

#pragma mark - User Preview Button delegate
- (void)pressedUserPreviewButton:(id)sender {
	OPFUserProfileViewController *userProfileViewController = OPFUserProfileViewController.newFromStoryboard;
    userProfileViewController.user = ((OPFUserPreviewButton*)sender).user;
    
    [self.navigationController pushViewController:userProfileViewController animated:YES];
}

- (void)pressedUserVoteButton:(OPFPostVoteButton *)voteButton
{
    __block NSInteger voteState = kOPFPostUserVoteStateNone;
    [[[OPFDatabaseAccess getDBAccess] combinedQueue] inDatabase:^(FMDatabase* db){
        FMResultSet *result = [db executeQuery:@"SELECT `upvote` FROM 'auxDB'.'users_votes' WHERE 'users_votes'.'user_id' = ? AND 'users_votes'.'post_id' = ?" withArgumentsInArray:@[ OPFAppState.sharedAppState.user.identifier, voteButton.post.identifier ]];
		
		[result next];
		voteState = [result intForColumn:@"upvote"];
    }];
	
	NSInteger newVoteState = kOPFPostUserVoteStateNone;
	
    if ((voteButton.buttonTypeUp && voteState == kOPFPostUserVoteStateUp) ||
		(voteButton.buttonTypeUp == NO && voteState == kOPFPostUserVoteStateDown)) {
		newVoteState = kOPFPostUserVoteStateNone;
	} else {
		newVoteState = voteButton.buttonTypeUp ? kOPFPostUserVoteStateUp : kOPFPostUserVoteStateDown;
	}
	
//    switch (voteState) {
//        case 0: newVoteState = voteButton.buttonTypeUp ? 1 : -1; break;
//        case 1: newVoteState = voteButton.buttonTypeUp ? 0 : -1; break;
//        case -1: newVoteState = voteButton.buttonTypeUp ? 1 : 0; break;
//        default:
//            break;
//    }
	
	NSInteger userIdentifier = OPFAppState.sharedAppState.user.identifier.integerValue;
	NSInteger postIdentifier = voteButton.post.identifier.integerValue;
	BOOL updated = [self updateVoteWithUserID:userIdentifier postID:postIdentifier vote:newVoteState];
	DLog(@"updated: %@", CDStringFromBOOL(updated));
	
	__strong OPFPostVoteButton *siblingVoteButton = voteButton.siblingVoteButton;
	if (voteButton.selected == YES) {
		voteButton.selected = NO;
		siblingVoteButton.selected = NO;
	} else {
		voteButton.selected = !(voteButton.selected);
		siblingVoteButton.selected = !(voteButton.selected);
	}
	
	[self updatePost:voteButton.post];
	
//    [self refreshQuestion];
//    [self updatePostsFromQuestion];
}


#pragma mark - Tag List Delegate
// TODO: Rewrite and fix.
- (void)didSelectTagNamed:(NSString *)tagName
{
	int views = self.navigationController.viewControllers.count;
	
	// See if the previous view controller was a questionS view
	BOOL reuse = (views >= 1) && [self.navigationController.viewControllers[views-2] isKindOfClass:[OPFQuestionsViewController class]];
	
	// Reuse the questionS view if available. Otherwise create new view
	OPFQuestionsViewController *view = (reuse ? self.navigationController.viewControllers[views-2] : [OPFQuestionsViewController new]);
	
	// Add search string to view
	view.searchString = tagName.opf_stringAsTagTokenString;
	
	// Navigate to the view
	if (reuse)
		[self.navigationController popViewControllerAnimated:YES];
	else
		[self.navigationController pushViewController:view animated:YES];
}


#pragma mark - Post a new answer
-(void) postNewAnswer:(id) sender{
    OPFPostAnswerViewController *postview = [OPFPostAnswerViewController new];
    postview.title = @"Post a question";
    postview.parentQuestion = [self.question.identifier integerValue];
    postview.delegate = self;
    [self.navigationController pushViewController:postview animated:YES];
}

-(void) updateQuestionView{
    [self refreshQuestion];
    [self.navigationController popViewControllerAnimated:YES];
}


- (BOOL)updateVoteWithUserID:(NSInteger)userID postID:(NSInteger)postID vote:(NSInteger)voteState
{
    __block int voteNum;
    __block int exist;
    
    [[[OPFDatabaseAccess getDBAccess] combinedQueue] inDatabase:^(FMDatabase* db){
        FMResultSet *result = [db executeQuery:@"SELECT COUNT(0) AS existens FROM 'auxDB'.'users_votes' WHERE 'users_votes'.'user_id' = ? AND 'users_votes'.'post_id' = ?;" withArgumentsInArray:@[ @(userID), @(postID) ]];
        [result next];
        exist = [result intForColumn:@"existens"];
        result = [db executeQuery:@"SELECT `upvote` FROM 'auxDB'.'users_votes' WHERE 'users_votes'.'user_id' = ? AND 'users_votes'.'post_id' = ?;" withArgumentsInArray:@[ @(userID), @(postID) ]];
        [result next];
        voteNum = [result intForColumn:@"upvote"];
    }];
    [[OPFDatabaseAccess getDBAccess] close];
    
    BOOL auxSucceeded = NO;
    
	NSInteger totalVotes = [OPFQuestion find:postID].score.integerValue;
	
	if (voteState == kOPFPostUserVoteStateNone) {
		NSArray *args = @[ @(userID), @(postID) ];
		NSString *auxQuery = @"DELETE FROM users_votes WHERE 'users_votes'.'user_id' = ? AND 'users_votes'.'post_id' = ?;";
		auxSucceeded = [[OPFDatabaseAccess getDBAccess] executeUpdate:auxQuery withArgumentsInArray:args auxiliaryUpdate:YES];
		
		totalVotes -= voteNum;
	} else if (exist == 0) {
        NSArray *args = @[ @(userID), @(postID), @(voteState) ];
        NSArray* col = @[@"user_id",@"post_id",@"upvote"];
        auxSucceeded = [OPFUpdateQuery insertInto:@"users_votes" forColumns:col values:args auxiliaryDB:YES];
		
		totalVotes += voteState;
	} else {
		NSArray *args = @[ @(voteState), @(userID), @(postID) ];
		NSString *auxQuery = @"UPDATE users_votes SET upvote=?  WHERE user_id=? AND post_id=?;";
		auxSucceeded = [[OPFDatabaseAccess getDBAccess] executeUpdate:auxQuery withArgumentsInArray:args auxiliaryUpdate:YES];
		
		totalVotes = totalVotes - voteNum + voteState;
    }
    
    NSArray *args = @[ @(totalVotes), @(postID) ];
    NSString *query = [NSString stringWithFormat:@"UPDATE posts SET score=? WHERE id=?;"];
    BOOL succeeded = [[OPFDatabaseAccess getDBAccess] executeUpdate:query withArgumentsInArray:args auxiliaryUpdate:NO];
    
    return auxSucceeded && succeeded;
}
// Refresh question from DB to get the vote + posts/votes which other users done since last update from db
- (void)commentsViewControllerUpvotedComment:(OPFCommentsViewController *)commentsViewController{
    [self refreshQuestion];
}



@end
