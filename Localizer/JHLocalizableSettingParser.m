/*
 JHLocalizableSettingParser.m
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

#import "JHLocalizableSettingParser.h"
#import "JHMatchInfo.h"

@interface JHLocalizableSettingParser()
//測試用
- (void)seperateFileContent:(NSString *)inFileContent header:(out NSString **)outHeader body:(out NSString **)outBody;
- (NSMutableArray *)scanFolderPathsFromString:(NSString *)inScanFolders;
@end

@implementation JHLocalizableSettingParser

- (void)parse:(NSString *)fileContent scanFolderPathArray:(out NSArray **)outArray matchRecordSet:(out NSSet **)outSet
{
    NSString *body = nil;
    NSString *header = nil;
    //將 key, translatedString, comment 和 from 的所有區塊和 scan list 分離
    [self seperateFileContent:fileContent header:&header body:&body];

    //copy on modification
    *outArray = [self scanFolderPathsFromString:header];
    *outSet = [self matchInfoRecordsFromString:body];
}

- (NSArray *)scanFolderPathsFromString:(NSString *)inFolderPaths
{
    if (![inFolderPaths length]) {
        return [NSArray array];
    }
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *folderPath in [inFolderPaths componentsSeparatedByString:@","]) {
        folderPath = [folderPath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([folderPath length]) {
            NSURL *fileURL = [NSURL fileURLWithPath:folderPath];
            [result addObject:fileURL];
        }
    }
    return result;
}

- (NSSet *)matchInfoRecordsFromString:(NSString *)inMatchInfosString
{
    NSMutableSet *result = [NSMutableSet set];

    if (![inMatchInfosString length]) {
        return result;
    }

    NSError *matchError = nil;

    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"/\\*(.*?)\\*/(.*?)\n(?=(/\\*(.*?)\\*/))" options:NSRegularExpressionDotMatchesLineSeparators error:&matchError];

    /* 得到所有的 key, translatedString, comment 還有資料來源後，將資料再分成許多獨立的區塊

     資訊來源
     key = translatedString; comment

     same pattern...
     */
    NSArray *matches = [regEx matchesInString:inMatchInfosString options:0 range:NSMakeRange(0, [inMatchInfosString length])];
    for (NSTextCheckingResult * i in matches) {
        NSString *belongFilePath = [inMatchInfosString substringWithRange:[i rangeAtIndex:1]];
        NSString *bodyString = [inMatchInfosString substringWithRange:[i rangeAtIndex:2]];
        //將區塊中的資訊掃出來封裝進 JHMatchInfo
        NSMutableSet *matchInfoSet = [NSMutableSet setWithSet:[self makeMatchRecord:belongFilePath bodyString:bodyString]];
        [matchInfoSet unionSet:result];
        result = matchInfoSet;
    }
    return result;
}

- (NSSet *)makeMatchRecord:(NSString *)belongFilePath bodyString:(NSString *)inBodyString
{
    NSError *matchError = nil;
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"\\s*\"(.*?)\"\\s*=\\s*\"(.*?)\"\\s*;\\s*(/\\*(.*?)\\*/)?" options:NSRegularExpressionDotMatchesLineSeparators error:&matchError];

    NSArray *matches = [regEx matchesInString:inBodyString options:0 range:NSMakeRange(0, [inBodyString length])];

    NSMutableArray *result = [NSMutableArray array];
    for (NSTextCheckingResult * match in matches) {
        NSString *key = [inBodyString substringWithRange:[match rangeAtIndex:1]];
        NSString *translateString = [inBodyString substringWithRange:[match rangeAtIndex:2]];
        NSString *comment = nil;
        if ([match rangeAtIndex:4].location != NSNotFound) {
            comment = [inBodyString substringWithRange:[match rangeAtIndex:4]] ;
        }
        else {
            comment = @"";
        }

        JHMatchInfo *matchInfo = [[[JHMatchInfo alloc] init] autorelease];

        [matchInfo setValue:key forKey:@"key"];
        [matchInfo setValue:translateString forKey:@"translateString"];
        [matchInfo setValue:comment forKey:@"comment"];
        // file path will be trimmed
        [matchInfo setValue:[belongFilePath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"filePath"];

        // seperate translated string, untranslated string and not exist
        if ([key isEqualToString:translateString] || [key isEqualToString:@""]) {
            matchInfo.state = unTranslated;
        }
        else {
            matchInfo.state = translated;
        }
        if ([matchInfo.filePath isEqualToString:@"Not exist"]) {
            matchInfo.state = notExist;
        }
        //matchInfo 是以 key 為比對方式，key 相同就存在，在除了 key 以外的資訊有可能不同，所以採用 replace 的方式置換
        if ([result containsObject:matchInfo]) {
            NSUInteger index = [result indexOfObject:matchInfo];
            [result replaceObjectAtIndex:index withObject:matchInfo];
        }
        else {
            [result addObject:matchInfo];
        }
    }
    return [NSSet setWithArray:result];
}

- (void)seperateFileContent:(NSString *)inFileContent header:(out NSString **)outHeader body:(out NSString **)outBody
{
    if ([inFileContent length] == 0) {
        return ;
    }

    NSString *scanListString = nil;
    NSString *matchInfoTotalBlockString = nil;

    //先將 fileContent 加一個終止的標籤 方便掃瞄
    inFileContent = [inFileContent stringByAppendingString:@"\n/*end*/"];
    NSError *matchError = nil;

    //如果檔案內有 scan list 則將 Localizable.strings 的檔案內容分割成 scanList 和"其他內容"兩個區塊
    NSRegularExpression *regExWithScanList = [NSRegularExpression regularExpressionWithPattern:@"/\\*[\\s\n]*Scan[\\s\n]*List(.*?)\\*/\n+(.*)" options:NSRegularExpressionDotMatchesLineSeparators error:&matchError];
    NSTextCheckingResult *checkingResultWithScanList = [regExWithScanList firstMatchInString:inFileContent options:0 range:NSMakeRange(0, [inFileContent length])];

    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"/\\*(.*?)\\*/(.*)" options:NSRegularExpressionDotMatchesLineSeparators error:&matchError];
    NSTextCheckingResult *checkingResult = [regEx firstMatchInString:inFileContent options:0 range:NSMakeRange(0, [inFileContent length])];

    if (checkingResultWithScanList) { //Localizable.strings 檔案中有 scanList 的資訊
        scanListString = [[inFileContent substringWithRange:[checkingResultWithScanList rangeAtIndex:1]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        matchInfoTotalBlockString = [inFileContent substringWithRange:[checkingResultWithScanList rangeAtIndex:2]];

        *outBody = matchInfoTotalBlockString;
        *outHeader = scanListString;
    }
    else if (checkingResult) { //Localizable.strings 舊有的格式
        *outBody = inFileContent;
        *outHeader = @"";
    }
    else { //兩種格式都不符合丟出格式不符的例外
        [NSException raise:@"InvalidFileFormatError" format:@"Localizable file format is not valid"];
    }
}
@end
