//
//  KKMatchInfoTableView.h
//  Localizer
//
//  Created by KKBOX on 12/10/24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol NSTableViewDelegateMatchInfoExtension <NSObject, NSTableViewDelegate>
- (void)tableView:(NSTableView *)inTableView didDeleteMatchInfosWithIndexes:(NSIndexSet *)inIndexes;
- (void)tableView:(NSTableView *)inTableView didCopiedMatchInfosWithIndexes:(NSIndexSet *)inIndexes;
- (void)tableView:(NSTableView *)inTableView didPasteMatchInfos:(NSIndexSet *)inIndexes;
@end

@interface JHMatchInfoTableView : NSTableView

@end
