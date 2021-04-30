//
//  YKNetworkTool.m
//  YKNetworking
//
//  Created by Kevin on 2021/4/30.
//

#import "YKNetworkTool.h"

@implementation YKNetworkTool

+ (void)logSocket:(NSArray *)logArray{
    NSString *logString = @"";
    for (NSDictionary *logDic in logArray) {
        id key = [[logDic allKeys] lastObject];
        id value = [[logDic allValues] lastObject];
        //如果是数组就扔成一堆
        if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSMutableArray class]])
        {
            NSString *arrStr = [NSString stringWithFormat:@"< %lu > ",(unsigned long)[value count]];
            for (id obj in value) {
                arrStr = [arrStr stringByAppendingFormat:@",%@",obj];
            }
            value = arrStr;
        }
        if (logDic == [logArray lastObject]) {
            logString = [logString stringByAppendingFormat:@"║ %@    %@ \n║------------------------------------------------------------------",key,value];
        } else
        {
            logString = [logString stringByAppendingFormat:@"\n║ %@    %@ \n╟-----------------------------------------------------------------\n",key,value];
        }
    }
    NSLog(@"%@",logString);
}


+ (NSString *)connectWithparams:(NSMutableDictionary *)params url:(NSString *)urlLink{
    // 初始化参数变量
    NSString *str = @"&";
  
    // 快速遍历参数数组
    for(id key in params) {
//        NSLog(@"key :%@  value :%@", key, [params objectForKey:key]);
        str = [str stringByAppendingString:key];
        str = [str stringByAppendingString:@"＝"];
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%@",[params objectForKey:key]]];
        str = [str stringByAppendingString:@"&"];
    }
    // 处理多余的&以及返回含参url
    if (str.length > 1) {
        // 更换首位的&
        str = [str stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"?"];
        // 去掉末尾的&
        str = [str substringToIndex:str.length - 1];
        // 返回含参url
        return [urlLink stringByAppendingString:str];
    }
    return @"";
}

@end
