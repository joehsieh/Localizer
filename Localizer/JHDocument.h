/*
 JHDocument.h
 Copyright (C) 2012 Joe Hsieh
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

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
