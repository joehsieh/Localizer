//
//  KKMatchInfo.h
//  Localizer
//
//  Created by KKBOX on 12/10/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    notExist, // not exist
    justInserted, // added record after scan
    existing // exist
} MatchInfoRecordState;

@interface JHMatchInfo : NSObject<NSCopying, NSCoding, NSPasteboardWriting, NSPasteboardReading>
{
    NSString *key;
    NSString *translateString;
    NSString *comment;
    NSString *filePath;
    MatchInfoRecordState state;
}

@property (retain, nonatomic) NSString *key;
@property (retain, nonatomic) NSString *translateString;
@property (retain, nonatomic) NSString *comment;
@property (retain, nonatomic) NSString *filePath;

- (MatchInfoRecordState)state;
- (void)setState:(MatchInfoRecordState)state;

@end
