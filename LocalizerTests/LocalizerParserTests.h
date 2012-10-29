//
//  LocalizerTests.h
//  LocalizerTests
//
//  Created by KKBOX on 12/10/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "KKLocalizableSettingParser.h"
@interface LocalizerParserTests : SenTestCase
{
    KKLocalizableSettingParser *localizableSettingParser;
}

@property (retain, nonatomic) KKLocalizableSettingParser *localizableSettingParser;
@end
