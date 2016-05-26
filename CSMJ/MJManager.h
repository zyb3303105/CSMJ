//
//  MJManager.h
//  CSMJ
//
//  Created by 彭征新 on 16/5/17.
//  Copyright © 2016年 彭征新. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJManager : NSObject
- (NSMutableArray *) createPaiKu:(NSInteger) num;

//检测是否胡牌
- (BOOL) checkAllPai: (NSMutableArray *) arr;

//检测是否可碰牌
- (BOOL) checkPengPai: (NSMutableArray *) arr card:(int ) card;

//检测是否可杠牌
- (BOOL) checkGangPai: (NSMutableArray *) arr card:(int ) card;

//检测是否可吃牌
- (NSMutableArray *) checkChiPai: (NSMutableArray *) arr card:(int ) card otherCount:(int )count myCount:(int )myCount;

//检测是否胡牌 (5张）
- (BOOL) check5Pai:(int) value1 value2:(int) value2 value3:(int) value3 value4:(int) value4 value5:(int) value5;
//检测是否胡牌（8张）
- (BOOL) check8Pai:(int) value1 value2:(int) value2 value3:(int) value3 value4:(int) value4 value5:(int) value5 value6:(int) value6 value7:(int) value7 value8:(int) value8;
//检测是否胡牌（11张）
- (BOOL) check11Pai:(int) value1 value2:(int) value2 value3:(int) value3 value4:(int) value4 value5:(int) value5 value6:(int) value6 value7:(int) value7 value8:(int) value8 value9:(int) value9 value10:(int) value10 value11:(int) value11;
//检测是否胡牌（14张）
- (BOOL) check14Pai:(int) value1 value2:(int) value2 value3:(int) value3 value4:(int) value4 value5:(int) value5 value6:(int) value6 value7:(int) value7 value8:(int) value8 value9:(int) value9 value10:(int) value10 value11:(int) value11 value12:(int) value12 value13:(int) value13 value14:(int) value14;
@end
