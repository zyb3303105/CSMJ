//
//  MJManager.m
//  CSMJ
//
//  Created by 彭征新 on 16/5/17.
//  Copyright © 2016年 彭征新. All rights reserved.
//

#import "MJManager.h"

@implementation MJManager
{
}


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

//检测是否胡牌
- (BOOL) checkAllPai:(NSMutableArray *)arr {
    arr = [[NSMutableArray alloc] initWithArray:[arr sortedArrayUsingSelector:@selector(compare:)]];
    switch (arr.count) {
        case 5: //5张
            return [self check5Pai:[arr[0] intValue] value2:[arr[1] intValue] value3:[arr[2] intValue]value4:[arr[3] intValue] value5:[arr[4] intValue]];
            break;
        case 8: //8张
            return [self check8Pai:[arr[0] intValue] value2:[arr[1] intValue] value3:[arr[2] intValue]value4:[arr[3] intValue] value5:[arr[4] intValue] value6:[arr[5] intValue] value7:[arr[6] intValue] value8:[arr[7] intValue]];
            break;
        case 11:    //11张
            return [self check11Pai:[arr[0] intValue] value2:[arr[1] intValue] value3:[arr[2] intValue]value4:[arr[3] intValue] value5:[arr[4] intValue] value6:[arr[5] intValue] value7:[arr[6] intValue] value8:[arr[7] intValue] value9:[arr[8] intValue] value10:[arr[9] intValue] value11:[arr[10] intValue]];
            break;
        case 14:    //14张
            return [self check14Pai:[arr[0] intValue] value2:[arr[1] intValue] value3:[arr[2] intValue]value4:[arr[3] intValue] value5:[arr[4] intValue] value6:[arr[5] intValue] value7:[arr[6] intValue] value8:[arr[7] intValue] value9:[arr[8] intValue] value10:[arr[9] intValue] value11:[arr[10] intValue] value12:[arr[11] intValue] value13:[arr[12] intValue] value14:[arr[13] intValue]];
            break;
        default:
            break;
    }
    return NO;
}

//检测是否有将牌
- (BOOL) checkAAPai:(int) value1 value2:(int) value2 {
    if (value1 == value2) {
        if (value1 % 10 == 2 || value1 % 10 == 5 || value1 % 10 == 8) {
            return YES;
        }
    }
    return NO;
}

//检测是否三连张
- (BOOL) checkABCPai:(int) value1 value2:(int) value2 value3:(int) value3 {
    if (value1 == value2-1 && value2 == value3-1) {
        return YES;
    }
    return NO;
}

//检测是否三重张
- (BOOL) checkAAAPai:(int) value1 value2:(int) value2 value3:(int) value3 {
    if (value1 == value2 && value2 == value3) {
        return YES;
    }
    return NO;
}

//检测是否四重张
- (BOOL) checkAAAAPai:(int) value1 value2:(int) value2 value3:(int) value3 value4:(int) value4{
    if (value1 == value2 == value3 == value4) {
        return YES;
    }
    return NO;
}

//检测是否三连对
- (BOOL) checkAABBCCPai:(int) value1 value2:(int) value2 value3:(int) value3 value4:(int) value4 value5:(int) value5 value6:(int) value6 {
    if (value1 == value2 && value3 == value4 && value5 == value6) {
        if (value1 == value3-1 && value3 == value5-1) {
            return YES;
        }
    }
    return NO;
}

//检测是否三连高压
- (BOOL) checkAAABBBCCCPai:(int) value1 value2:(int) value2 value3:(int) value3 value4:(int) value4 value5:(int) value5 value6:(int) value6 value7:(int) value7 value8:(int) value8 value9:(int) value9{
    //暂不实现
    return NO;
}

//检测是否三连刻
- (BOOL) checkAAAABBBBCCCCPai:(int) value1 value2:(int) value2 value3:(int) value3 value4:(int) value4 value5:(int) value5 value6:(int) value6 value7:(int) value7 value8:(int) value8 value9:(int) value9 value10:(int) value10 value11:(int) value11 value12:(int) value12{
    //暂不实现
    return NO;
}

 //检测是否六连对
- (BOOL) checkAABBCCDDEEFFPai:(int) value1 value2:(int) value2 value3:(int) value3 value4:(int) value4 value5:(int) value5 value6:(int) value6 value7:(int) value7 value8:(int) value8 value9:(int) value9 value10:(int) value10 value11:(int) value11 value12:(int) value12{
    //暂不实现
    return NO;
}


//带将牌检测=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//检测是否胡牌 (5张）
- (BOOL) check5Pai:(int) value1 value2:(int) value2 value3:(int) value3 value4:(int) value4 value5:(int) value5 {
    //如果是左边两个为将，右边为三重张或三连张
    if ([self checkAAPai:value1 value2:value2]) {
        if ([self check3Pai:value3 value2:value4 value3:value5]) {
            return YES;
        }
    }
    
    //如果中间2个为将
    if ([self checkAAAPai:value2 value2:value3 value3:value4]) {
        if ([self checkABCPai:value1 value2:value4 value3:value5]) {
            return YES;
        }
    }
    
    //如果右边两个为将，左边为三重张或者三连张
    if ([self checkAAPai:value4 value2:value5]) {
        if ([self checkABCPai:value1 value2:value2 value3:value3]) {
            return YES;
        }
    }
    
    return NO;
}

//检测是否胡牌（8张）
- (BOOL) check8Pai:(int) value1 value2:(int) value2 value3:(int) value3 value4:(int) value4 value5:(int) value5 value6:(int) value6 value7:(int) value7 value8:(int) value8{
    //如果是左边两个为将，右边为三重张或三连张
    if ([self checkAAPai:value1 value2:value2]) {
        if ([self check6Pai:value3 value2:value4 value3:value5 value4:value6 value5:value7 value6:value8]) {
            return YES;
        }
    }
    
    //如果中间2个为将
    if ([self checkAAPai:value4 value2:value5]) {
        if ([self check3Pai:value1 value2:value2 value3:value3] && [self check3Pai:value6 value2:value7 value3:value8]) {
            return YES;
        }
    }
    
    //如果右边两个为将，左边为三重张或者三连张
    if ([self checkAAPai:value7 value2:value8]) {
        if ([self check6Pai:value1 value2:value2 value3:value3 value4:value4 value5:value5 value6:value6]) {
            return YES;
        }
    }
    
    return NO;
}

//检测是否胡牌（11张）
- (BOOL) check11Pai:(int) value1 value2:(int) value2 value3:(int) value3 value4:(int) value4 value5:(int) value5 value6:(int) value6 value7:(int) value7 value8:(int) value8 value9:(int) value9 value10:(int) value10 value11:(int) value11{
    //如果是左边两个为将，右边为三重张或者三连张
    if ([self checkAAPai:value1 value2:value2]) {
        if ([self check9Pai:value3 value2:value4 value3:value5 value4:value6 value5:value7 value6:value8 value7:value9 value8:value10 value9:value11]) {
            return YES;
        }
    }
    
    //如果第4和第5个位将
    if ([self checkAAPai:value4 value2:value5]) {
        if ([self check3Pai:value1 value2:value2 value3:value3] && [self check6Pai:value6 value2:value7 value3:value8 value4:value9 value5:value10 value6:value11]) {
            return YES;
        }
    }
    
    //如果第7和第8个为将
    if ([self checkAAPai:value7 value2:value8]) {
        if ([self check6Pai:value1 value2:value2 value3:value3 value4:value4 value5:value5 value6:value6] && [self check3Pai:value9 value2:value10 value3:value11]) {
            return YES;
        }
    }
    
    //如果右边两个为将，左边为三重张或者三连张
    if ([self checkAAPai:value10 value2:value11]) {
        if ([self check9Pai:value1 value2:value2 value3:value3 value4:value4 value5:value5 value6:value6 value7:value7 value8:value8 value9:value9]) {
            return YES;
        }
    }
    
    return NO;
}

//检测是否胡牌（14张）
- (BOOL) check14Pai:(int) value1 value2:(int) value2 value3:(int) value3 value4:(int) value4 value5:(int) value5 value6:(int) value6 value7:(int) value7 value8:(int) value8 value9:(int) value9 value10:(int) value10 value11:(int) value11 value12:(int) value12 value13:(int) value13 value14:(int) value14{
    //如果是左边两个为将，右边为三重张或三连张
    if ([self checkAAPai:value1 value2:value2]) {
        if ([self check12Pai:value3 value2:value4 value3:value5 value4:value6 value5:value7 value6:value8 value7:value9 value8:value10 value9:value11 value10:value12 value11:value13 value12:value14]) {
            return YES;
        }
    }
    
    //如果是第4和第5为将
    if ([self checkAAPai:value4 value2:value5]) {
        if ([self check3Pai:value1 value2:value2 value3:value3] && [self check9Pai:value6 value2:value7 value3:value8 value4:value9 value5:value10 value6:value11 value7:value12 value8:value13 value9:value14]) {
            return  YES;
        }
    }
    
    //如果是第7和第8为将
    if ([self checkAAPai:value7 value2:value8]) {
        if ([self check6Pai:value1 value2:value2 value3:value3 value4:value4 value5:value5 value6:value6] && [self check6Pai:value9 value2:value10 value3:value11 value4:value12 value5:value13 value6:value14]) {
            return YES;
        }
    }
    
    //如果是第10和第11为将
    if ([self checkAAPai:value10 value2:value11]) {
        if ([self check9Pai:value1 value2:value2 value3:value3 value4:value4 value5:value5 value6:value6 value7:value7 value8:value8 value9:value9] && [self check3Pai:value12 value2:value13 value3:value14]) {
            return YES;
        }
    }
    
    //如果右边2个位将
    if ([self checkAAPai:value13 value2:value14]) {
        if ([self check12Pai:value1 value2:value2 value3:value3 value4:value4 value5:value5 value6:value6 value7:value7 value8:value8 value9:value9 value10:value10 value11:value11 value12:value12]) {
            return YES;
        }
    }
    return NO;
}


//不带将牌检测=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//检测是否胡牌 (3张）
- (BOOL) check3Pai:(int) value1 value2:(int) value2 value3:(int) value3 {
    if ([self checkAAAPai:value1 value2:value2 value3:value3] || [self checkABCPai:value1 value2:value2 value3:value3]) {
        return YES;
    }
    return NO;
}
//检测是否胡牌（6张）
- (BOOL) check6Pai:(int) value1 value2:(int) value2 value3:(int) value3 value4:(int) value4 value5:(int) value5 value6:(int) value6 {
    if ([self check3Pai:value1 value2:value2 value3:value3] && [self check3Pai:value4 value2:value5 value3:value6]) {
        return YES;
    }
    
    //三连对
    if ([self checkAABBCCPai:value1 value2:value2 value3:value3 value4:value4 value5:value5 value6:value6]) {
        return YES;
    }
    
    //中间4张相同
    if ([self checkAAAAPai:value2 value2:value3 value3:value4 value4:value5]) {
        if ([self checkABCPai:value1 value2:value2 value3:value6]) {
            return YES;
        }
    }
    
    //其他特殊胡牌情况有待补充
    
    return NO;
}

//检测是否胡牌（9张）
- (BOOL) check9Pai:(int) value1 value2:(int) value2 value3:(int) value3 value4:(int) value4 value5:(int) value5 value6:(int) value6 value7:(int) value7 value8:(int) value8 value9:(int) value9 {
    if ([self checkABCPai:value1 value2:value2 value3:value3] && [self check6Pai:value4 value2:value5 value3:value6 value4:value7 value5:value8 value6:value9]) {
        return YES;
    }
    if ([self checkAAAPai:value1 value2:value2 value3:value3] && [self check6Pai:value4 value2:value5 value3:value6 value4:value7 value5:value8 value6:value9]) {
        return YES;
    }
    if ([self checkABCPai:value7 value2:value8 value3:value9] && [self check6Pai:value1 value2:value2 value3:value3 value4:value4 value5:value5 value6:value6]) {
        return YES;
    }
    if ([self checkAAAPai:value7 value2:value8 value3:value9] && [self check6Pai:value1 value2:value2 value3:value3 value4:value4 value5:value5 value6:value6]) {
        return YES;
    }
    
    //233444556的胡牌情况
    if ([self checkAAAPai:value4 value2:value5 value3:value6]) {
        if (value2 == value3 && value7 == value8) {
            if (value1 == value2-1 && value2 == value4-1 && value6 == value7-1 && value7 == value9-1) {
                return YES;
            }
        }
    }
    
    //其他特殊胡牌情况有待补充
    
    return NO;
}

//检测是否胡牌（12张）
- (BOOL) check12Pai:(int) value1 value2:(int) value2 value3:(int) value3 value4:(int) value4 value5:(int) value5 value6:(int) value6 value7:(int) value7 value8:(int) value8 value9:(int) value9 value10:(int) value10 value11:(int) value11 value12:(int) value12 {
    if ([self checkAAAPai:value1 value2:value2 value3:value3] && [self check9Pai:value4 value2:value5 value3:value6 value4:value7 value5:value8 value6:value9 value7:value10 value8:value11 value9:value12]) {
        return YES;
    }
    if ([self checkABCPai:value1 value2:value2 value3:value3] && [self check9Pai:value4 value2:value5 value3:value6 value4:value7 value5:value8 value6:value9 value7:value10 value8:value11 value9:value12]) {
        return YES;
    }
    if ([self checkAAAPai:value10 value2:value11 value3:value12] && [self check9Pai:value1 value2:value2 value3:value3 value4:value4 value5:value5 value6:value6 value7:value7 value8:value8 value9:value9]) {
        return YES;
    }
    if ([self checkABCPai:value10 value2:value11 value3:value12] && [self check9Pai:value1 value2:value2 value3:value3 value4:value4 value5:value5 value6:value6 value7:value7 value8:value8 value9:value9]) {
        return YES;
    }
    
    //233444555667的胡牌情况
    if ([self checkAAAPai:value4 value2:value5 value3:value6] && [self checkAAAPai:value7 value2:value8 value3:value9]) {
        if (value2 == value3 && value10 == value11) {
            if (value1 == value2-1 && value2 == value4-1 && value4 == value7-1 && value7 == value10-1 && value10 == value12-1) {
                return YES;
            }
        }
    }
    
    //其他特殊胡牌情况有待补充
    return NO;
}




/**
 *检测是否可碰牌
 *@param-in:arr 手牌数组
 *@param-in:card 被检测牌
 */
- (BOOL) checkPengPai: (NSMutableArray *) arr card:(int ) card {
    int count = 0;
    for (NSString *str in arr) {
        if ([str intValue] == card) {
            count ++;
        }
    }
    
    if (count >= 2) {
        return YES;
    }
    return NO;
}

/**
 *检测是否可杠牌
 *@param-in:arr 手牌数组
 *@param-in:card 被检测牌
 */
- (BOOL) checkGangPai: (NSMutableArray *) arr card:(int ) card {
    int count = 0;
    for (NSString *str in arr) {
        if ([str intValue] == card) {
            count ++;
        }
    }
    
    if (count >= 3) {
        return YES;
    }
    return NO;
}

/**
 *检测是否可吃牌
 *@param-in:arr 手牌数组
 *@param-in:card 被检测牌
 *@param-in:otherCount 打牌者的索引
 *@param-in:myCount 我自己的索引
 *@param-out:result 可用于吃牌的组合
 */
- (NSMutableArray *) checkChiPai: (NSMutableArray *) arr card:(int ) card otherCount:(int )count myCount:(int )myCount {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    //假设吃3
    //可12吃、24吃、45吃
    if (myCount != count+1 ) {  //我不是出牌者的下家
        if (!(myCount == 0 && count == 3)) {
            return result;
        }
    }
    
    int value1 = card - 2,value2 = card - 1,value3 = card + 1,value4 = card + 2;
    BOOL exist1 = NO,exist2 = NO,exist3 = NO,exist4 = NO;
    
    for (NSString *str in arr) {
        if ([str intValue] == value1) {
            exist1 = YES;
        }
        
        if ([str intValue] == value2) {
            exist2 = YES;
        }
        
        if ([str intValue] == value3) {
            exist3 = YES;
        }
        
        if ([str intValue] == value4) {
            exist4 = YES;
        }
    }
    
    
    
    //12吃
    if (exist1 && exist2) {
        [result addObject:@[[NSString stringWithFormat:@"%d",value1],[NSString stringWithFormat:@"%d",value2]]];
    }
    
    //24吃
    if (exist2 && exist3) {
        [result addObject:@[[NSString stringWithFormat:@"%d",value2],[NSString stringWithFormat:@"%d",value3]]];
    }
    
    //45吃
    if (exist3 && exist4) {
        [result addObject:@[[NSString stringWithFormat:@"%d",value3],[NSString stringWithFormat:@"%d",value4]]];
    }
    
    return result;
}





















@end
