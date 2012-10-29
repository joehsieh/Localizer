#import <Cocoa/Cocoa.h>

@protocol NSTableViewDelegateScanFolderExtension <NSObject, NSTableViewDelegate>
- (void)tableView:(NSTableView *)inTableView didDeleteScanFoldersWithIndexes:(NSIndexSet *)inIndexes;
- (void)tableView:(NSTableView *)inTableView didOpenScanFoldersWithIndexes:(NSIndexSet *)inIndexes;
@end

@interface JHScanFoldersTableView : NSTableView

@end
