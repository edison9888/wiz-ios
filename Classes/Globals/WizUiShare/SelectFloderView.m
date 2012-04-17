//
//  SelectFloderView.m
//  Wiz
//
//  Created by dong zhao on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SelectFloderView.h"
#import "WizGlobalData.h"
#import "WizIndex.h"
#import "WizGlobals.h"
#import "WizPadNotificationMessage.h"
#import "WizGlobals.h"
@implementation SelectFloderView

@synthesize selectedFloder;
@synthesize allFloders;
@synthesize accountUserID;
@synthesize selectedFloderString;
@synthesize searchBar;
@synthesize searchDisplayController;
@synthesize searchedFolder;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
    self.searchedFolder = nil;
    self.allFloders = nil;
    self.accountUserID = nil;
    self.searchDisplayController = nil;
    self.searchBar = nil;
    [super dealloc];
}
- (void)searchTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* folder = [self.searchedFolder objectAtIndex:indexPath.row];
    if ([folder isEqualToString:[self.selectedFloder lastObject]]) {
            return;
    }
    else {
        [self didSelectedFolder:folder];
        [tableView reloadData];
        [self.tableView reloadData];
    }
    [self.searchDisplayController setActive:NO animated:YES];
}
- (void) buildSeachView
{
    self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)] autorelease];
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.delegate =self;
    self.tableView.tableHeaderView = self.searchBar;
    self.searchDisplayController= [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self]autorelease];
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) addFloder
{
   [[NSNotificationCenter defaultCenter] postNotificationName:TypeOfSelectedFolder object:nil userInfo:[NSDictionary dictionaryWithObject:[self.selectedFloder lastObject]  forKey:TypeOfFolderKey]];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildSeachView];
    if (![WizGlobals WizDeviceIsPad]) {
        UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithTitle:WizStrOK style:UIBarButtonItemStyleDone target:self action:@selector(addFloder)];
        self.navigationItem.rightBarButtonItem = editButton;
        [editButton release];
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    if(self.selectedFloder == nil)
        self.selectedFloder = [[[NSMutableArray alloc] init] autorelease];
    if(self.allFloders == nil)
        self.allFloders = [[[[[WizGlobalData sharedData] indexData:self.accountUserID] allLocationsForTree] mutableCopy] autorelease];
    if(![self.selectedFloderString isEqual:@""])
    {
        for(int i = 0; i < [self.allFloders count]; i++)
        {
            NSString* each = [self.allFloders objectAtIndex:i];
            if([each isEqualToString:self.selectedFloderString])
            {
                [self.selectedFloder addObject:each];
            }
        }
    if ([self.selectedFloder count] ==0) {
        [self.selectedFloder addObject:self.selectedFloderString];
        [self.allFloders insertObject:self.selectedFloderString atIndex:0];
    }
    }
    else
    {
        [self.selectedFloder addObject:[self.allFloders objectAtIndex:0]];
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return 2;
    }
    else {
        return 1;
    }
}

- (NSUInteger) searchTableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString* match = [NSString stringWithFormat:@"*%@*",self.searchBar.text];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF like[cd] %@",match];
    NSArray* nameIn = [self.allFloders filteredArrayUsingPredicate:predicate];
    self.searchedFolder = nameIn;
    return [self.searchedFolder count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if(section == 0)
            return [self.selectedFloder count];
        if(section == 1)
            return [self.allFloders count];
    }
    else {
        return [self searchTableView:tableView numberOfRowsInSection:section];
    }
    return 0;
}
- (UITableViewCell *)searchTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    NSString* title = [self.searchedFolder objectAtIndex:indexPath.row];
    if ([title isEqualToString:[self.selectedFloder lastObject]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = [self.searchedFolder objectAtIndex:indexPath.row];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        if(0 == indexPath.section) 
        {
            cell.textLabel.text = [WizGlobals folderStringToLocal:[self.selectedFloder objectAtIndex:indexPath.row]];
        }
        if(1 == indexPath.section)
        {
            cell.textLabel.text = [WizGlobals folderStringToLocal:[self.allFloders objectAtIndex:indexPath.row]];
            if ([[self.selectedFloder lastObject] isEqualToString:[self.allFloders objectAtIndex:indexPath.row]]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }
    else {
        return [self searchTableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

#pragma mark - Table view delegate

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if(0 == section)
            return NSLocalizedString(@"Selected folders",nil);
        if(1 == section)
            return NSLocalizedString(@"All folders", nil);
    }
    else {
        return nil;
    }
    return @"";
}
- (BOOL) checkFolderIsExist:(NSString*)folder
{
    for (NSString* each in self.allFloders) {
        if ([each isEqualToString:folder]) {
            return YES;
        }
    }
    return NO;
}
- (void) didSelectedFolder:(NSString*)folder
{
    if (![self checkFolderIsExist:folder]) {
        [self.allFloders insertObject:folder atIndex:0];
    }
    [self.selectedFloder removeLastObject];
    [self.selectedFloder addObject:folder];
    self.selectedFloderString = [NSMutableString stringWithString:folder];
    if (WizDeviceIsPad()) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TypeOfSelectedFolder object:nil userInfo:[NSDictionary dictionaryWithObject:folder forKey:TypeOfFolderKey]];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tableView)
    {
        if( 1 == indexPath.section) {
            NSString* folder = [self.allFloders objectAtIndex:indexPath.row];
            if ([folder isEqualToString:[self.selectedFloder lastObject]]) {
                return;
            }
            else {
                [self didSelectedFolder:folder];
                [self.tableView reloadData];
            }
        }
        
    }
    else {
        [self searchTableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSString* location = [NSString stringWithFormat:@"/%@/",self.searchBar.text];
    [self didSelectedFolder:location];
    [self.tableView reloadData];
}
- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = YES;
    for(id cc in [self.searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:NSLocalizedString(@"Add", nil) forState:UIControlStateNormal];
        }
    }
}
@end