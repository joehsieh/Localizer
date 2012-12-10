/*
 JHDocument.m
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

#import "JHDocument.h"
#import "JHSourceCodeParser.h"
#import "JHFilePathTableViewController.h"
#import "JHMatchInfo.h"
#import "JHLocalizableSettingParser.h"
#import "JHMatchInfoTableViewController.h"
#import "JHMatchInfoRecordColorTransformer.h"
#import "NSString+RelativePath.h"

@implementation JHDocument

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (void)dealloc
{
    self.filePathTableViewController = nil;
    self.matchInfoTableViewController = nil;
    self.translatedWindowController = nil;
    self.matchInfoProcessor = nil;
    self.localizableInfoSet = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Registering value transformers
        JHMatchInfoRecordColorTransformer *transformer = [[[JHMatchInfoRecordColorTransformer alloc] init] autorelease];
        [NSValueTransformer setValueTransformer:transformer forName:@"JHMatchInfoRecordColorTransformer"];

        matchInfoProcessor = [[JHMatchInfoProcessor alloc] init];
        // 預設自動填入翻譯字串
        // [[NSUserDefaults standardUserDefaults] setBool:YES forKey:autoFillTranslateStr];

    }
    return self;
}

#pragma mark -  override NSDocument

//在 saveToURL 中才可以得到即將要存入的檔案路徑
- (void)saveToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation completionHandler:(void (^)(NSError *))completionHandler
{
    [filePathTableViewController updateRelativeFilePathArrayWithNewBaseURL:url];

    [super saveToURL:url ofType:typeName forSaveOperation:saveOperation completionHandler:completionHandler];
}

//將檔案依照規定的格式寫入檔案中
- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(NSURL *)absoluteOriginalContentsURL error:(NSError **)outError
{
    NSMutableString *resultString = [NSMutableString string];

    //寫入 header 的 files 路徑字串和 body 的 matchInfos 字串
    [resultString appendFormat:@"%@%@", filePathTableViewController.relativeSourceFilepahtsStringRepresentation, matchInfoTableViewController.matchInfosString];

    BOOL boolResult = [resultString writeToURL:absoluteURL atomically:YES encoding:NSUTF8StringEncoding error:outError];

    //成功儲存完相關資料後，更新 localizable 的 set
    if (boolResult) {
		[self updateLocalizableSet];
	}

    return boolResult;
}

//讀入檔案，並且利用 parser 得到所要的資料
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    BOOL readSuccess = NO;
    //截取自 .strings 檔所讀出的 key value pair
    NSString *localizableFileContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (!localizableFileContent && outError) {
        *outError = [NSError errorWithDomain:NSCocoaErrorDomain
                                        code:NSFileReadUnknownError userInfo:nil];
    }
    if (localizableFileContent) {
        readSuccess = YES;
        // get localizable related info from Localizable.strings
        JHLocalizableSettingParser *localizableSettingParser = [[[JHLocalizableSettingParser alloc] init] autorelease];

        NSArray *tempScanArray = nil;
        NSSet *tempMatchRecordSet = nil;

        [localizableSettingParser parse:localizableFileContent scanFolderPathArray:&tempScanArray matchRecordSet:&tempMatchRecordSet];

        scanArray = [tempScanArray copy];
        localizableInfoSet = [tempMatchRecordSet copy];
    }
    [localizableFileContent release];

    return readSuccess;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
    [super windowControllerDidLoadNib:windowController];

    //將 undo manager 傳入 controller 讓 controller 可以自行 undo/redo
    [self.matchInfoTableViewController setUndoManager:[self undoManager]];
    [self.filePathTableViewController setUndoManager:[self undoManager]];

    //載入 matchInfoTable 中的資料
    [self.matchInfoTableViewController reloadMatchInfoRecords:[localizableInfoSet allObjects]];

    //載入 scan array 的資料
    [self.filePathTableViewController setSourceFilePaths:scanArray withBaseURL:[self fileURL]];

    translatedWindowController = [[JHTranslatedWindowController alloc] initWithWindowNibName:@"JHTranslatedWindow"];
    translatedWindowController.translatedWindowControllerDelegate = self;
}

- (NSString *)windowNibName
{
    return @"JHDocument";
}

#pragma mark - NSToolbarDelegate

- (void)toolbarWillAddItem:(NSNotification *)notification
{
    NSDictionary *toolbarItemNameDictionary = @{
        @"Add Scan Folders or Files": NSLocalizedString(@"Add Scan Folders or Files", @""),
        @"Scan":NSLocalizedString(@"Scan", @""),
        @"Update with Outside String":NSLocalizedString(@"Update with Outside String", @""),
        @"TranslatedCountString":NSLocalizedString(@"Translated", @""),
        @"UnTranslatedCountString":NSLocalizedString(@"UnTranslated", @""),
        @"NotExistCountString":NSLocalizedString(@"NotExist", @"")
    };

    NSToolbarItem *item = [notification.userInfo objectForKey:@"item"];
    item.label = [toolbarItemNameDictionary objectForKey:item.itemIdentifier];
}

#pragma mark -  button action

//加入檔案路徑的 action
- (IBAction)addScanFolderAndFiles:(id)sender
{
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:YES];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"h", @"m",@"mm", nil]];

	NSWindow *window = [[[self windowControllers] objectAtIndex:0] window];
	[openPanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
		if (result == NSOKButton) {
            NSMutableArray *pathsToAdd = [NSMutableArray array];
			NSSet *filePathSet = [NSSet setWithArray:self.filePathTableViewController.filePathArray];
			NSArray *URLs = openPanel.URLs;
			[URLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				if (![filePathSet containsObject:obj]) {
					[pathsToAdd addObject:obj];
				}
			}];
            [filePathTableViewController addFilePaths:pathsToAdd];
		}

	}];
}

//merge src 和 localizable.strings 的資料
- (IBAction)scan:(id)sender
{
    NSMutableSet *sourceCodeInfoSet = [NSMutableSet setWithSet:[self parseSourceCode:filePathTableViewController.filePathArray]];

    // merge src info set and localizable info set
    NSArray *result = [matchInfoProcessor mergeSetWithSrcInfoSet:sourceCodeInfoSet withLocalizableInfoSet:localizableInfoSet withLocalizableFileExist:([self fileURL] != nil)];

    // reload match info table view
    [self.matchInfoTableViewController reloadMatchInfoRecords:result];
}

- (IBAction)translate:(id)sender
{
    NSWindow *window = [[[self windowControllers] objectAtIndex:0] window];
    [NSApp beginSheet:translatedWindowController.window modalForWindow:window modalDelegate:nil didEndSelector:NULL contextInfo:nil];

}

#pragma mark - validate tool bar item

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
	SEL action = [theItem action];
	if (action == @selector(addScanFolderAndFiles:)) {
		return YES;
	}
	else if (action == @selector(scan:)) {
		return !![[self filePathTableViewController].filePathArray count];
	}
    else if (action == @selector(translate:)){
        return YES;
    }
	return [super validateToolbarItem:theItem];
}

#pragma mark - Others

- (NSSet *)parseSourceCode:(NSArray *)filePathArray
{
    NSMutableSet *sourceCodeInfoSet = [NSMutableSet set];
    JHSourceCodeParser *sourceCodeParser = [[JHSourceCodeParser alloc] init];
    for (NSURL *filePath in filePathArray) {
        [sourceCodeInfoSet unionSet: [sourceCodeParser parse:[filePath path]]];
    }
    [sourceCodeParser release];
    return sourceCodeInfoSet;
}

- (void)updateLocalizableSet
{
    NSArray *updatedLocalizableInfoArray = [NSArray arrayWithArray:matchInfoTableViewController.matchInfoArray];

    NSSet *temp = localizableInfoSet;
    localizableInfoSet = [[NSSet setWithArray:updatedLocalizableInfoArray] retain];
    [temp release];
}

- (void)windowController:(JHTranslatedWindowController *)inWindowController didMerge:(id)inSomething;
{
    NSUndoManager *undoManager = [self undoManager];
    NSString *inActionName = NSLocalizedString(@"Translate", @"");
    [[undoManager prepareWithInvocationTarget:matchInfoTableViewController] restoreMatchinfoArray:[[[matchInfoTableViewController.arrayController content]copy]autorelease]  actionName:inActionName];
    if (!undoManager.isUndoing) {
        [undoManager setActionName:NSLocalizedString(inActionName, @"")];
    }
    NSString *translatedContent = [NSString stringWithFormat:@"/* Not exist */ \n %@",translatedWindowController.translatedView.textStorage.string];

    // 在加入翻譯字串前，先將 localizanbleSet 更新到最新的狀態
    [self updateLocalizableSet];

    if (translatedContent && localizableInfoSet) {
        JHLocalizableSettingParser *localizableSettingParser = [[[JHLocalizableSettingParser alloc] init] autorelease];

        NSArray *tempScanArray = nil;
        NSSet *translatedMatchRecordSet = nil;

        [localizableSettingParser parse:translatedContent scanFolderPathArray:&tempScanArray matchRecordSet:&translatedMatchRecordSet];

        NSMutableArray *result = [NSMutableArray arrayWithArray:[localizableInfoSet allObjects]];

        [translatedMatchRecordSet enumerateObjectsUsingBlock:^(JHMatchInfo *obj, BOOL *stop) {
				//matchInfo 是以 key 為比對方式，key 相同就存在，在除了 key 以外的資訊有可能不同，所以採用 replace 的方式置換
				if ([localizableInfoSet containsObject:obj]) {
					NSUInteger index = [result indexOfObject:obj];

					JHMatchInfo *matchInfo = [result objectAtIndex:index];
					obj.filePath = matchInfo.filePath;

					if ([obj.key isEqualToString:obj.translateString]) {
						obj.state = unTranslated;
					}

					if ([obj.filePath isEqualToString:@"Not exist"]) {
						obj.state = notExist;
					}
					[result replaceObjectAtIndex:index withObject:obj];
				}
				else {
					obj.state = notExist;
					[result addObject:obj];
				}
			}];
        [matchInfoTableViewController reloadMatchInfoRecords:result];
    }
}

@synthesize filePathTableViewController, matchInfoTableViewController,translatedWindowController,
localizableInfoSet, scanArray, matchInfoProcessor;
@end
