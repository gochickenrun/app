//
//  OPFProfileSearchViewController.m
//  Code Stream
//
//  Created by Tobias Deekens on 23.04.13.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import "OPFProfileSearchViewController.h"
#import "OPFProfileViewCell.h"
#import "OPFProfileSearchHeaderView.h"
#import "OPFUser.h"
#import "UIView+OPFViewLoading.h"

@interface OPFProfileSearchViewController ()

@property (strong, nonatomic) NSMutableArray *mutableUserModels;
@property(nonatomic) BOOL isFiltered;

- (void)performInitialDatabaseFetch;
- (void)opfSetupView;

@end

@implementation OPFProfileSearchViewController

static NSString *const ProfileHeaderViewIdentifier = @"OPFProfileSearchHeaderView";

- (id)init
{
    self = [super initWithNibName:@"OPFProfileSearchView" bundle:nil];

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

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)opfSetupView
{
    [self performInitialDatabaseFetch];    
}

- (void)performInitialDatabaseFetch
{
    self.userModels = [OPFUser all:0 per:30];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Returning 1 because we only have one section for users
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 59;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.isFiltered ? self.mutableUserModels.count : self.userModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *profileViewCellIdentifier = @"OPFProfileViewCell";
    
    OPFProfileViewCell *profileViewCell = (OPFProfileViewCell *)[tableView dequeueReusableCellWithIdentifier:profileViewCellIdentifier];
    
    if (profileViewCell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:profileViewCellIdentifier owner:self options:nil];
        profileViewCell = [nib objectAtIndex:0];
    }
        
    profileViewCell.userModel
    = (self.isFiltered == YES) ? [self.mutableUserModels objectAtIndex:indexPath.row] : [self.userModels objectAtIndex:indexPath.row];
    
    [profileViewCell setupFormatters];
    [profileViewCell setModelValuesInView];
    
    profileViewCell.profilesViewController = self;
    
    return profileViewCell;
}

#pragma mark - SearchBar Delegate -
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.isFiltered = (searchText.length == 0) ? NO : YES;
    
    //No else clause needed, next search will flush array anyways
    if(self.isFiltered) {
        [self.mutableUserModels removeAllObjects];
        
        self.profilePredicate = [NSPredicate predicateWithFormat:@"displayName BEGINSWITH[cd] %@", searchText];
                
        self.mutableUserModels = [NSMutableArray arrayWithArray:[self.userModels filteredArrayUsingPredicate:self.profilePredicate]];
    }
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
}

@end