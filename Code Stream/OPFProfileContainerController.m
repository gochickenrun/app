//
//  OPFProfileContainerController.m
//  Code Stream
//
//  Created by Tobias Deekens on 04.05.13.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "OPFProfileContainerController.h"
#import "OPFAppState.h"
#import "OPFLoginViewController.h"
#import "OPFSignupViewController.h"
#import "OPFUserProfileViewController.h"
#import "NSString+OPFMD5Hash.h"

@interface OPFProfileContainerController ()

@property(strong, nonatomic) OPFLoginViewController *loginViewController;
@property(strong, nonatomic) OPFSignupViewController *signupViewController;
@property(strong, nonatomic) OPFUserProfileViewController *profileViewController;

- (void)transitionToLoginViewControllerFromViewController :(UIViewController *) viewController;
- (void)transitionToSignupViewControllerFromViewController :(UIViewController *) viewController;
- (void)transitionToProfileViewControllerFromViewController :(UIViewController *) viewController;

@end

@implementation OPFProfileContainerController

static const int TransitionDuration = .5f;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self opfSetupView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //Alloc init the contained view controllers
    self.loginViewController = [OPFLoginViewController new];
    self.signupViewController = [OPFSignupViewController new];
    self.profileViewController = [OPFUserProfileViewController newFromStoryboard];
    
    //self.profileViewController.nextResponder = self;
    
    //Add them to self (container) as child
    [self addChildViewController:self.loginViewController];
    [self addChildViewController:self.signupViewController];
    [self addChildViewController:self.profileViewController];
    
    //Let childs know that they have been moved into a parent <-> child relationship
    [self.loginViewController didMoveToParentViewController:self];
    [self.signupViewController didMoveToParentViewController:self];
    [self.profileViewController didMoveToParentViewController:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([OPFAppState isLoggedIn]) {
        self.profileViewController.user = [OPFAppState userModel];
        
        [self.view addSubview:self.profileViewController.view];
    } else {
        [self.view addSubview:self.loginViewController.view];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)opfSetupView
{
    self.title = NSLocalizedString(@"Login", @"Login View controller title");
}

#pragma mark - Transition methods

- (void)transitionToLoginViewControllerFromViewController :(UIViewController *) viewController;
{
    self.title = NSLocalizedString(@"Login", @"Login View controller title");
    
    [self transitionFromViewController:viewController
                      toViewController:self.loginViewController
                              duration:TransitionDuration
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil
                            completion:nil];
}

- (void)transitionToSignupViewControllerFromViewController :(UIViewController *) viewController;
{
    self.title = NSLocalizedString(@"Signup", @"Signup View controller title");
    
    [self transitionFromViewController:viewController
                      toViewController:self.signupViewController
                              duration:TransitionDuration
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil
                            completion:nil];
}

- (void)transitionToProfileViewControllerFromViewController :(UIViewController *) viewController;
{
    self.title = NSLocalizedString(@"Profile", @"Profile View controller title");
    
    self.profileViewController.user = [OPFAppState userModel];
    
    [self transitionFromViewController:viewController
                      toViewController:self.profileViewController
                              duration:TransitionDuration
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil
                            completion:nil];
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

#pragma mark - IBOutlet responder chain catches

- (void)userRequestsLogin:(id)sender
{    
    NSString* email = self.loginViewController.eMailField.text;
    NSString* password = self.loginViewController.passwordField.text;
    BOOL persistFlag = self.loginViewController.rememberUser.isOn;
    
    BOOL loginReponse = [OPFAppState loginWithEMailHash:email.opf_md5hash andPassword:password persistLogin:persistFlag];
    
    if(loginReponse == YES) {
        [self transitionToProfileViewControllerFromViewController:self.loginViewController];
    } else {
        self.loginViewController.loginMessageLabel.text = NSLocalizedString(@"Wrong username or password!", @"Login failure message");
    }
}
    
@end
