//
//  KKMatchInfo.m
//  Localizer
//
//  Created by KKBOX on 12/10/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "KKMatchInfo.h"
NSString *const KKMatchInfoUTI = @"com.joehsieh.KKMatchInfo";
@implementation KKMatchInfo

- (void)dealloc
{
    self.key = nil;
    self.translateString = nil;
    self.comment = nil;
    self.filePath = nil;
    [super dealloc];
}

-(BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    if ([[self key] isEqualToString:[(KKMatchInfo *)object key]]) {
        return YES;
    }
    return NO;
}

-(NSUInteger)hash
{
    NSUInteger hash = 1;
    hash = hash * 17 +key.hash;
    return hash;
}


- (id)copyWithZone:(NSZone *)zone
{
    KKMatchInfo *copy = [[[self class] allocWithZone: zone] init];
    copy.key = key;
    copy.translateString = translateString;
    copy.comment = comment;
    copy.filePath = filePath;
    
    return copy;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"<KKMatchInfo: key: %@, translateString: %@, comment: %@, filePath: %@>",
            [self key], [self translateString], [self comment], [self filePath]];
}

- (MatchInfoRecordState)state
{
    if (state == justInserted) {
        return justInserted;
    }
    if ([filePath isEqualToString:@"Not exist"]) {
        return notExist;
    }
    return existing;
}

- (void)setState:(MatchInfoRecordState)inState
{
    state = inState;
}

#pragma mark - NSPasteboardWriting
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    static NSArray *writableTypes = nil;
    
    if (!writableTypes) {
        writableTypes = [[NSArray alloc] initWithObjects:KKMatchInfoUTI, nil];
    }
    return writableTypes;
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    
    if ([type isEqualToString:KKMatchInfoUTI]) {
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }
    
    return nil;
}

#pragma mark - NSPasteboardReading
+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    
    static NSArray *readableTypes = nil;
    if (!readableTypes) {
        readableTypes = [[NSArray alloc] initWithObjects:KKMatchInfoUTI, nil];
    }
    return readableTypes;
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard {
    if ([type isEqualToString:KKMatchInfoUTI]) {
        return NSPasteboardReadingAsKeyedArchive;
    }
    return 0;
}

#pragma mark- NSCoding
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.key forKey:@"kKey"];
    [coder encodeObject:self.translateString forKey:@"kTranslateString"];
    [coder encodeObject:self.comment forKey:@"kComment"];
    [coder encodeObject:self.filePath forKey:@"kFilePath"];    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        key = [[aDecoder decodeObjectForKey:@"kKey"] retain];
        translateString = [[aDecoder decodeObjectForKey:@"kTranslateString"] retain];
        comment = [[aDecoder decodeObjectForKey:@"kComment"] retain];
        filePath = [[aDecoder decodeObjectForKey:@"kFilePath"] retain];
    }
    
    return self;
}
@synthesize key, translateString, comment, filePath;
@end
