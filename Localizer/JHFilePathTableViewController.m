/*
 JHFilePathTableViewController.m
 Copyright (C) 2012 Joe Hsieh
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "JHFilePathTableViewController.h"
#import "NSString+RelativePath.h"

@interface JHFilePathTableViewController(Privates)
- (void)restoreFilePathArray:(NSArray *)inArray actionName:(NSString *)inActionName;
- (NSArray *)translateRelativePathToAbsolutePath:(NSArray *)inArray withBasePath:(NSString *)inBasePath;
- (void)reloadSourceFilePaths;
@end

@implementation JHFilePathTableViewController(Privates)

- (void)restoreFilePathArray:(NSArray *)inArray actionName:(NSString *)inActionName
{
    [[undoManager prepareWithInvocationTarget:self] restoreFilePathArray:[[filePathArray copy] autorelease]  actionName:inActionName];
    if (!undoManager.isUndoing) {
        [undoManager setActionName:NSLocalizedString(inActionName, @"")];
    }
    [filePathArray setArray:inArray];
    [self reloadSourceFilePaths];
}

- (NSArray *)translateRelativePathToAbsolutePath:(NSArray *)inArray withBasePath:(NSString *)inBasePath
{
    NSMutableArray *result = [NSMutableArray array];
    for (NSURL *url in inArray) {
        NSURL *completedURL = nil;
        if (inBasePath) {
            completedURL = [NSURL URLWithString:[[[url relativePath] absolutePathFromBaseDirPath:inBasePath] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        }
        else{
            completedURL = url;
        }
        
        if (!completedURL) {
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Invalid scan list", @"") defaultButton:NSLocalizedString(@"OK", @"") alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
            [alert runModal];
            return result;
        }
        [result addObject:completedURL];
    }
    return result;
}

- (void)reloadSourceFilePaths
{
    [(NSTableView *)self.view reloadData];
}


@end

@implementation JHFilePathTableViewController

- (void)dealloc
{
	[filePathArray release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        if (!filePathArray) {
			filePathArray = [[NSMutableArray alloc] init];
        }
    }    
    return self;
}

- (void)awakeFromNib
{
	// Register to accept filename drag/drop
	[self.view registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    NSTableView *tableView = (NSTableView *)self.view;
    NSTableColumn *column = [tableView tableColumnWithIdentifier:@"path"];
    [column setEditable:NO];
    NSBrowserCell *cell = [[[NSBrowserCell alloc] init] autorelease];
    [column setDataCell:cell];
}

#pragma mark -  NSTableView DataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [filePathArray count];
}
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{    
    //依據檔案的路徑拿到該檔案的
    if ([[tableColumn identifier] isEqualToString:@"path"]) {
        NSString *filePath = [[tableColumn dataCellForRow:row] title];
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:filePath];
        [icon setSize:NSMakeSize(16.0,16.0)];
        
        NSBrowserCell *browserCell = (NSBrowserCell *)cell;
        [browserCell setLeaf:YES];
        NSImage *image = [NSImage imageNamed:NSImageNameFolder];
        [image setSize:NSMakeSize(16, 16)];
        [browserCell setImage:image];
    }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [[filePathArray  objectAtIndex:row] path];
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
    NSPasteboard *pb = [info draggingPasteboard];
    NSArray *array = [pb propertyListForType:NSFilenamesPboardType];
    
    //由 NSString 轉成 NSURL
    NSMutableArray *resultArray = [NSMutableArray array];
    for (NSString *s in array) {
        BOOL isDir;  
        [[NSFileManager defaultManager] fileExistsAtPath:s isDirectory:&isDir];
        NSURL *temp = [NSURL fileURLWithPath:s];    
        //只能拖入副檔名是 h, m 或是 mm 的原始碼檔案
        if ([[temp pathExtension] isEqualToString:@"h"] || [[temp pathExtension] isEqualToString:@"m"] || [[temp pathExtension] isEqualToString:@"mm"] || isDir) {
             [resultArray addObject:temp];
        }
        else {
            [resultArray removeAllObjects];
            break;
        }
    }
    [filePathArray addObjectsFromArray:resultArray];
 
    [(NSTableView *)self.view reloadData];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{    
    return NSDragOperationCopy;
}

#pragma mark -  NSTableViewDelegateScanFolderExtension
- (void)tableView:(NSTableView *)inTableView didDeleteScanFoldersWithIndexes:(NSIndexSet *)inIndexes
{    
    [self removeFilePaths:[filePathArray objectsAtIndexes:inIndexes]];
}

- (void)tableView:(NSTableView *)inTableView didOpenScanFoldersWithIndexes:(NSIndexSet *)inIndexes
{
    [inIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSDictionary* errors = [NSDictionary dictionary];
        NSAppleScript* appleScript = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"tell application \"Finder\" \n open (\"%@\" as POSIX file) \n end tell",[filePathArray objectAtIndex:idx]]];
        [appleScript executeAndReturnError:&errors];
        [appleScript release];
    }];
}

#pragma mark -  redo/undo add/delete src file paths

- (void)addFilePaths:(NSArray *)inArray
{
    NSString *actionName = NSLocalizedString(@"Add Src Path", @"");
    [[undoManager prepareWithInvocationTarget:self] restoreFilePathArray:[[filePathArray copy] autorelease]  actionName:actionName];
    if (!undoManager.isUndoing) {
        [undoManager setActionName:actionName];
    }
	[self willChangeValueForKey:@"filePathArray"];
    [filePathArray addObjectsFromArray:inArray];
    [self didChangeValueForKey:@"filePathArray"];
    [self reloadSourceFilePaths];
}
- (void)removeFilePaths:(NSArray *)inArray
{
    NSString *actionName = NSLocalizedString(@"Remove Src Path", @"");
    [[undoManager prepareWithInvocationTarget:self] restoreFilePathArray:[[filePathArray copy] autorelease] actionName:actionName];
    if (!undoManager.isUndoing) {
        [undoManager setActionName:actionName];
    }
	[self willChangeValueForKey:@"filePathArray"];
    [filePathArray removeObjectsInArray:inArray];
    [self didChangeValueForKey:@"filePathArray"];
    [self reloadSourceFilePaths];
}

- (void)setSourceFilePaths:(NSArray *)inArray withBaseURL:(NSURL *)baseURL
{
	[self willChangeValueForKey:@"filePathArray"];
	[filePathArray setArray:[self translateRelativePathToAbsolutePath:inArray withBasePath:[baseURL path]]];
    [self didChangeValueForKey:@"filePathArray"];
    [self reloadSourceFilePaths];
}

#pragma mark -  absolute relative path operation

- (void)updateRelativeFilePathArrayWithNewBaseURL:(NSURL *)baseURL
{
    if (![baseURL path]) {
        //如果沒有基礎的路徑可以轉換出相對路徑，就回傳絕對路徑
        relativeFilePathArray = filePathArray;
    }
    NSMutableArray *result = [NSMutableArray array];
    for (NSURL *i in filePathArray) {
        [result addObject:[NSURL URLWithString:[[i.relativePath relativePathFromBaseDirPath:[baseURL path]] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    }
    relativeFilePathArray = result;
}

#pragma mark -  others

- (NSArray *)filePathsAtIndexes:(NSIndexSet *)indexSet
{
    return [self.filePathArray objectsAtIndexes:indexSet];
}


- (NSString *)relativeSourceFilepahtsStringRepresentation
{
    NSMutableString *resultString = [NSMutableString string];
    [resultString appendString:@"/*\nScan List\n"];
	for (NSURL *fileURL in relativeFilePathArray) {
		[resultString appendFormat:@"%@%@\n", [fileURL path], fileURL == [relativeFilePathArray lastObject] ? @"": @","];
	}
    [resultString appendString:@"*/\n"];
    
    return resultString;
}

@synthesize filePathArray, relativeFilePathArray;
@synthesize undoManager;
@end
