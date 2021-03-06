//
//  WizPadListTableControllerBase.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadListTableControllerBase.h"
#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "NSDate-Utilities.h"
#import "WizPadNotificationMessage.h"
#import "WizNotification.h"
#import "pinyin.h"
#import <ifaddrs.h>
#import "WizDocument.h"
#import "WizDbManager.h"
#import "WizTableViewController.h"
#import "WizSettings.h"
#import "WizUiTypeIndex.h"
#import "WizSyncManager.h"


@interface WizPadListTableControllerBase ()
{
    UILabel* userRemindLabel;
    UIActivityIndicatorView* syncIndicator;
    BOOL isFirstLogin;
}
@end

@implementation WizPadListTableControllerBase
@synthesize isLandscape;
@synthesize kOrderIndex;
@synthesize tableArray;
@synthesize checkDocumentDelegate;
@synthesize orientationDelegate;

- (UIInterfaceOrientation) interfaceOrientation
{
    return [self.orientationDelegate currentOrientation];
}

- (void) dealloc
{
    orientationDelegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MessageOfChangeDocumentListOrderMethod object:nil];
    [WizNotificationCenter removeObserver:self];
    [tableArray release];
    checkDocumentDelegate = nil;
    
    [userRemindLabel release];
    userRemindLabel = nil;
    
    [syncIndicator release];
    syncIndicator = nil;
    
    [super dealloc];
}
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [WizNotificationCenter addObserverForUpdateDocument:self selector:@selector(updateDocument:)];
        [WizNotificationCenter addObserverForDeleteDocument:self selector:@selector(onDeleteDocument:)];
        [WizNotificationCenter addObserverWithKey:self selector:@selector(reloadAllData) name:MessageTypeOfPadTableViewListChangedOrder];
        NSMutableArray* arr = [NSMutableArray arrayWithCapacity:0];
        self.tableArray = [NSMutableArray array];
        [self.tableArray addObject:arr];
        kOrderIndex = -1;
        self.tableArray = [NSMutableArray array];
        userRemindLabel = [[UILabel alloc] init];
        syncIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30, 30)];
        userRemindLabel.backgroundColor = [UIColor clearColor];;
        userRemindLabel.textAlignment = UITextAlignmentCenter;
        userRemindLabel.userInteractionEnabled = NO;
        userRemindLabel.numberOfLines = 0;

        userRemindLabel.textColor = [UIColor lightTextColor];
        userRemindLabel.font= [UIFont systemFontOfSize:35];
        
        isFirstLogin = YES;
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (NSArray*) reloadDocuments
{
    return [WizDocument recentDocuments];
}

- (void) didChangedSyncDescription:(NSString *)description
{
    userRemindLabel.text = WizStrLoading;
    if (description == nil || [description  isBlock]) {
        userRemindLabel.text = NSLocalizedString(@"You don't have any notes.\n Tap new note to get started!", nil);
    }
    else {
        if ([self.tableArray count] > 0) {
            if ([[self.tableArray objectAtIndex:0] count] >0) {
                self.tableView.backgroundView = nil;
            }
        }
    }
}

- (void) reloadAllData
{
    NSArray* documents = [self reloadDocuments];
    if (![documents count]) {
        UIView* back =  [[UIView alloc] initWithFrame:self.view.frame];
        NSLog(@"size is %f %f",back.frame.size.width,back.frame.size.height);
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            userRemindLabel.frame = CGRectMake(312, 184, 400, 400);
        }
        else {
            userRemindLabel.frame = CGRectMake(184, 312, 400, 400);
        }
        userRemindLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [back addSubview:userRemindLabel];
        userRemindLabel.text = NSLocalizedString(@"You don't have any notes.\n Tap new note to get started!", nil);
        self.tableView.backgroundView = back;
        [back release];
        [[WizSyncManager shareManager] setDisplayDelegate:self];
    }
    else
    {
        self.tableView.backgroundView = nil;
        [self.tableArray removeAllObjects];
        [self.tableArray addObject:[NSMutableArray arrayWithArray:documents]];
        NSInteger order = [[WizSettings defaultSettings] userTablelistViewOption];
        [self.tableArray sortDocumentByOrder:order];
        [self.tableView reloadData];
        self.kOrderIndex = order;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor= [UIColor scrollViewTexturedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[UIDevice currentDevice] orientation] != self.interfaceOrientation) {
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[WizSettings defaultSettings] userTablelistViewOption] != self.kOrderIndex) {
        [self reloadAllData];
    }
    [self.tableView reloadData];
    if (isFirstLogin) {
        [[WizSyncManager shareManager] automicSyncData];
        isFirstLogin = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void) didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [self.tableView reloadData];
    [super didAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tableArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    
    
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        count = 4;
   }
    else
    {
        count = 3;
    }
    
    if ([[self.tableArray objectAtIndex:section] count]%count>0) {
        return  [[self.tableArray objectAtIndex:section] count]/count+1;
    }
    else {
        return [[self.tableArray objectAtIndex:section] count]/count  ;
    }
}
- (void) didSelectedDocument:(WizDocument*)doc
{
    [self.checkDocumentDelegate checkDocument:WizPadCheckDocumentSourceTypeOfRecent keyWords:doc.guid selectedDocument:doc];
}
- (void)updateDocument:(NSNotification*)nc
{
    NSString* documentGUID = [WizNotificationCenter getDocumentGUIDFromNc:nc];
    if (documentGUID == nil) {
        return;
    }
    WizDocument* doc = [WizDocument documentFromDb:documentGUID];
    if (doc == nil) {
        return;
    }
    NSIndexPath* updatePath = [self.tableArray updateDocument:doc];
    if (updatePath != nil) {
        return;
    }
    NSIndexPath* indexPath = [self.tableArray insertDocument:doc];
    
    if (nil != indexPath) {
        if (WizNewSectionIndex == indexPath.section) {
            [self.tableView beginUpdates];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
        else {
            [self.tableView beginUpdates];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
    }
    self.tableView.backgroundView = nil;
}
- (void) didPadCellDidSelectedDocument:(WizDocument *)doc
{
    [self didSelectedDocument:doc];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WizPadAbstractCell";
    WizPadListCell *cell = (WizPadListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        static CGSize detailSize = CGSizeMake(205, 300);
        cell = [[[WizPadListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier detailViewSize:detailSize] autorelease];
        cell.selectedDelegate = self;
    }
    NSUInteger documentsCount=0;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        documentsCount = 4;
    }
    else
    {
        documentsCount = 3;
    }
    NSUInteger needLength = documentsCount*(indexPath.row+1);
    NSArray* sectionArray = [self.tableArray objectAtIndex:indexPath.section];
    NSArray* cellArray=nil;
    NSRange docRange;
    if ([sectionArray count] < needLength) {
        docRange =  NSMakeRange(documentsCount*indexPath.row, (NSInteger)[sectionArray count]-documentsCount*indexPath.row);
    }
    else {
        docRange = NSMakeRange(documentsCount*indexPath.row, documentsCount);
    }
    cellArray = [sectionArray subarrayWithRange:docRange];
    cell.documents = cellArray;
    [cell updateDoc];
  
    return cell;
}
#pragma mark - Table view delegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return PADABSTRACTVELLHEIGTH;
}
- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSMutableArray* array = [self.tableArray objectAtIndex:section];
    return [array arrayTitle];
}

// interface  orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES ];
    NSLog(@"interface is %d",self.interfaceOrientation);
    
}

- (void) onDeleteDocument:(NSNotification*)nc
{
    WizDocument* doc = [WizNotificationCenter getWizDocumentFromNc:nc];
    if (nil == doc)
    {
        NSLog(@"nil");
        return;
    }
    NSIndexPath* indexPath = [self.tableArray removeDocument:doc];
    if (nil != indexPath) {
        if (WizDeletedSectionIndex == indexPath.row) {
            [self.tableView beginUpdates];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
        else {
            [self.tableView beginUpdates];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id) init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
@end
