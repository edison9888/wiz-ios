//
//  WizIphoneFolderController.m
//  Wiz
//
//  Created by wiz on 12-8-28.
//
//

#import "WizIphoneFolderController.h"
#import "WizDbManager.h"
#import "WizNotification.h"
#import "PhFolderListViewController.h"

@interface WizIphoneFolderController () 

@end

@implementation WizIphoneFolderController


- (void) dealloc
{
    [WizNotificationCenter removeObserver:self];
    [super dealloc];
}

- (id) initWithRootTreeNode:(NSString *)nodeKey
{
    self = [super initWithRootTreeNode:nodeKey];
    if (self) {
        [WizNotificationCenter addObserverWithKey:self selector:@selector(reloadAllData) name:MessageTypeOfUpdateFolderTable];
    }
    return self;
}

- (NSString*) restructLoactionKey:(NSArray*)locationArray  maxIndex:(int)index
{
    NSMutableString* key = [NSMutableString string];
    [key appendString:@"/"];
    for (int i =1; i <= index; i++) {
        [key appendFormat:@"%@/",[locationArray objectAtIndex:i]];
    }
    return key;
}
- (void) makeSureParentExisted:(NSArray*)locationArray  rootNode:(TreeNode*)rootNode
{
    for (int i = 1; i < (NSInteger)[locationArray count] -1 ; i++) {
        NSString* key = [self restructLoactionKey:locationArray maxIndex:i];
        NSString* title = [locationArray objectAtIndex:i];
        TreeNode* currentNode = [rootNode childNodeFromKeyString:key];
        if (nil == currentNode) {
            currentNode = [[TreeNode alloc] init];
            currentNode.title = title;
            currentNode.keyString = key;
            currentNode.strType = WizTreeViewFolderKeyString;
            if (1 == i) {
                [rootNode addChildTreeNode:currentNode];
            }
            else
            {
                NSString* parentKey = [self restructLoactionKey:locationArray maxIndex:i-1];
                TreeNode* parentNode = [rootNode childNodeFromKeyString:parentKey];
                [parentNode addChildTreeNode:currentNode];
            }
            [currentNode release];
        }
    }
}
- (void) reloadFolderTootNode
{
    NSArray* allFolders = [[[WizDbManager shareDbManager] shareDataBase] allLocationsForTree];
    for (NSString* folderString in allFolders) {
        if ([folderString isEqualToString:@"/Deleted Items/"]) {
            continue;
        }
        NSArray* breakLocation = [folderString componentsSeparatedByString:@"/"];
        [self makeSureParentExisted:breakLocation rootNode:rootTreeNode];
    }
}
- (void) reloadAllTreeNodes
{
    [self reloadFolderTootNode];
}

- (void) decorateTreeCell:(WizPadTreeTableCell *)cell
{
    TreeNode* node = [rootTreeNode childNodeFromKeyString:cell.strTreeNodeKey];
    if (node == nil) {
        return;
    }
    NSInteger currentCount = [WizObject fileCountOfLocation:node.keyString];
    NSInteger totalCount = [WizObject filecountWithChildOfLocation:node.keyString];
    if (currentCount != totalCount) {
        cell.detailLabel.text = [NSString stringWithFormat:@"%d/%d",currentCount,totalCount];
    }
    else {
        cell.detailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d notes", nil),currentCount];
    }
    cell.titleLabel.text = NSLocalizedString(node.title, nil) ;
}

- (void) deleteTreeNodeContentData:(NSString *)key
{
    [WizObject deleteFolder:key];
}
- (UIImage*) placeHolderImage
{
//    return [UIImage imageNamed:@"treeItemFolder"];
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
       TreeNode* node = [needDisplayTreeNodes objectAtIndex:indexPath.row];
        PhFolderListViewController* folder = [[PhFolderListViewController alloc] initWithFolder:node.keyString];
        [self.navigationController pushViewController:folder animated:YES];
        [folder release];
    }
}
- (UIImage*) tableFootRemindImage
{
    return [UIImage imageNamed:@"folderTableFooter"];
}

- (NSString*) tableFootRemindString
{
    return NSLocalizedString(@"Folders allow you to organize your notes however you like. Your folders will sync with every version of WizNote you use.", nil);
}
//
- (NSString*) addNodeAlertTitle
{
    return NSLocalizedString(@"Add Folder", nil);
}

- (NSString*) alertTextfiledPlaceHolder
{
    return NSLocalizedString(@"Folder title", nil);
}

- (BOOL) isAddTreeNodeVaild:(NSString *)title
{
    BOOL isFolderExist = [[[WizDbManager shareDbManager] shareDataBase] isExistFolderWithTitle:title];
    if (isFolderExist) {
        [WizGlobals reportWarningWithString:[NSString stringWithFormat:NSLocalizedString(@"Folder named %@ exists!", nil),NSLocalizedString(title, nil)]];
    }
    return !isFolderExist;
}

- (TreeNode*) createNewTreeNode:(NSString *)title  fromeRootNode:(TreeNode*)node
{
    NSString* parentPath = @"/";
    
    NSString* path = [NSString stringWithFormat:@"%@%@/",parentPath,title];
    
    [WizObject addLocalFolder:path];
    TreeNode* nodeAdded = [[TreeNode alloc] init];
    nodeAdded.title = title;
    nodeAdded.strType = WizTreeViewFolderKeyString;
    nodeAdded.keyString = path;
    [node addChildTreeNode:nodeAdded];
    return [nodeAdded autorelease];
}
//
- (NSString*) deletedAlertTitle
{
    return NSLocalizedString(@"Delete Folder", nil);
}

- (NSString*) deletedAlertMessage:(TreeNode*)node
{
    return [NSString stringWithFormat:NSLocalizedString(@"You will delete the folder %@ and notes in it, are you sure?", nil), node.title];
}

- (BOOL) isDeletedVaild:(TreeNode*)node
{
    return ![node.keyString isEqualToString:@"/My Notes/"];
}
@end
