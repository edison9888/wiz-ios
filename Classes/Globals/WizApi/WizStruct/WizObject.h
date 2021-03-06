//
//  WizObject.h
//  Wiz
//
//  Created by MagicStudio on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizObject : NSObject
{
    NSString* guid;
    NSString* title;
}
@property (atomic, retain) NSString* guid;
@property (nonatomic, retain) NSString* title;
+ (int) filecountWithChildOfLocation:(NSString*) location;
+ (int) fileCountOfLocation:(NSString *)location;
+ (NSArray*) allLocationsForTree;
+ (NSString*) folderAbstract:(NSString*)folderKey;
+ (void) deleteFolder:(NSString*)folderKey;
+ (BOOL) addLocalFolder:(NSString*)folder;
@end
