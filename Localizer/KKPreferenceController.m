//
//  KKPreferenceController.m
//  Localizer
//
//  Created by KKBOX on 12/10/26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "KKPreferenceController.h"
#import "KKSourceCodeParser.h"
@implementation KKPreferenceController

-(IBAction)showPreference:(id)sender
{
    if (!window) {
        [NSBundle loadNibNamed:@"KKPreference" owner:self];
        message.stringValue = NSLocalizedString(@"Fill translate string automatically.", @"");
        subMessage.stringValue = NSLocalizedString(@"localizer will fill untranslate string with key automatically.", @"");
    }
    if (![window isVisible]) {
        [window center];
    }
    [self.window makeKeyAndOrderFront:sender];
}

-(IBAction)clickCheckbox:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:(BOOL)[sender state] forKey:autoFillTranslateStr];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@synthesize window, message, subMessage;
@end
