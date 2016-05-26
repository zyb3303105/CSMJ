//
//  ACTIONManager.m
//  CSMJ
//
//  Created by 彭征新 on 16/5/25.
//  Copyright © 2016年 彭征新. All rights reserved.
//

#import "ACTIONManager.h"

@implementation ACTIONManager

- (ACTIONManager *) initArray {
    ACTIONManager *manager = [[ACTIONManager alloc] init];
    manager.responseArr = [[NSMutableArray alloc] initWithObjects:@"0",@"0",@"0",@"0", nil];
    return manager;
}

/** 
 *获取玩家响应
 *count:    响应者的索引
 *resType:  响应类型
 *cardCount:打牌者的索引
 *myCount:  我自己的索引
 */
- (void) getResponse:(int) count resType:(NSString *) resType myCount:(int) myCount {
    _responseArr[count] = resType;
    
    if ([_responseArr[myCount] isEqualToString:@"0"]) { //自己还未做出响应 则不做任何事情
        
    } else {    //否则，根据优先级判断是否可继续执行
        if ([self checkActionLevel:_responseArr of:myCount]) {  //如果自己优先级最高
            [_delegate doAction:[_responseArr[myCount] intValue]];
            [self cleanResponse];//清空
        }
    }
}

//检测优先级
- (BOOL) checkActionLevel:(NSMutableArray *) arr of:(int) count{
    for (NSString *str in arr) {
        if (![str isEqualToString:@"0"]) {   //还未做响应的不比较,包括出牌者自身,是不会响应的
            if ([arr[count] intValue] > [str intValue]) { //优先级比数组里其他人低
                return NO;
            }
        }
    }
    return YES;
}

//过圈
- (void) cleanResponse {
    for (int i = 0; i < 4; i ++) {
        _responseArr[i] = @"0";
    }
}
@end
