//
//  NSString+Ybs.m
//  laiji
//
//  Created by xinguang hu on 2019/1/18.
//  Copyright © 2019 hxg. All rights reserved.
//

#import "NSString+Ybs.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (Ybs)

- (NSString *(^)(id))stringify
{
    return ^NSString *(id object){
        if([object isEqual:[NSNull null]] || object == nil || object == NULL){
            return @"";
        }
        else if ([object isKindOfClass:[NSNumber class]]){
            return [NSString stringWithFormat:@"%@",object];
        }
        return object;
    };
}

- (BOOL)isEmpty
{
    if (self == nil || self == NULL){
        return YES;
    }
    if ([self isKindOfClass:[NSNull class]]){
        return YES;
    }
    if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0){
        return YES;
    }
    return NO;
}

- (BOOL)isAllNumber
{
    NSString *pattern = @"[0-9]*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pattern];
    return [predicate evaluateWithObject:self];
}

- (BOOL)isAllNumberOrDecimal
{
    NSString *regex2 = @"^[0-9]+([.]{1}[0-9]+){0,1}$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:self];
}

- (BOOL)isPhoneNumber
{
    NSString *pattern = @"^(13[0-9]|14[579]|15[0-3,5-9]|16[6]|17[0135678]|18[0-9]|19[89])\\d{8}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    return [predicate evaluateWithObject:self];
}

- (BOOL)isAmount
{
    NSString *pattern = @"^([1-9]\\d*|0)(\\.\\d?[1-9])?$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    return [predicate evaluateWithObject:self];
}

- (BOOL)isIDCard
{
    NSString *pattern = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pattern];
    return [predicate evaluateWithObject:self];
}

- (BOOL)isNumberOrAlphabetOrChinese{
    NSString *pattern = @"[ 0-9a-zA-Z\\u4e00-\\u9fa5！!_]*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pattern];
    return [predicate evaluateWithObject:self];
}

- (NSString *)trimBlank
{
    if (self.isEmpty){
        return @"";
    }else{
        return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
}

+ (NSString *)md5:(NSString *)str{
    if (!str) return nil;
    const char *cStr = str.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    NSMutableString *md5Str = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [md5Str appendFormat:@"%02x", result[i]];
    }
    return md5Str;
}

+ (NSString *)randomStringWithLength:(NSInteger)length {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    for (NSInteger i = 0; i < length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)letters.length)]];
    }
    return randomString;
}

+ (NSDictionary *)dictionaryFromUrlQueryString:(NSString *)query{
    NSArray *strArr = [query componentsSeparatedByString:@"&"];
    //把strArr转换为字典
    //tempDic中存放一个URL中转换的键值对
    NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
    for (int j=0;j<strArr.count; j++){
        //在通过=拆分键和值
        NSArray *dicArray = [strArr[j] componentsSeparatedByString:@"="];
        //给字典加入元素
        [result setObject:dicArray[1] forKey:dicArray[0]];
    }
    
    return result;
}



@end
