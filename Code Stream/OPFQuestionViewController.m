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
#import "OPFPostAnswerViewController.h"
#import "NSString+OPFEscapeStrings.h"
#import "UIWebView+OPFHtmlView.h"
#import "OPFWebViewController.h"

enum {
	kOPFQuestionBodyCell = 0,
	kOPFQuestionMetadataCell = 1,
	kOPFQuestionTagsCell = 2,
	kOPFQuestionCommentsWithTagsCell = 3,
	kOPFQuestionCommentsWithoutTagsCell = 2,
};

static const NSInteger kOPQuestionSection = 0;

static const CGFloat kOPQuestionBodyInset = 20.f;


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
-(void)webViewDidFinishLoad:(UIWebView *)webView {
	
	if (![self.rowHeights[webView.tag] isEqual: @5])
		return;
	
    CGRect frame = webView.frame;
    frame.size = [webView sizeThatFits:CGSizeZero];
    webView.frame = frame;
	
	[self.rowHeights replaceObjectAtIndex:webView.tag withObject:@(webView.frame.size.height)];
	
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kOPFQuestionBodyCell inSection:webView.tag]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if(navigationType==UIWebViewNavigationTypeLinkClicked) {
        NSLog(@"Button clicked");
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
                OPFQuestionViewController *questionView = [OPFQuestionViewController new];
                questionView.question = question;
                [self.navigationController pushViewController:questionView animated:YES];
            }
            // Oterwise open the stackoverflow webpage
            else{
                OPFWebViewController *webBrowser = [OPFWebViewController new];
                webBrowser.page=request.URL;
                [self.navigationController pushViewController:webBrowser animated:YES];
            }
            
            return NO;
            
        }
        else{
            OPFWebViewController *webBrowser = [OPFWebViewController new];
            webBrowser.page = request.URL;
            [self.navigationController pushViewController:webBrowser animated:YES];
            return NO;
        }
        
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
	[self.tableView registerNib:[UINib nibWithNibName:CDStringFromClass(OPFQuestionHeaderView) bundle:nil] forHeaderFooterViewReuseIdentifier:QuestionHeaderViewIdentifier];
}


- (void)viewWillAppear:(BOOL)animated
{
    UIBarButtonItem *composeAnswer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(postNewAnswer:)];
    self.navigationItem.rightBarButtonItem = composeAnswer;
    
    NSLog(@"View Will Appear!!!");
    [self.tableView reloadData];
    
    OPFUser *user = [[OPFUser alloc] init];
    [user setReputation:@(351)];
    [user setDisplayName:@"Aron"];
    OPFPost *post = [[OPFPost alloc] init];
    [post setScore:@(123)];
    [post setTitle:@"This is the question right? Well the title will most likely be a bit long."];
    [post setBody:@"<p>We can write</p>\n\n<pre class=\"\"lang-rb prettyprint-override\"\"><code>get '/foo' do\n  ...\nend\n</code></pre>\n\n<p>and</p>\n\n<pre class=\"\"lang-rb prettyprint-override\"\"><code>post '/foo' do\n  ...\nend\n</code></pre>\n\n<p>which is fine.  But can I combine multiple HTTP verbs in one route?</p>\n"];
	
    post.owner = user;
    
    OPFPost *post1 = [[OPFPost alloc] init];
    [post1 setScore:@(456)];
    [post1 setTitle:@"This is a question with a rather long title, right? But it could also be even longer, or could it? What happens when we make it crazy long?"];
    [post1 setBody:@"<p>Response generated by ASP Webservice:</p>\n\n<pre><code>&lt;?xml version=""1.0"" encoding=""utf-8""?&gt;\n&lt;soap:Envelope xmlns:soap=""http://www.w3.org/2003/05/soap-envelope"" xmlns:rpc=""http://www.w3.org/2003/05/soap-rpc"" xmlns:soapenc=""http://www.w3.org/2003/05/soap-encoding"" xmlns:tns=""http://tempuri.org/"" xmlns:types=""http://tempuri.org/"" xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""&gt;\n    &lt;soap:Body&gt;\n        &lt;types:GenerateRandomResponse&gt;\n            &lt;rpc:result&gt;GenerateRandomResult&lt;/rpc:result&gt;\n            &lt;GenerateRandomResult xsi:type=""xsd:string""&gt;5kHKi1&lt;/GenerateRandomResult&gt;\n        &lt;/types:GenerateRandomResponse&gt;\n    &lt;/soap:Body&gt;\n&lt;/soap:Envelope&gt;\n</code></pre>\n\n<p>Request in spring:</p>\n\n<pre class=""lang-java prettyprint-override""><code>GenerateRandom generateRandom = new GenerateRandom();\nGenerateRandomResponse response = (GenerateRandomResponse)webServiceTemplate.marshalSendAndReceive(generateRandom);\n</code></pre>\n\n<pre class=""lang-java prettyprint-override""><code>@XmlRootElement(namespace = ""http://tempuri.org/"", name = ""GenerateRandom"")\npublic class GenerateRandom\n{\n}\n</code></pre>\n\n<pre class=""lang-java prettyprint-override""><code>@XmlRootElement(namespace = ""http://tempuri.org/"", name = ""GenerateRandomResponse"")\npublic class GenerateRandomResponse\n{\n}\n</code></pre>\n\n<p>How to bind response to GenerateRandomResponse?\nI try @XmlValue, nothing...</p>\n"];
    
    post1.owner=user;
	
	// If a question was set, load it. Otherwise take this just created mockup question
	if (self.question) {
		[self.posts addObject:self.question];
		[self.posts addObjectsFromArray:self.question.answers];
	} else
		[self.posts addObjectsFromArray:@[ post, post1 ]];
	
	self.rowHeights = [NSMutableArray arrayWithCapacity:self.posts.count];
	for (int i = 0; i < self.posts.count; i++) {
		[self.rowHeights addObject:@5];
	}
	
	[super viewWillAppear:animated];
}


#pragma mark - 
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
	return self.posts[indexPath.section];
}

- (BOOL)isPostQuestionPost:(OPFPost *)post
{
	return post == self.questionPost;
}


#pragma mark -
- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier = nil;
	if (indexPath.row == kOPFQuestionBodyCell) {
		cellIdentifier = BodyCellIdentifier;
	} else if (indexPath.row == kOPFQuestionMetadataCell) {
		cellIdentifier = MetadataCellIdentifier;
	} else {
		if (indexPath.section == kOPQuestionSection) {
			if (indexPath.row == kOPFQuestionTagsCell) {
				cellIdentifier = TagsCellIdentifier;
			} else if (indexPath.row == kOPFQuestionCommentsWithTagsCell) {
				cellIdentifier = CommentsCellIdentifier;
			}
		} else if (indexPath.row == kOPFQuestionCommentsWithoutTagsCell) {
			cellIdentifier = CommentsCellIdentifier;
		}
	}
	return cellIdentifier;
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.posts.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// The first section corresponds the question which has an extra row for tags.
    return (section == 0 ? 4 : 3);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	OPFQuestionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:QuestionHeaderViewIdentifier];
	
	OPFPost *post = self.posts[section];
	headerView.titleLabel.text = [post isKindOfClass:[OPFQuestion class]] ? post.title : @"";
	
	OPFScoreNumberFormatter *scoreFormatter = self.cache[@"scoreFormatter"];
	if (scoreFormatter == nil) {
		scoreFormatter = [OPFScoreNumberFormatter new];
		self.cache[@"scoreFormatter"] = scoreFormatter;
	}
	headerView.scoreLabel.text = [scoreFormatter stringFromScore:post.score.unsignedIntegerValue];
	
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
												   
											   
	} else if ([cellIdentifier isEqualToString:TagsCellIdentifier]) {
		OPFPostTagsTableViewCell *tagsCell = (OPFPostTagsTableViewCell *)cell;
		tagsCell.tags = self.question.tags;
		tagsCell.tagsView.delegate = self;
		tagsCell.tagsView.dataSource = tagsCell;
		[tagsCell.tagsView reloadData];
		
	} else if ([cellIdentifier isEqualToString:CommentsCellIdentifier]) {
		if (post.comments.count > 0) { 
			cell.detailTextLabel.text = ((OPFComment*)post.comments[0]).text;
		} else {
			cell.detailTextLabel.text = NSLocalizedString(@"Add the first comment", @"No comments on post summary label.");
		}
	} else {
		NSAssert(NO, @"Unknonw cell identifier '%@'", cellIdentifier);
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	cell.backgroundColor = UIColor.whiteColor;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat height = 0.f;
	if (indexPath.row == kOPFQuestionBodyCell) {/*
		OPFPost *post = [self postForIndexPath:indexPath];
		NSString *body = post.body;
	
		UIFont *bodyFont = [UIFont systemFontOfSize:14.f];
		CGSize constrainmentSize = CGSizeMake(CGRectGetWidth(tableView.bounds), 99999999.f);
		CGSize bodySize = [body sizeWithFont:bodyFont constrainedToSize:constrainmentSize lineBreakMode:NSLineBreakByWordWrapping];
		height = bodySize.height + kOPQuestionBodyInset;*/
		height = ((NSNumber*)self.rowHeights[indexPath.section]).floatValue;
	} else {
		height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
	}
	return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 44.f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([[self cellIdentifierForIndexPath:indexPath] isEqualToString:MetadataCellIdentifier]) {
		OPFPost *post = [self postForIndexPath:indexPath];
		OPFUserProfileViewController *view = OPFUserProfileViewController.newFromStoryboard;
		view.user = post.owner;
		
		[self.navigationController pushViewController:view animated:YES];
		
	}
    if ([[self cellIdentifierForIndexPath:indexPath] isEqualToString:CommentsCellIdentifier]) {
        
		// Selected cell was comment
		
		OPFPost *post = [self postForIndexPath:indexPath];
		OPFCommentsViewController *commentViewController = [OPFCommentsViewController new];
		
		commentViewController.postModel = post;
		
		[self.navigationController pushViewController:commentViewController animated:YES];
	}
}

#pragma mark - User Preview Button delegate
- (void)pressedUserPreviewButton:(id)sender {
	OPFUserProfileViewController *userProfileViewController = OPFUserProfileViewController.newFromStoryboard;
    userProfileViewController.user = ((OPFUserPreviewButton*)sender).user;
    
    [self.navigationController pushViewController:userProfileViewController animated:YES];
}

#pragma mark - Tag List Delegate

- (void)tagList:(GCTagList *)taglist didSelectedLabelAtIndex:(NSInteger)index {
	
	
	
	int views = self.navigationController.viewControllers.count;
	
	// See if the previous view controller was a questionS view
	Boolean reuse = (views >= 1) && [self.navigationController.viewControllers[views-2] isKindOfClass:[OPFQuestionsViewController class]];
	
	// Reuse the questionS view if available. Otherwise create new view
	OPFQuestionsViewController *view = (reuse) ? self.navigationController.viewControllers[views-2] :[OPFQuestionsViewController new] ;
	
	// Add search string to view
	view.searchString = [NSString stringWithFormat:@"[%@]", [taglist.dataSource tagList:taglist tagLabelAtIndex:index].text];
	
	
	
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
    [self reloadInputViews];
}

-(void) updateViewWithAnswer:(OPFAnswer *) answer{
    [self.posts addObject:answer];
    [self.tableView reloadData];
}






@end
