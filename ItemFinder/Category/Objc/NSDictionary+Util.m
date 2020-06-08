//
//  NSDictionary+YbsObject.m
//  laiji
//
//  Created by xinguang hu on 2019/3/5.
//  Copyright © 2019 hxg. All rights reserved.
//

#import "NSDictionary+Util.h"
#import <objc/runtime.h>

@implementation NSDictionary (Util)

+ (NSDictionary*)getObjectData:(id)obj {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);
    for(int i = 0;i < propsCount; i++) {
        objc_property_t prop = props[i];
        
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        id value = [obj valueForKey:propName];
        if(value == nil) {
            value = [NSNull null];
        }
        else {
            value = [self getObjectInternal:value];
        }
        [dic setObject:value forKey:propName];
    }
    return dic;
}

+ (id)getObjectInternal:(id)obj {
    if([obj isKindOfClass:[NSString class]]
       || [obj isKindOfClass:[NSNumber class]]
       || [obj isKindOfClass:[NSNull class]]) {
        return obj;
    }
    
    if([obj isKindOfClass:[NSArray class]]) {
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for(int i = 0;i < objarr.count; i++) {
            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        return arr;
    }
    
    if([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for(NSString *key in objdic.allKeys) {
            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }
        return dic;
    }
    return [self getObjectData:obj];
}

- (NSDictionary *)convertNullValueToEmptyStr{//只支持一层
    
    NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] init];
    for (NSString *keyStr in self.allKeys) {
        
        if ([[self objectForKey:keyStr] isEqual:[NSNull null]]) {
            [mutableDic setObject:@"" forKey:keyStr];
        }else{
            [mutableDic setObject:[self objectForKey:keyStr] forKey:keyStr];
        }
    }
    return mutableDic;
}


+ (NSDictionary *)readLocalJsonFileWithName:(NSString *)name {
    // 获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    // 对数据进行JSON格式化并返回字典形式
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

- (NSString *)keyValueJointedAfterString:(NSString *)originalString{
    
    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@",originalString];
    //获取字典的所有keys
    NSArray * keys = [self allKeys];
    //拼接字符串
    for (int j = 0; j < keys.count; j ++){
        NSString *string;
        if (j == 0){
            //拼接时加？
            string = [NSString stringWithFormat:@"?%@=%@", keys[j], self[keys[j]]];
        }else{
            //拼接时加&
            string = [NSString stringWithFormat:@"&%@=%@", keys[j], self[keys[j]]];
        }
        //拼接字符串
        [urlStr appendString:string];
        
    }
    return urlStr;

}




@end
