//
//  KKFilePathTableViewController.h
//  Localizer
//
//  Created by KKBOX on 12/10/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKFilePathTableViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>
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
