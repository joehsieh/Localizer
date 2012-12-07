/*
 JHPreferenceController.m
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

#import "JHPreferenceController.h"
#import "JHSourceCodeParser.h"
@implementation JHPreferenceController

- (void)dealloc
{
    self.window = nil;
    self.message = nil;
    self.subMessage = nil;
    [super dealloc];
}

- (IBAction)showPreference:(id)sender
{
    if (!window) {
        [NSBundle loadNibNamed:@"JHPreference" owner:self];
        message.stringValue = NSLocalizedString(@"Fill translate string automatically.", @"");
        subMessage.stringValue = NSLocalizedString(@"localizer will fill untranslate string with key automatically.", @"");
    }
    if (![window isVisible]) {
        [window center];
    }
    [self.window makeKeyAndOrderFront:sender];
}

- (IBAction)clickCheckbox:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:(BOOL)[sender state] forKey:autoFillTranslateStr];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@synthesize window, message, subMessage;
@end
