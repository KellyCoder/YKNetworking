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


@end
