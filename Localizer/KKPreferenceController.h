//
//  KKPreferenceController.h
//  Localizer
//
//  Created by KKBOX on 12/10/26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKPreferenceController : NSObject
{
    IBOutlet NSWindow *window;
    IBOutlet NSTextField *message;
    IBOutlet NSTextField *subMessage;
}
-(IBAction)showPreference:(id)sender;
-(IBAction)clickCheckbox:(id)sender;

@property (assign, nonatomic) IBOutlet NSWindow *window;
@property (assign, nonatomic) IBOutlet NSTextField *message;
@property (assign, nonatomic) IBOutlet NSTextField *subMessage;
@end
