//
//  JHTranslatedWindowController.h
//  Localizer
//
//  Created by KKBOX on 12/11/5.
//
//

#import <Cocoa/Cocoa.h>

@class JHTranslatedWindowController;
@protocol JHTranslatedWindowControllerDelegate <NSObject>
@required
- (void)windowController:(JHTranslatedWindowController *)inWindowController didMerge:(id)inSomething;
@end

@interface JHTranslatedWindowController : NSWindowController
{
    IBOutlet NSTextView *translatedView;
    IBOutlet NSButton *mergeButton;
    IBOutlet NSButton *closeButton;

    id <JHTranslatedWindowControllerDelegate> translatedWindowControllerDelegate;
}

- (IBAction)mergeTranslatedString:(id)sender;
- (IBAction)close:(id)sender;

@property (assign, nonatomic) IBOutlet NSTextView *translatedView;
@property (assign, nonatomic) IBOutlet NSButton *mergeButton;
@property (assign, nonatomic) IBOutlet NSButton *closeButton;

@property (assign, nonatomic) id<JHTranslatedWindowControllerDelegate> translatedWindowControllerDelegate;

@end
