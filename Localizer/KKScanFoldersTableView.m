#import "KKScanFoldersTableView.h"

@implementation KKScanFoldersTableView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
//        NSArray *headerNameArray = @[NSLocalizedString(@"source code file path", @"")];
        
        NSArray *headerNameArray = [NSArray arrayWithObject:NSLocalizedString(@"source code file path", @"")];
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
    id <NSTableViewDelegateScanFolderExtension> delegate = (id <NSTableViewDelegateScanFolderExtension>)[self delegate];
    if ([delegate respondsToSelector:@selector(tableView:didDeleteScanFoldersWithIndexes:)]) {
        NSInteger clickedRow = [self clickedRow];
        if (clickedRow != -1) {
            [delegate tableView:self didDeleteScanFoldersWithIndexes:[self selectedRowIndexes]];        
        }
    }
}

- (IBAction)openFileInFinder:(id)sender
{
    id <NSTableViewDelegateScanFolderExtension> delegate = (id <NSTableViewDelegateScanFolderExtension>)[self delegate];
    if ([delegate respondsToSelector:@selector(tableView:didOpenScanFoldersWithIndexes:)]) {
        NSInteger clickedRow = [self clickedRow];
        if (clickedRow != -1) {
            [delegate tableView:self didOpenScanFoldersWithIndexes:[NSIndexSet indexSetWithIndex:clickedRow]];
        }
        else {
            [delegate tableView:self didOpenScanFoldersWithIndexes:[self selectedRowIndexes]];
        }
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    NSInteger clickedRow = [self clickedRow];
    SEL action = [menuItem action];
    if (action == @selector(delete:)) {
        if (![[self selectedRowIndexes] count] && clickedRow == -1) {
            return NO;
        }
        return YES;
    }
    else if (action == @selector(openFileInFinder:)){
        return YES;
    }
    
    return NO;
}

- (NSMenu *)menu
{
    NSMenu *menu = [[[NSMenu alloc] initWithTitle:NSLocalizedString(@"Context Menu", @"")] autorelease];
    [menu addItemWithTitle:NSLocalizedString(@"Delete", @"") action:@selector(delete:) keyEquivalent:@""];
    [menu addItemWithTitle:NSLocalizedString(@"Open Folder in Finder", @"") action:@selector(openFileInFinder:) keyEquivalent:@""];
    return menu;
}

@end
