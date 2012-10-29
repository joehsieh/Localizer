//
//  SrcParserTest.h
//  Localizer
//
//  Created by KKBOX on 12/10/22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "KKSourceCodeParser.h"

@interface SrcParserTest : SenTestCase
{
    KKSourceCodeParser *srcParser;
}
@property (retain, nonatomic) KKSourceCodeParser *srcParser;
@end
