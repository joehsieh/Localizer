//
//  KKMatchInfoProcessor.m
//  Localizer
//
//  Created by KKBOX on 12/10/26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JHMatchInfoProcessor.h"
#import "JHMatchInfo.h"
@implementation JHMatchInfoProcessor

- (NSArray *)mergeSetWithSrcInfoSet:(NSSet *)inSrcInfoSet withLocalizableInfoSet:(NSSet *)inLocalizableInfoSet withLocalizableFileExist:(BOOL)isLocalizableFileExist
{
    NSArray *result = nil;
    //同時有 localizable.strings 檔和 src 則 merge 兩者資料後回傳
    if (isLocalizableFileExist) {
        NSMutableArray *combinedResult = [NSMutableArray array];
        NSArray *addedSortedArray = [self getAddedSortedArray:inSrcInfoSet localizableInfoSet:inLocalizableInfoSet];
        NSArray *intersectArray = [self getIntersectArray:inSrcInfoSet localizableInfoSet:inLocalizableInfoSet];
        NSArray *noExistArray = [self getNoExistArray:inSrcInfoSet localizableInfoSet:inLocalizableInfoSet];
        [combinedResult addObjectsFromArray:addedSortedArray];
        [combinedResult addObjectsFromArray:intersectArray];
        [combinedResult addObjectsFromArray:noExistArray];
        
        result = combinedResult;
    }
    else{
        result = [inSrcInfoSet allObjects];
    }
    return result;
}

#pragma mark -  set operation
- (NSArray *)getAddedSortedArray:(NSSet *)inSrcInfoSet localizableInfoSet:(NSSet *)inLocalizableInfoSet
{
    NSMutableArray *result = [NSMutableArray array];
    
    NSArray *srcInfoArray = [NSArray arrayWithArray:[inSrcInfoSet allObjects]];
    NSArray *localizableInfoArray = [NSArray arrayWithArray:[inLocalizableInfoSet allObjects]];
    for (JHMatchInfo *srcInfoRecord in srcInfoArray) {
        BOOL isExist = NO;
        for (JHMatchInfo *localizableInfoRecord in localizableInfoArray) {
            if ([srcInfoRecord.key isEqualToString:localizableInfoRecord.key]) {
                isExist = ![localizableInfoRecord.filePath isEqualToString:@"Not exist"];
                break;
            }
        }
        if (!isExist) {
            srcInfoRecord.state = justInserted;
            [result addObject:srcInfoRecord];
        }
        
    }
    return result;
}

- (NSArray *)getIntersectArray:(NSSet *)inSrcInfoSet localizableInfoSet:(NSSet *)inLocalizableInfoSet
{
    NSMutableArray *result = [NSMutableArray array];
    
    NSArray *srcInfoArray = [NSArray arrayWithArray:[inSrcInfoSet allObjects]];
    NSArray *localizableInfoArray = [NSArray arrayWithArray:[inLocalizableInfoSet allObjects]];
    for (JHMatchInfo *localizableInfoRecord in localizableInfoArray) {
        for (JHMatchInfo *srcInfoRecord in srcInfoArray) {
            if ([localizableInfoRecord.key isEqualToString:srcInfoRecord.key] && ![localizableInfoRecord.filePath isEqualToString:@"Not exist"]) {
                [result addObject:localizableInfoRecord];
            }
        }
    }
    return result;
}

// matchInfo exist in localizable.strings but not in selected source code
- (NSArray *)getNoExistArray:(NSSet *)inSrcInfoSet localizableInfoSet:(NSSet *)inLocalizableInfoSet
{
    NSMutableArray *result = [NSMutableArray array];
    
    NSArray *srcInfoArray = [NSArray arrayWithArray:[inSrcInfoSet allObjects]];
    NSArray *localizableInfoArray = [NSArray arrayWithArray:[inLocalizableInfoSet allObjects]];
    for (JHMatchInfo *localizableInfoRecord in localizableInfoArray) {
        BOOL isExist = NO;
        for (JHMatchInfo *srcInfoRecord in srcInfoArray) {
            if ([localizableInfoRecord.key isEqualToString:srcInfoRecord.key]) {
                isExist = YES;
                break;
            }
        }
        if (!isExist) {
            localizableInfoRecord.state = notExist;
            localizableInfoRecord.filePath = @"Not exist";
            [result addObject:localizableInfoRecord];
        }
    }
    return result;
}

@end
