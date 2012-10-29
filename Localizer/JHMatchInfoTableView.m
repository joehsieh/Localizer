//
//  KKMatchInfoTableView.m
//  Localizer
//
//  Created by KKBOX on 12/10/24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

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
    if ([delegate respondsToSelector:@selector(tableView:didDeleteMatchInfosWithIndexes:)]) {
        [delegate tableView:self didDeleteMatchInfosWithIndexes:[self selectedRowIndexes]];
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
    if ([delegate respondsToSelector:@selector(tableView:didPasteMatchInfos:)]) {
        [delegate tableView:self didPasteMatchInfos:[self selectedRowIndexes]];
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
