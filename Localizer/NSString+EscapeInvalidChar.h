//
//  NSString+EscapeInvalidChar.h
//  Localizer
//
//  Created by joehsieh on 12/10/30.
//
//

#import <Foundation/Foundation.h>

@interface NSString (EscapeInvalidChar)

- (NSString *)encodeInvalidChar;
- (NSString *)decodeInvalidChar;

@end
