//
//  NSString+EscapeInvalidChar.m
//  Localizer
//
//  Created by joehsieh on 12/10/30.
//
//

#import "NSString+EscapeInvalidChar.h"

@implementation NSString (EscapeInvalidChar)

- (NSString *)encodeInvalidChar
{
    NSString *str = [NSString stringWithString:self];
    str = [str stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    return str;
}

- (NSString *)decodeInvalidChar
{
    NSString *str = [NSString stringWithString:self];
    str = [str stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
    str = [str stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    return str;
}

@end
