//
//  MJManager.m
//  CSMJ
//
//  Created by 彭征新 on 16/5/17.
//  Copyright © 2016年 彭征新. All rights reserved.
//

#import "MJManager.h"

@implementation MJManager

/**
 *创建牌库
 *num:本局局数
 */
- (NSMutableArray *) createPaiKu:(NSInteger) num {
    NSMutableArray *paiKuArr = [[NSMutableArray alloc] init];
    
    for (int k = 0; k < num; k ++) {
        //一局牌库
        NSMutableArray *oneGame = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < 4; i ++) {
            //创建万字 11 - 19
            for (int j = 11; j < 20; j ++) {
                NSString *str = [NSString stringWithFormat:@"%d",j];
                [oneGame addObject:str];
            }
            
            //创建条字 21 - 29
            for (int j = 21; j < 30; j ++) {
                NSString *str = [NSString stringWithFormat:@"%d",j];
                [oneGame addObject:str];
            }
            
            //创建筒字 31 - 39
            for (int j = 31; j < 40; j ++) {
                NSString *str = [NSString stringWithFormat:@"%d",j];
                [oneGame addObject:str];
            }
        }
        
        [self arrayRandom:oneGame];
        
        [paiKuArr addObject:oneGame];
    }
    
    return paiKuArr;
}

//打乱数组顺序
- (void)arrayRandom:(NSMutableArray *)array{
    NSInteger count = array.count - 1;
    int index;
    id tmp;
    
    for ( ; count > 0; count --) {
        index = rand() % count;
        tmp = array[count];
        array[count] = array[index];
        array[index] = tmp;
    }
}
@end
