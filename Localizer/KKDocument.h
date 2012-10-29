//
//  KKDocument.h
//  Localizer
//
//  Created by KKBOX on 12/10/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KKFilePathTableViewController.h"
#import "KKMatchInfoTableViewController.h"
#import "KKMatchInfoProcessor.h"

@interface KKDocument : NSDocument<NSToolbarDelegate>
{
    IBOutlet KKFilePathTableViewController *filePathTableViewController;
    IBOutlet KKMatchInfoTableViewController *matchInfoTableViewController;
    
    // 整合 src 和 localizable.strings 資料的處理器
    KKMatchInfoProcessor *matchInfoProcessor;
    
    // localizable.strings 的 header 資料
    NSArray *scanArray;
    
    // localizable.strings 中的 body 資料
    NSSet *localizableInfoSet;
}

- (IBAction)addScanFolderAndFiles:(id)sender;
- (IBAction)scan:(id)sender;

@property (assign, nonatomic) IBOutlet KKFilePathTableViewController *filePathTableViewController;
@property (assign, nonatomic) IBOutlet KKMatchInfoTableViewController *matchInfoTableViewController;

@property (retain, nonatomic) KKMatchInfoProcessor *matchInfoProcessor;
@property (retain, nonatomic) NSSet *localizableInfoSet;
@property (retain, nonatomic) NSArray *scanArray;

@end
