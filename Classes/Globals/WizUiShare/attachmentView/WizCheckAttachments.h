//
//  WizCheckAttachments.h
//  Wiz
//
//  Created by wiz on 12-2-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizCheckAttachments : UITableViewController <UIAlertViewDelegate,UIDocumentInteractionControllerDelegate>
{
    NSString* accountUserId;
    NSMutableArray* attachments;
    NSString* documentGUID;
    UIAlertView* waitAlert;
    UINavigationController* checkNav;
    NSIndexPath* lastIndexPath;
    UIDocumentInteractionController* currentPreview;
}
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSMutableArray* attachments;
@property (nonatomic, retain) NSString* documentGUID;
@property (nonatomic, retain) UIAlertView* waitAlert;
@property (nonatomic, retain) UINavigationController* checkNav;
@property (nonatomic, retain) NSIndexPath* lastIndexPath;
@property (nonatomic, retain) UIDocumentInteractionController* currentPreview;
- (void) downloadDone:(NSNotification*)nc;
@end