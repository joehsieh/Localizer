/*
 JHMatchInfoTableViewController.m
 Copyright (C) 2012 Joe Hsieh
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "JHMatchInfoTableViewController.h"
#import "ImageAndTextCell.h"
#import "JHMatchInfo.h"

@implementation JHMatchInfoTableViewController

- (void)dealloc
{
    [self stopObservingMatchInfoArray:[arrayController content]];
    self.arrayController = nil;
    [super dealloc];
}

#pragma mark -  NSTableViewDelegate
- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([tableColumn.identifier isEqualToString:@"key"] || [tableColumn.identifier isEqualToString:@"from"] ) {
        return NO;
    }
    return  YES;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{    
    if ([[tableColumn identifier] isEqualToString:@"from"]) {
        ImageAndTextCell *imageAndTextCell = (ImageAndTextCell *)cell;
        NSString *path = [imageAndTextCell stringValue];
        NSString *fileExtension = [path pathExtension];
        if ([fileExtension length]) {
            NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFileType:fileExtension];
            [icon setSize:NSMakeSize(10.0, 10.0)];
            [imageAndTextCell setImage:icon];
        }
        else {
            [imageAndTextCell setImage:nil];
        }
    }
}

#pragma mark -  NSTableViewDelegateMatchInfoExtension
- (void)tableView:(NSTableView *)inTableView didDeleteMatchInfos:(id)inSomething
{
    [self removeMatchInfoArray:[arrayController selectedObjects]]; 
}

- (void)tableView:(NSTableView *)inTableView didCopiedMatchInfosWithIndexes:(NSIndexSet *)inIndexes
{
    if ([[arrayController selectedObjects] count] != 0) {
        NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
        [pasteBoard clearContents];
        [pasteBoard writeObjects:[arrayController selectedObjects]];
        
    }
}

- (JHMatchInfo *)copiedMatchInfo:(JHMatchInfo *)inMatchInfo
{
    if ([arrayController.content containsObject:inMatchInfo]) {
        JHMatchInfo *matchInfo = [[[JHMatchInfo alloc] init] autorelease];
        matchInfo.key = [NSString stringWithFormat:@"%@ copy",inMatchInfo.key];
        matchInfo.translateString = inMatchInfo.translateString;
        matchInfo.comment = inMatchInfo.comment;
        matchInfo.filePath = inMatchInfo.filePath;
        JHMatchInfo *temp = [self copiedMatchInfo:matchInfo];
        if (temp == nil) {
            return matchInfo;
        }
        else{
            return temp;
        }
    }
    return nil;
}

- (void)tableView:(NSTableView *)inTableView didPasteMatchInfosWithIndexes:(NSIndexSet *)inIndexes
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSArray *classArray = [NSArray arrayWithObject:[JHMatchInfo class]];
    NSDictionary *options = [NSDictionary dictionary];
    
    BOOL ok = [pasteboard canReadObjectForClasses:classArray options:options];
    if (ok) {
        NSArray *objectsToPaste = [pasteboard readObjectsForClasses:classArray options:options];
        NSMutableArray *matchInfoArray = [NSMutableArray array];
        
        [objectsToPaste enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [matchInfoArray addObject:[self copiedMatchInfo:obj]];
        }];
        [self insetMatchInfoArray:matchInfoArray withIndex:[inIndexes firstIndex] + 1];
    }
}


- (void)reloadMatchInfoRecords:(NSArray *)inArray
{
    [self startObservingMatchInfoArray:inArray];
    arrayController.content = inArray;
    [self updateCount:inArray];
}

- (void)updateCount:(NSArray *)inArray
{
    NSUInteger translatedCount = 0;
    NSUInteger unTranslatedCount = 0;
    NSUInteger notExistCount = 0;
    
    for (JHMatchInfo *i in inArray) {
        switch (i.state) {
            case translated:
                translatedCount++;
                break;
            case unTranslated:
                unTranslatedCount++;
                break;
            case notExist:
                notExistCount++;
                break;
            default:
                break;
        }
    }
    [self willChangeValueForKey:@"translatedCountString"];
    translatedCountString = [NSString stringWithFormat:@"%ld", translatedCount];
    [self didChangeValueForKey:@"translatedCountString"];
        
    [self willChangeValueForKey:@"unTranslatedCountString"];
    unTranslatedCountString = [NSString stringWithFormat:@"%ld", unTranslatedCount];
    [self didChangeValueForKey:@"unTranslatedCountString"];
    
    [self willChangeValueForKey:@"notExistCountString"];
    notExistCountString = [NSString stringWithFormat:@"%ld", notExistCount];
    [self didChangeValueForKey:@"notExistCountString"];
}

#pragma mark -  redo/undo add/delete matchInfo record
- (void)removeMatchInfoArray:(NSArray *)matchInfoArray
{
    NSString *actionName = NSLocalizedString(@"Delete", @"");
    [self stopObservingMatchInfoArray:matchInfoArray];
    
    [[undoManager prepareWithInvocationTarget:self] restoreMatchinfoArray:[[[arrayController content]copy]autorelease]  actionName:actionName];
    if (!undoManager.isUndoing) {
        [undoManager setActionName:actionName];
    }
    
    NSMutableArray *result = [NSMutableArray arrayWithArray:arrayController.content];
    [result removeObjectsInArray:matchInfoArray];
    arrayController.content = result;
}

- (void)insetMatchInfoArray:(NSArray *)matchInfoArray withIndex:(NSUInteger)insertedIndex
{
    NSString *actionName = NSLocalizedString(@"Insert", @"");
    [self startObservingMatchInfoArray:matchInfoArray];
    
    [[undoManager prepareWithInvocationTarget:self] restoreMatchinfoArray:[[[arrayController content]copy]autorelease]  actionName:actionName];
    if (!undoManager.isUndoing) {
        [undoManager setActionName:actionName];
    }
    NSMutableArray *result = [NSMutableArray arrayWithArray:arrayController.content];
    [matchInfoArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result insertObject:obj atIndex:insertedIndex];
    }];
    arrayController.content = result;
}

- (void)restoreMatchinfoArray:(NSArray *)inArray actionName:(NSString *)inActionName
{
    [self updateCount:inArray];
    [self startObservingMatchInfoArray:inArray];
    
    [[undoManager prepareWithInvocationTarget:self] restoreMatchinfoArray:[[[arrayController content]copy]autorelease]  actionName:inActionName];
    if (!undoManager.isUndoing) {
        [undoManager setActionName:inActionName];
    }
    arrayController.content = inArray;
}

#pragma mark -  redo/undo edit match record
- (void)changeKeyPath:(NSString *)keyPath ofObject:(id)object toValue:(id)newValue
{
    [self updateCount:[NSArray arrayWithArray:arrayController.content]];
    [object setValue:newValue forKeyPath:keyPath];    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(JHMatchInfo *)object change:(NSDictionary *)change context:(void *)context
{
    id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
    [[undoManager prepareWithInvocationTarget:self] changeKeyPath:keyPath ofObject:object toValue:oldValue];
    if (!undoManager.isUndoing) {
        [undoManager setActionName:NSLocalizedString(@"Edit", @"")];
    }
    if ([object.key isEqualToString:object.translateString] || [object.key isEqualToString:@""]) {
        object.state = unTranslated;
    }
    else{
        object.state = translated;
    }
    [self updateCount:arrayController.content];
}

- (void)stopObservingMatchInfoArray:(NSArray *)inArray
{
    //移除 observing
    for (JHMatchInfo *matchInfo in [inArray retain]) {
        [matchInfo removeObserver:self forKeyPath:@"translateString"];
        [matchInfo removeObserver:self forKeyPath:@"comment"];
    }
}

- (void)startObservingMatchInfoArray:(NSArray *) inArray
{
    //加上 KVO 準備 Undo 用
    for (JHMatchInfo *matchInfo in [inArray retain]) {
        [matchInfo addObserver:self forKeyPath:@"translateString" options:NSKeyValueObservingOptionOld context:nil];
        [matchInfo addObserver:self forKeyPath:@"comment" options:NSKeyValueObservingOptionOld context:nil];
    }
}

#pragma mark -  others

- (NSArray *)sortedMatchInfoFilePathArray
{
    NSArray *filePaths = [[arrayController content] valueForKeyPath:@"filePath"];
    NSSet *filePathSet = [NSSet setWithArray:filePaths];
	return [[filePathSet allObjects] sortedArrayUsingSelector:@selector(compare:)];
}

- (NSArray *)matchInfoArray
{
    return arrayController.content;
}

- (NSString *)matchInfosString
{
    NSMutableString *resultString = [NSMutableString string];
    
    for (NSString *filePath in [self sortedMatchInfoFilePathArray]) {
        [resultString appendFormat:@"/* %@ */\n",filePath];
        for (JHMatchInfo *matchInfo in [self matchInfoArray]) {
            if ([[matchInfo filePath] isEqualToString:filePath]) {
                [resultString appendString:[NSString stringWithFormat:@"\"%@\" = \"%@\";/*%@*/ \n", matchInfo.key , matchInfo.translateString, matchInfo.comment]];
            }
        }
		[resultString appendString:@"\n\n"];
    }
    return resultString;
}

- (IBAction)fileterByType:(id)sender
{
     
    for (JHMatchInfo *matchInfo in arrayController.content) {
        if (matchInfo.state != unTranslated) {
             
        }
    }
}

@synthesize arrayController;
@synthesize undoManager;
@end
