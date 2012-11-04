/*
 JHMatchInfoTableView.m
 Copyright (C) 2012 Joe Hsieh
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "JHMatchInfoTableView.h"

@implementation JHMatchInfoTableView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        NSArray *headerNameArray = @[
            NSLocalizedString(@"key", @""),
            NSLocalizedString(@"translate string", @""),
            NSLocalizedString(@"comment", @""),
            NSLocalizedString(@"from", @"")
        ];
    
        //設定可以多選
        [self setAllowsMultipleSelection: YES];
        
        for (int i = 0; i < [self.tableColumns count] ; i++) {
            [[self.tableColumns objectAtIndex:i] setHeaderCell:[[[NSTableHeaderCell alloc] initTextCell:[headerNameArray objectAtIndex:i]] autorelease]];
        }
    }
    return self;
}

- (IBAction)delete:(id)sender
{    
    id <NSTableViewDelegateMatchInfoExtension> delegate = (id <NSTableViewDelegateMatchInfoExtension>)[self delegate];
    if ([delegate respondsToSelector:@selector(tableView:didDeleteMatchInfos:)]) {
        [delegate tableView:self didDeleteMatchInfos:nil];
    }
}

- (IBAction)copy:(id)sender
{
    id <NSTableViewDelegateMatchInfoExtension> delegate = (id <NSTableViewDelegateMatchInfoExtension>)[self delegate];
    if ([delegate respondsToSelector:@selector(tableView:didCopiedMatchInfosWithIndexes:)]) {
        [delegate tableView:self didCopiedMatchInfosWithIndexes:[self selectedRowIndexes]];
    }
}

- (IBAction)paste:(id)sender
{
    id <NSTableViewDelegateMatchInfoExtension> delegate = (id <NSTableViewDelegateMatchInfoExtension>)[self delegate];
    if ([delegate respondsToSelector:@selector(tableView:didPasteMatchInfosWithIndexes:)]) {
        [delegate tableView:self didPasteMatchInfosWithIndexes:[self selectedRowIndexes]];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    SEL action = [menuItem action];
    if (action == @selector(delete:)) {
        if (![[self selectedRowIndexes] count]) {
            return NO;
        }
        return YES;
    }
    else if (action == @selector(copy:)){
        return YES;
    }
    else if (action == @selector(paste:)){
        return YES;
    }
    
    return NO;
}

- (NSMenu *)menu
{
    NSMenu *menu = [[[NSMenu alloc] initWithTitle:NSLocalizedString(@"Context Menu", @"")] autorelease];
    [menu addItemWithTitle:NSLocalizedString(@"Delete", @"") action:@selector(delete:) keyEquivalent:@""];
    [menu addItemWithTitle:NSLocalizedString(@"Copy", @"") action:@selector(copy:) keyEquivalent:@""];
    [menu addItemWithTitle:NSLocalizedString(@"Paste", @"") action:@selector(paste:) keyEquivalent:@""];
    return menu;
}

@end
