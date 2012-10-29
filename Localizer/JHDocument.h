//
//  KKDocument.h
//  Localizer
//
//  Created by KKBOX on 12/10/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JHFilePathTableViewController.h"
#import "JHMatchInfoTableViewController.h"
#import "JHMatchInfoProcessor.h"

@interface JHDocument : NSDocument<NSToolbarDelegate>
{
    IBOutlet JHFilePathTableViewController *filePathTableViewController;
    IBOutlet JHMatchInfoTableViewController *matchInfoTableViewController;
    
    // 整合 src 和 localizable.strings 資料的處理器
    JHMatchInfoProcessor *matchInfoProcessor;
    
    // localizable.strings 的 header 資料
    NSArray *scanArray;
    
    // localizable.strings 中的 body 資料
    NSSet *localizableInfoSet;
}

- (IBAction)addScanFolderAndFiles:(id)sender;
- (IBAction)scan:(id)sender;

@property (assign, nonatomic) IBOutlet JHFilePathTableViewController *filePathTableViewController;
@property (assign, nonatomic) IBOutlet JHMatchInfoTableViewController *matchInfoTableViewController;

@property (retain, nonatomic) JHMatchInfoProcessor *matchInfoProcessor;
@property (retain, nonatomic) NSSet *localizableInfoSet;
@property (retain, nonatomic) NSArray *scanArray;

@end
