//
//  KKLocalizableSettingParser.h
//  Localizer
//
//  Created by joehsieh on 12/10/12.
//
//

#import <Foundation/Foundation.h>

@interface JHLocalizableSettingParser : NSObject

- (void)parse:(NSString *)fileContent scanFolderPathArray:(out NSArray **)outArray matchRecordSet:(out NSSet **)outSet;

@end
