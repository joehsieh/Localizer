//
//  KKMatchInfoRecordColorTransformer.m
//  Localizer
//
//  Created by joehsieh on 12/10/20.
//
//

#import "JHMatchInfoRecordColorTransformer.h"
#import "JHMatchInfo.h"

@implementation JHMatchInfoRecordColorTransformer

+ (Class)transformedValueClass
{
    return [NSColor class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    NSInteger state = [value integerValue];
    
    switch (state) {
        case justInserted:
            return [NSColor blueColor];
        case notExist:
            return [NSColor redColor];
        case existing:
            return [NSColor blackColor];
        default:
            break;
    }
    return nil;
}

- (id)reverseTransformedValue:(id)value
{
    if (value == [NSColor blueColor]) {
        return [NSNumber numberWithInt:justInserted];
    }
    else if(value == [NSColor redColor]) {
        return [NSNumber numberWithInt:notExist];
    }
    else if(value == [NSColor blackColor]) {
        return [NSNumber numberWithInt:existing];
    }
    return nil;
}
@end
