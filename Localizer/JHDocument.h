/*
 JHDocument.h
 Copyright (C) 2012 Joe Hsieh

 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:

 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
*/

#import <Cocoa/Cocoa.h>
#import "JHFilePathTableViewController.h"
#import "JHMatchInfoTableViewController.h"
#import "JHMatchInfoProcessor.h"
#import "JHTranslatedWindowController.h"

// An abstract document which represents a "Localizable.strings" file.

@interface JHDocument : NSDocument <NSToolbarDelegate,JHTranslatedWindowControllerDelegate>
{
    IBOutlet JHFilePathTableViewController *filePathTableViewController;
    IBOutlet JHMatchInfoTableViewController *matchInfoTableViewController;
	IBOutlet NSSegmentedControl *segmentedControl;

    JHTranslatedWindowController *translatedWindowController;
    JHMatchInfoProcessor *matchInfoProcessor;
    NSArray *scanArray;
    NSSet *localizableInfoSet;
}

- (IBAction)addScanFolderAndFiles:(id)sender;
- (IBAction)scan:(id)sender;
- (IBAction)translate:(id)sender;
- (IBAction)filterWithSearchType:(id)sender;

@property (assign, nonatomic) IBOutlet JHFilePathTableViewController *filePathTableViewController;
@property (assign, nonatomic) IBOutlet JHMatchInfoTableViewController *matchInfoTableViewController;
@property (assign, nonatomic) JHTranslatedWindowController *translatedWindowController;

@property (retain, nonatomic) JHMatchInfoProcessor *matchInfoProcessor;
@property (retain, nonatomic) NSSet *localizableInfoSet;
@property (retain, nonatomic) NSArray *scanArray;

@end
