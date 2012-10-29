//
//  KKMatchInfoProcessor.h
//  Localizer
//
//  Created by KKBOX on 12/10/26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHMatchInfoProcessor : NSObject

//according to that does localizable.strings file exit to merge src info set and localizable info set
- (NSArray *)mergeSetWithSrcInfoSet:(NSSet *)inSrcInfoSet withLocalizableInfoSet:(NSSet *)inLocalizableInfoSet withLocalizableFileExist:(BOOL)isLocalizableFileExist;
@end
