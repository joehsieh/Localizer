/*
 JHMatchInfoProcessor.m
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
    else {
        result = [inSrcInfoSet allObjects];
    }
    return result;
}

#pragma mark -  set operation

/*
 source code 和 localizable.strings 檔案的差集
 - 將差集後的每筆的結果標上藍色
 */
- (NSArray *)getAddedSortedArray:(NSSet *)inSrcInfoSet localizableInfoSet:(NSSet *)inLocalizableInfoSet
{
    NSMutableSet *mutableSrcInfoSet = [NSMutableSet setWithSet:inSrcInfoSet];
    [mutableSrcInfoSet minusSet:inLocalizableInfoSet];
    [mutableSrcInfoSet enumerateObjectsUsingBlock:^(JHMatchInfo *obj, BOOL *stop) {
        obj.state = unTranslated;
    }];

    return [mutableSrcInfoSet allObjects];
}

/*
 source code 和 localizable.strings 檔案的交集
 - 交集結果以 localizable.strings 的內容表達。
 - 交集時，若 matchInfo 中 file path 中不同時，則使用 source code 的 file path 更新 localizable.strings 中 matchInfo record 的 file path
 */
- (NSArray *)getIntersectArray:(NSSet *)inSrcInfoSet localizableInfoSet:(NSSet *)inLocalizableInfoSet
{
    NSMutableArray *result = [NSMutableArray array];

    NSArray *srcInfoArray = [NSArray arrayWithArray:[inSrcInfoSet allObjects]];
    NSArray *localizableInfoArray = [NSArray arrayWithArray:[inLocalizableInfoSet allObjects]];
    for (JHMatchInfo *localizableInfoRecord in localizableInfoArray) {
        for (JHMatchInfo *srcInfoRecord in srcInfoArray) {
            if ([localizableInfoRecord.key isEqualToString:srcInfoRecord.key]) {
                if (![localizableInfoRecord.filePath isEqualToString:srcInfoRecord.filePath]) {
                    //更新localizable.strings 中 matchInfo record 中的 file path
                    localizableInfoRecord.filePath = srcInfoRecord.filePath;
                }
                [result addObject:localizableInfoRecord];
            }
        }
    }
    return result;
}

/*
 localizable.strings 和 source code 檔案的差集
 - 將差集後的每筆的結果標上紅色並且將路徑由 source code 修改成 localizable.strings 的路徑
 */
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
