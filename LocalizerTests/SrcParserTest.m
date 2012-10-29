//
//  SrcParserTest.m
//  Localizer
//
//  Created by KKBOX on 12/10/22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SrcParserTest.h"
#import "KKMatchInfo.h"
@implementation SrcParserTest
- (void)setUp
{
    [super setUp];
    srcParser = [[KKSourceCodeParser alloc] init];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    self.srcParser = nil;
    [super tearDown];
}

- (void)testParseSrcInFile
{
    KKMatchInfo *matchInfo1 = [[[KKMatchInfo alloc] init] autorelease];
    matchInfo1.key = @"test1";
    matchInfo1.translateString = @"";
    matchInfo1.comment = @"";
    matchInfo1.filePath = @"test";
    
    KKMatchInfo *matchInfo2 = [[[KKMatchInfo alloc] init] autorelease];
    matchInfo2.key = @"test2";
    matchInfo2.translateString = @"";
    matchInfo2.comment = @"";
    matchInfo2.filePath = @"test";
    
    KKMatchInfo *matchInfo3 = [[[KKMatchInfo alloc] init] autorelease];
    matchInfo3.key = @"test3";
    matchInfo3.translateString = @"";
    matchInfo3.comment = @"";
    matchInfo3.filePath = @"test";
    
    KKMatchInfo *matchInfo4 = [[[KKMatchInfo alloc] init] autorelease];
    matchInfo4.key = @"test4";
    matchInfo4.translateString = @"";
    matchInfo4.comment = @"";
    matchInfo4.filePath = @"test";
    
    KKMatchInfo *matchInfo5 = [[[KKMatchInfo alloc] init] autorelease];
    matchInfo5.key = @"test5";
    matchInfo5.translateString = @"";
    matchInfo5.comment = @"";
    matchInfo5.filePath = @"test";
    
    KKMatchInfo *matchInfo6 = [[[KKMatchInfo alloc] init] autorelease];
    matchInfo6.key = @"test6";
    matchInfo6.translateString = @"";
    matchInfo6.comment = @"";
    matchInfo6.filePath = @"test";
    
    KKMatchInfo *matchInfo7 = [[[KKMatchInfo alloc] init] autorelease];
    matchInfo7.key = @"test7";
    matchInfo7.translateString = @"";
    matchInfo7.comment = @"";
    matchInfo7.filePath = @"test";
    
    KKMatchInfo *matchInfo8 = [[[KKMatchInfo alloc] init] autorelease];
    matchInfo8.key = @"test8";
    matchInfo8.translateString = @"";
    matchInfo8.comment = @"";
    matchInfo8.filePath = @"test";
    
    NSError **error = nil;
    NSArray *actualResult = [NSArray arrayWithObjects:matchInfo1, matchInfo2, matchInfo3, matchInfo4, matchInfo5, matchInfo6, nil];
    NSString *fileContent = [NSString stringWithContentsOfFile:@"./LocalizerTests/test" encoding:NSUTF8StringEncoding error:error];
    
    NSArray * result = [self translateFromSetToAscendingArray:[srcParser parse:fileContent]];
    for (int i = 0 ; i < [result count]; i ++) {
        STAssertEqualObjects([result objectAtIndex:i],[actualResult objectAtIndex:i],@"");
    }
}

- (void)testParseSrcInDir
{
    
}

#pragma mark -  help function
- (NSArray *)translateFromSetToAscendingArray:(NSMutableSet *) inSet
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
    NSArray *result = [[inSet retain] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[sortDescriptor autorelease]]];
    return result;
}

@synthesize srcParser;
@end
