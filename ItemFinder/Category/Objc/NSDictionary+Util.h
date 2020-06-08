//
//  NSDictionary+YbsObject.h
//  laiji
//
//  Created by xinguang hu on 2019/3/5.
//  Copyright © 2019 hxg. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Util)

+ (NSDictionary *)getObjectData:(id)obj;
- (NSDictionary *)convertNullValueToEmptyStr;
+ (NSDictionary *)readLocalJsonFileWithName:(NSString *)name;
- (NSString *)keyValueJointedAfterString:(NSString *)originalString;

@end

NS_ASSUME_NONNULL_END
