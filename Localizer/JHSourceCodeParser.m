/*
 JHSourceCodeParser.m
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

#import "JHSourceCodeParser.h"
#import "JHMatchInfo.h"

NSString *const JHAutoFillTranslationPreferenceKey = @"autoFillTranslateStr";

@implementation JHSourceCodeParser

static NSSet *makeMatchInfoSet(NSString *pattern, NSString *fileContent, NSString *filePath)
{
    NSError *matchError = nil;
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&matchError];
    NSArray *matches = [regEx matchesInString:fileContent options:0 range:NSMakeRange(0, [fileContent length])];
    NSMutableSet *result = [[[NSMutableSet alloc] init] autorelease];

    for (NSTextCheckingResult * i in matches) {
        NSString *key = [fileContent substringWithRange:[i rangeAtIndex:1]];
        NSString *comment = @"";

        /* NSTextCheckingResult 中的 numberOfRanges 預設就有一個也就是 rangeAtIndex:0 就是 range
         因此如果 capture groups 有 2 個則 numberOfRanges 是 3 而不是 2
         註：LFLSTR 有 key 一個 capture group，而  有 key 和 comment 兩個 capture groups
         */
        if ([i numberOfRanges] == 3) {
            comment = [fileContent substringWithRange:[i rangeAtIndex:2]];
        }
        else {
            comment = @"";
        }
        JHMatchInfo *matchInfo = [[JHMatchInfo alloc] init];
        matchInfo.key = key;

        //檢查 userDefault 如果 autoFillTranslateStr 是打開的則 translate string 自動填入 key

        if ([[NSUserDefaults standardUserDefaults] boolForKey:JHAutoFillTranslationPreferenceKey]) {
            matchInfo.translateString = matchInfo.key;
        }
        else {
            matchInfo.translateString = @"";
        }
        matchInfo.comment = comment;
        matchInfo.filePath = filePath;

        [result addObject:[matchInfo autorelease]];
    }
    return result;
}

static NSSet *parseFile(NSString *baseFilePath, NSString *extFilePath, NSError **error)
{
    NSError *e = nil;

    NSMutableSet *result = [NSMutableSet set];
    NSString *absoluteFilePath = [baseFilePath stringByAppendingPathComponent:extFilePath];

    BOOL isDir = NO;
    // Because we used GTMUILocalizer, so we must maintain key in xib.
    [[NSFileManager defaultManager] fileExistsAtPath:absoluteFilePath isDirectory:&isDir];
    if ([[NSArray arrayWithObjects:@"h", @"m", @"mm", @"xib", nil] containsObject:[absoluteFilePath pathExtension]] || isDir) {
        NSString *fileContent = [NSString stringWithContentsOfFile:absoluteFilePath encoding:NSUTF8StringEncoding error:&e];
        if (e) {
            if (error != nil) {
                *error = e;
            }
            return nil;
        }
        /*
         pattern 解釋
         @"NSLocalizedString\\s*\\(\\s*@\"(.*?)\"\\s*,\\s*@?\"?(.*?)\"?\\s*\\)"

         開頭為 NSLocalizedString
         \\s*  零或多個空白
         \\(   跳脫左括弧 讓 ( 成為 literal
         @     如果是 key 在左括弧以及可能附加在其後的空白一定要出現 @ ，但如果是 comment 可能是 nil 所以 comment 不一定是 @""
         這種 pattern，因此 comment 要使用 @? 表達
         \"    @ 後要接上 " 其狀況跟 @ 類似
         (.*?) 這是 Reluctant 的做法
         ,     key 和 comment 之間要有一個分隔符號 ,
         */
		NSArray *patterns = [NSArray arrayWithObjects:
							 @"NSLocalizedString\\s*\\(\\s*@\"(.*?)\"\\s*,\\s*@?\"?(.*?)\"?\\s*\\)",
							 @"LFLSTR\\s*\\(\\s*@\"(.*?)\"\\s*\\)",
                             @"\\^(.*?)<",nil];
		for (NSString *pattern in patterns) {
			[result unionSet:makeMatchInfoSet(pattern, fileContent, extFilePath)];
		}
    }
    return result;
}

static NSSet *parseDir(NSString *baseFilePath, NSError **error)
{
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:baseFilePath];
    NSString *extFilePath;
    NSMutableSet *result = [[NSMutableSet alloc] init];
    while (extFilePath = [dirEnum nextObject]) {
        BOOL isDir = NO;
        NSError *e = nil;
        NSString *absoluteFilePath = [baseFilePath stringByAppendingPathComponent:extFilePath];

        if (!([[NSFileManager defaultManager] fileExistsAtPath:absoluteFilePath isDirectory:&isDir] && isDir)){
            NSSet *matchInfoSet = parseFile(baseFilePath, extFilePath, &e);
            [result unionSet:matchInfoSet];
        }

    }
    return [result autorelease];
}

- (NSSet *)parse:(NSString *)filePath
{
    if (!filePath) {
        [NSException raise:@"JHSourceCodeParserError" format:@"File path is missing."];
    }

    BOOL isDir = NO;
    NSSet *matchResult = nil;
    NSError *e = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir]) {
        matchResult = isDir ? parseDir(filePath, &e) : parseFile(@"", filePath, &e);
    }
    return matchResult;
}
@end
