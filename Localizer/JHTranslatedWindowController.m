#import "JHTranslatedWindowController.h"

@implementation JHTranslatedWindowController

- (void)dealloc
{
    self.translatedView = nil;
    self.translatedWindowControllerDelegate = nil;
    [super dealloc];
}

- (void)awakeFromNib
{
    [[self window] setDefaultButtonCell:[mergeButton cell]];
}

- (IBAction)mergeTranslatedString:(id)sender
{
    if (self.translatedWindowControllerDelegate && [self.translatedWindowControllerDelegate respondsToSelector:@selector(windowController:didMerge:)]) {
        [self.translatedWindowControllerDelegate windowController:self didMerge:nil];
    }
}

- (IBAction)close:(id)sender
{
    [NSApp endSheet:[self window]];
    [[self window] orderOut:self];
}

@synthesize translatedView, mergeButton, closeButton;
@synthesize translatedWindowControllerDelegate;

@end
