//
//  OPFUserProfileViewController.m
//  Code Stream
//
//  Created by Marcus Johansson on 2013-04-25.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "OPFUserProfileViewController.h"
#import "OPFUser.h"
#import "OPFQuestionsViewController.h"
#import "OPFAppDelegate.h"
#import "UIImageView+KHGravatar.h"
#import "UIImageView+AFNetworking.h"
#import "OPFScoreNumberFormatter.h"
#import "OPFQuestion.h"
#import "OPFAnswer.h"
#import "NSString+OPFEscapeStrings.h"

enum  {
    kOPFUserQuestionsViewCell = 4,
    kOPFUserAnswersViewCell = 5
};

@interface OPFUserProfileViewController ()

@property(nonatomic, strong) OPFScoreNumberFormatter *scoreFormatter;
@property(nonatomic, strong) NSNumberFormatter *numberFormatter;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;

- (void)loadUserGravatar;
- (void)setAvatarWithGravatar :(UIImage*) gravatar;

@end

@implementation OPFUserProfileViewController

//Used on not specified information in model such as location or website
static NSString *const NotSpecifiedInformationPlaceholder = @"-";

// Identifiers for the questions and view cells
static NSString *const UserQuestionsViewCell = @"UsersQuestionsViewCell";
static NSString *const UserWebsiteViewCell = @"UserWebsiteViewCell";

static CGFloat userAboutMeInset = 20.0;

+ (instancetype)newFromStoryboard
{
	// This be a hack, do not ship stuff like this!
	NSAssert(OPFAppDelegate.sharedAppDelegate.storyboard != nil, @"Our hack to instantiate OPFUserProfileViewController from the storyboard failed as the root view controller wasn’t from the storyboard.");
	OPFUserProfileViewController *userProfileViewController = [OPFAppDelegate.sharedAppDelegate.storyboard instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
	return userProfileViewController;
}

-(id) init
{
	self = [super init];
    if (self) {
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    // Configure the view according to the userdata
    [self configureView];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TabbedViewController methods

// Setting the image of the tab.
- (NSString *)tabImageName
{
    return @"tab-me";
}

// Setting the title of the tab.
- (NSString *)tabTitle
{
    return NSLocalizedString(@"My Profile", @"Profile View Controller tab title");
}


- (void)loadUserGravatar
{
    __weak OPFUserProfileViewController *weakSelf = self;
    
    [self.userAvatar setImageWithGravatarEmailHash:self.user.emailHash placeholderImage:weakSelf.userAvatar.image defaultImageType:KHGravatarDefaultImageMysteryMan rating:KHGravatarRatingX
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [weakSelf setAvatarWithGravatar:image];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                 
    }];
}

- (void)setAvatarWithGravatar :(UIImage*) gravatar
{
    self.userAvatar.image = gravatar;
}

-(void) configureView
{
    self.scoreFormatter = [OPFScoreNumberFormatter new];
    self.numberFormatter = [NSNumberFormatter new];
    self.dateFormatter = [NSDateFormatter new];
    
    // Set the textFields in the userInterface
    self.userName.text = self.user.displayName;
    //self.userAboutMe.text = self.user.aboutMe;
    self.userLocation.text = (! [self.user.location isEqualToString:@"NULL"] ) ? self.user.location : NotSpecifiedInformationPlaceholder;
    self.userWebsite.text = (! [[self.user.websiteUrl absoluteString] isEqualToString:@"NULL"] ) ? [self.user.websiteUrl absoluteString] : NotSpecifiedInformationPlaceholder;

    [self loadUserGravatar];
    
    //Set number-fields by using a NSNumberFormatter and OPFScoreNumberFormatter
    self.userReputation.text = [self.scoreFormatter stringFromScore:[self.user.reputation integerValue]];;
    if(self.user.age!=nil){
        self.userAge.text = [self.numberFormatter stringFromNumber:self.user.age];
    }
    else
        self.userAge.text = @"-";
    // Set date-fields by using a NSDateFormatter
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    self.userCreationDate.text = [self.dateFormatter stringFromDate:self.user.creationDate];
    self.userLastAccess.text = [self.dateFormatter stringFromDate:self.user.lastAccessDate];
    
    if (![self.user.aboutMe isEqualToString:@"NULL"]) {
        [self.userBio loadHTMLString:[NSString stringWithFormat:@"<body bgcolor=\"#F7F7F7\"><font face='Helvetica' size='2'>%@</body>", [self.user.aboutMe OPF_escapeWithScheme:OPFEscapeHtml]] baseURL:nil];
    }
    else{
        [self.userBio loadHTMLString:[NSString stringWithFormat:@"<body bgcolor=\"#F7F7F7\"><font face='Helvetica' size='2'>-</body>"] baseURL:nil];
    }
	
	self.userBio.delegate = self;
    
    self.userVotes.text = [[[self.user.upVotes stringValue] stringByAppendingString:@" / "] stringByAppendingString:[self.user.downVotes stringValue]];
    
    self.views.text = [self.user.views stringValue];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //Autoresize the "About Me" textview
    CGFloat height = 0.f;
    
    if(indexPath.section==1 && indexPath.row == 0){
        NSString *aboutUser = _user.aboutMe;
        UIFont *aboutUserFont = [UIFont systemFontOfSize:14.f];
        CGSize constrainmentSize = CGSizeMake(CGRectGetWidth(tableView.bounds), 99999999.f);
        CGSize aboutUserSize = [aboutUser sizeWithFont:aboutUserFont constrainedToSize:constrainmentSize lineBreakMode:NSLineBreakByWordWrapping];
        height = aboutUserSize.height + userAboutMeInset;
    }
    // Set all the other tables to the default height
    else
    {
        height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return height;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

// Indentify which cell the user clicked on
-(NSString *) cellIdentifierForIndexPath: (NSIndexPath *) indexPath
{
    NSString *cellIdentifier = nil;
    
    if(indexPath.section==4){
        if(indexPath.row==0)
            cellIdentifier = UserQuestionsViewCell;
    }
    else if(indexPath.section==1 && indexPath.row==3)
        cellIdentifier = UserWebsiteViewCell;
    
    return cellIdentifier;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *detailViewController = nil;
    if([[self cellIdentifierForIndexPath:indexPath]isEqualToString:UserQuestionsViewCell]){
       
        OPFQuestionsViewController *questionsViewController = [OPFQuestionsViewController new];
		OPFQuery *questionsQuery = [[OPFQuestion query] whereColumn:@"owner_user_id" is:self.user.identifier];
		
        questionsViewController.query = questionsQuery;
		
        detailViewController = questionsViewController;
    }
    else if([[self cellIdentifierForIndexPath:indexPath]isEqualToString:UserWebsiteViewCell]){
        NSURL *url = [[NSURL alloc] initWithString:self.userWebsite.text];
        [[UIApplication sharedApplication] openURL:url];
    }
    
    // Pass the selected object to the new view controller.
    if(detailViewController!=nil){
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if(navigationType==UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:request.URL];
		return NO;
	} else return YES;
}



@end
