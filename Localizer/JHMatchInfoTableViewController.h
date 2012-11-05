/*
 JHMatchInfoTableViewController.h
 Copyright (C) 2012 Joe Hsieh
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <Foundation/Foundation.h>
#import "JHMatchInfoTableView.h"

@interface JHMatchInfoTableViewController : NSObject<NSTableViewDelegate, NSTableViewDelegateMatchInfoExtension>
{
    // table view data
    IBOutlet NSArrayController *arrayController;
    NSUndoManager *undoManager;
    
    // for update every type count of top tool bar
    NSString *translatedCountString;
    NSString *unTranslatedCountString;
    NSString *notExistCountString;
    
}
//指定新的 matchInfo record 並重新載入，動作完後會直接更新 table 上的資料
- (void)reloadMatchInfoRecords:(NSArray *)inArray;

//利用 match info 的所有資訊生成一個固定格式的字串
- (NSString *)matchInfosString;

//回傳排序好的 match info file path 陣列
- (NSArray *)sortedMatchInfoFilePathArray;

//matchInfo array 要 redo 的時候使用這個介面 restore 資料 
- (void)restoreMatchinfoArray:(NSArray *)inArray actionName:(NSString *)inActionName;

- (IBAction)fileterByType:(id)sender;

@property (retain, nonatomic) IBOutlet NSArrayController *arrayController;
@property (readonly, nonatomic) NSArray *matchInfoArray;
@property (assign , nonatomic) NSUndoManager *undoManager;

@end
