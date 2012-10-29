//
//  KKLocalizableSettingParser.m
//  Localizer
//
//  Created by joehsieh on 12/10/12.
//
//

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
        //將區塊中的資訊掃出來封裝進 KKMatchInfo
        [result addObjectsFromArray:[[self makeMatchRecord:belongFilePath bodyString:bodyString]allObjects]];
    }
    return result;
}

- (NSSet *)makeMatchRecord:(NSString *)belongFilePath bodyString:(NSString *)inBodyString
{
    NSError *matchError = nil;
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"\\s*\"(.*?)\"\\s*=\\s*\"(.*?)\"\\s*;\\s*(/\\*(.*?)\\*/)?" options:NSRegularExpressionDotMatchesLineSeparators error:&matchError];
    
    NSArray *matches = [regEx matchesInString:inBodyString options:0 range:NSMakeRange(0, [inBodyString length])];
    
    NSMutableSet *result = [NSMutableSet set];
    for (NSTextCheckingResult * match in matches) {                        
        NSString *key = [inBodyString substringWithRange:[match rangeAtIndex:1]];                                    
        NSString *translateString = [inBodyString substringWithRange:[match rangeAtIndex:2]];
        NSString *comment = nil;
        if ([match rangeAtIndex:4].location != NSNotFound) {
            comment = [[inBodyString substringWithRange:[match rangeAtIndex:4]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; 
        }
        else {
            comment = @"";
        }
        
        JHMatchInfo *matchInfo = [[[JHMatchInfo alloc] init] autorelease];
        
        [matchInfo setValue:[key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"key"];            
        [matchInfo setValue:[translateString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"translateString"];            
        [matchInfo setValue:[comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]  forKey:@"comment"];            
        [matchInfo setValue:[belongFilePath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"filePath"];
        
        [result addObject:matchInfo];
    }
    return result;
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


