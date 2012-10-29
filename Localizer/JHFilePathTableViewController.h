/*
 JHFilePathTableViewController.h
 Copyright (C) 2012 Joe Hsieh
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <Foundation/Foundation.h>

@interface JHFilePathTableViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>
{
    NSMutableArray *filePathArray;
    
    //to be stored in localizable file
    NSArray *relativeFilePathArray;
    
    NSUndoManager *undoManager;
}

//增加原始碼路徑，動作完後會直接更新 table 上的資料
- (void)addFilePaths:(NSArray *)inArray;

//移除原始碼路徑，動作完後會直接更新 table 上的資料
- (void)removeFilePaths:(NSArray *)inArray;

//給定一個新的原始碼路徑的陣列，並且指定一個基底位置。將原始碼路徑是相對路徑的轉成絕對路徑並載入，動作完後會直接更新 table 上的資料
- (void)setSourceFilePaths:(NSArray *)inArray withBaseURL:(NSURL *)baseURL;

//將目前的 file path 複製一份後再經由傳入的 base url 製造一份相對路徑並儲存在物件中
- (void)updateRelativeFilePathArrayWithNewBaseURL:(NSURL *)baseURL;

//給定 index 的集合回傳該 index 集合所代表的物件
- (NSArray *)filePathsAtIndexes:(NSIndexSet *)indexSet;

@property (retain, nonatomic) NSArray *filePathArray;
@property (retain, nonatomic) NSArray *relativeFilePathArray;
@property (assign, nonatomic) NSUndoManager *undoManager;
@property (readonly, nonatomic) NSString *relativeSourceFilepahtsStringRepresentation;

@end
