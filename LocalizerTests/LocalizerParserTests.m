//
//  LocalizerTests.m
//  LocalizerTests
//
//  Created by KKBOX on 12/10/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LocalizerParserTests.h"
#import "KKMatchInfo.h"
@implementation LocalizerParserTests

- (void)setUp
{
    [super setUp];
    localizableSettingParser = [[KKLocalizableSettingParser alloc] init];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    self.localizableSettingParser = nil;
    [super tearDown];
}

- (void)testMakeScanArray
{
    NSArray *actualResult = [NSArray arrayWithObjects:@"Views/KKSearchField.m", @"Controllers/KKMainController+OutlineView.m", @"Controllers/KKMainController+PlaylistDescriptionExport.m", nil];
    NSError **error = nil;
    NSString *scanListString = [NSString stringWithContentsOfFile:@"./LocalizerTests/scanList" encoding:NSUTF8StringEncoding error:error];
    NSArray *result = [localizableSettingParser makeScanArray:scanListString];
    
    for (int i = 0; i < [actualResult count]; i++) {
        STAssertEqualObjects([[result objectAtIndex:i] relativePath], [actualResult objectAtIndex:i], @"");
    }
     
}
- (void)testSeperateScanListAndMatchInfoBolckBody
{
//    NSString *matchInfoTotalBlockString = @"/* Classes/KKMacPlayerPolicy.m */\n\"Please login.\" = \"请先登录\"; /* */ \n\"You need to login to play the online music.\" = \"您必须先登录，才能够播放KKBOX在线音乐。\";/**/ \n\"Your offline cache expired\" = \"您的离线档案已经过期了\";/**/ \n\n\n/*AutoUpdate/KKAutoUpdateController.m*/\n\"Major Software Update Required.\" = \"KKBOX必须进行软件更新\";/*軟體需要更新的註解\"quotesComment\"*/ \n\"Quit\" = \"/* 退出 */\";/**/ \n\"Update\" = \"更新/* 更新 */\";/*更新的註解*/\n\"Major Software Update Required.\" = \"KKBOX必须进行软件更新\";/*軟體需要更新的註解\"quotesComment\"*/";
    
    NSError **error = nil;
    
    NSString *fileContent = [NSString stringWithContentsOfFile:@"./LocalizerTests/LocalizableTest1.strings" encoding:NSUTF8StringEncoding error:error];
    NSDictionary *result = [localizableSettingParser seperateMatchInfoTotalBlockAndScanListString:fileContent];
   
    STAssertEqualObjects([result objectForKey:@"scanListString"], @"Classes/KKMacPlayerPolicy.m", @"");
//    STAssertEqualObjects([result objectForKey:@"matchInfoTotalBlockString"], matchInfoTotalBlockString, @"");    
}

#pragma mark -  test file path header exist and non-exsit condition
- (void)testExistPathInfoFile
{
    KKMatchInfo *matchInfo1 = [[KKMatchInfo alloc] init];
    matchInfo1.key = @"Major Software Update Required.";
    matchInfo1.translateString = @"KKBOX必须进行软件更新";
    matchInfo1.comment = @"軟體需要更新的註解\"quotesComment\"";
    matchInfo1.filePath = @"AutoUpdate/KKAutoUpdateController.m";
    
    KKMatchInfo *matchInfo2 = [[KKMatchInfo alloc] init];
    matchInfo2.key = @"Update";
    matchInfo2.translateString = @"更新/* 更新 */";
    matchInfo2.comment = @"更新的註解";
    matchInfo2.filePath = @"AutoUpdate/KKAutoUpdateController.m";
    
    KKMatchInfo *matchInfo3 = [[KKMatchInfo alloc] init];
    matchInfo3.key = @"Quit";
    matchInfo3.translateString = @"/* 退出 */";
    matchInfo3.comment = @"";
    matchInfo3.filePath = @"AutoUpdate/KKAutoUpdateController.m";
    
    //next file
    KKMatchInfo *matchInfo4 = [[KKMatchInfo alloc] init];
    matchInfo4.key = @"Please login.";
    matchInfo4.translateString = @"请先登录";
    matchInfo4.comment = @"";
    matchInfo4.filePath = @"Classes/KKMacPlayerPolicy.m";
    
    KKMatchInfo *matchInfo5 = [[KKMatchInfo alloc] init];
    matchInfo5.key = @"You need to login to play the online music.";
    matchInfo5.translateString = @"您必须先登录，才能够播放KKBOX在线音乐。";
    matchInfo5.comment = @"";
    matchInfo5.filePath = @"Classes/KKMacPlayerPolicy.m";
    
    KKMatchInfo *matchInfo6 = [[KKMatchInfo alloc] init];
    matchInfo6.key = @"Your offline cache expired";
    matchInfo6.translateString = @"您的离线档案已经过期了";
    matchInfo6.comment = @"";
    matchInfo6.filePath = @"Classes/KKMacPlayerPolicy.m";
    
    NSArray *actualResult = [NSArray arrayWithObjects:[matchInfo1 autorelease], [matchInfo2 autorelease], [matchInfo3 autorelease], [matchInfo4 autorelease], [matchInfo5 autorelease], [matchInfo6 autorelease], nil];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
    actualResult = [actualResult sortedArrayUsingDescriptors:[NSArray arrayWithObject:[sortDescriptor autorelease]]];
    
    NSError **error = nil;
    
    NSString *fileContent = [NSString stringWithContentsOfFile:@"./LocalizerTests/LocalizableTest1.strings" encoding:NSUTF8StringEncoding error:error];
    NSDictionary *dictionary = [[localizableSettingParser parse:fileContent] retain];
    NSMutableSet *matchRecordSet = [dictionary objectForKey:@"matchRecordSet"];
    
    NSArray *result = [self translateFromSetToAscendingArray:matchRecordSet];
    
    for (int i = 0; i < [actualResult count]; i++) {
        STAssertEqualObjects([[result objectAtIndex:i] description], [[actualResult objectAtIndex:i] description], @"");
    }
    [dictionary release];
    
}

- (void)testWithoutPathInfoFile
{
    KKMatchInfo *matchInfo1 = [[KKMatchInfo alloc] init];
    matchInfo1.key = @"Major Software Update Required.";
    matchInfo1.translateString = @"KKBOX必须进行软件更新";
    matchInfo1.comment = @"軟體需要更新的註解\"quotesComment\"";
    matchInfo1.filePath = @"AutoUpdate/KKAutoUpdateController.m";
    
    KKMatchInfo *matchInfo2 = [[KKMatchInfo alloc] init];
    matchInfo2.key = @"Update";
    matchInfo2.translateString = @"更新/* 更新 */";
    matchInfo2.comment = @"更新的註解";
    matchInfo2.filePath = @"AutoUpdate/KKAutoUpdateController.m";
    
    KKMatchInfo *matchInfo3 = [[KKMatchInfo alloc] init];
    matchInfo3.key = @"Quit";
    matchInfo3.translateString = @"/* 退出 */";
    matchInfo3.comment = @"";
    matchInfo3.filePath = @"AutoUpdate/KKAutoUpdateController.m";
    
    //next file
    KKMatchInfo *matchInfo4 = [[KKMatchInfo alloc] init];
    matchInfo4.key = @"Please login.";
    matchInfo4.translateString = @"请先登录";
    matchInfo4.comment = @"";
    matchInfo4.filePath = @"Classes/KKMacPlayerPolicy.m";
    
    KKMatchInfo *matchInfo5 = [[KKMatchInfo alloc] init];
    matchInfo5.key = @"You need to login to play the online music.";
    matchInfo5.translateString = @"您必须先登录，才能够播放KKBOX在线音乐。";
    matchInfo5.comment = @"";
    matchInfo5.filePath = @"Classes/KKMacPlayerPolicy.m";
    
    KKMatchInfo *matchInfo6 = [[KKMatchInfo alloc] init];
    matchInfo6.key = @"Your offline cache expired";
    matchInfo6.translateString = @"您的离线档案已经过期了";
    matchInfo6.comment = @"";
    matchInfo6.filePath = @"Classes/KKMacPlayerPolicy.m";
    
    NSArray *actualResult = [NSArray arrayWithObjects:[matchInfo1 autorelease], [matchInfo2 autorelease], [matchInfo3 autorelease], [matchInfo4 autorelease], [matchInfo5 autorelease], [matchInfo6 autorelease], nil];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
    actualResult = [actualResult sortedArrayUsingDescriptors:[NSArray arrayWithObject:[sortDescriptor autorelease]]];
    
    NSError **error = nil;
    
    NSString *fileContent = [NSString stringWithContentsOfFile:@"./LocalizerTests/LocalizableTest2.strings" encoding:NSUTF8StringEncoding error:error];
    NSDictionary *dictionary = [[localizableSettingParser parse:fileContent] retain];
    NSMutableSet *matchRecordSet = [dictionary objectForKey:@"matchRecordSet"];
    NSArray *result = [self translateFromSetToAscendingArray:matchRecordSet];
    
    for (int i = 0; i < [actualResult count]; i++) {
        STAssertEqualObjects([[result objectAtIndex:i] description], [[actualResult objectAtIndex:i] description], @"");
    } 
    [dictionary release];
}
#pragma mark -  help function
- (NSArray *)translateFromSetToAscendingArray:(NSMutableSet *) inSet
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
    NSArray *result = [[inSet retain] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[sortDescriptor autorelease]]];
    return result;
}
@synthesize localizableSettingParser;
@end
