//
//  KKMatchInfoTableViewController.h
//  Localizer
//
//  Created by joehsieh on 12/10/14.
//
//

#import <Foundation/Foundation.h>
#import "KKMatchInfoTableView.h"

@interface KKMatchInfoTableViewController : NSObject<NSTableViewDelegate, NSTableViewDelegateMatchInfoExtension>
{
    // table view data
    IBOutlet NSArrayController *arrayController;
    NSUndoManager *undoManager;
    
}
//指定新的 matchInfo record 並重新載入，動作完後會直接更新 table 上的資料
- (void)reloadMatchInfoRecords:(NSArray *)inArray;

//利用 match info 的所有資訊生成一個固定格式的字串
- (NSString *)matchInfosString;

//回傳排序好的 match info file path 陣列
- (NSArray *)sortedMatchInfoFilePathArray;


@property (retain, nonatomic) IBOutlet NSArrayController *arrayController;
@property (readonly, nonatomic) NSArray *matchInfoArray;
@property (assign , nonatomic) NSUndoManager *undoManager;

@end
