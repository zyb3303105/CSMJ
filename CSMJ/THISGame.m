//
//  THISGame.m
//  CSMJ
//
//  Created by 彭征新 on 16/5/17.
//  Copyright © 2016年 彭征新. All rights reserved.
//

#import "THISGame.h"

@implementation THISGame
{
    NSUserDefaults *userDefaults ;
}

- (THISGame *) initWithRoomNum:(NSString *) roomNum {
    userDefaults = [NSUserDefaults standardUserDefaults];
    THISGame *thisGame = [[THISGame alloc] init];
    NSNumber *num = [NSNumber numberWithFloat:[roomNum floatValue]];
    
    //查询对应的房间
    AVQuery *query = [AVQuery queryWithClassName:@"Room"];
    [query whereKey:@"roomNum" equalTo:num];

//    [query getFirstObjectInBackgroundWithBlock:^(AVObject *object, NSError *error) {
//        if (object != nil) {
//            NSLog(@"获取房间号为%@的牌墙成功！",num);
//            NSArray *arrPaiku = [object objectForKey:@"paiKu"];
//            thisGame.paiQiang = arrPaiku[0];    //获取第一局牌墙
//            [userDefaults setObject:thisGame.paiQiang forKey:@"paiQiang"];
//            
//        }
//    }];
    AVObject *object = [query getFirstObject];
    if (object != nil) {
        NSLog(@"获取房间号为%@的牌墙成功！",num);
        NSArray *arrPaiku = [object objectForKey:@"paiKu"];
        thisGame.paiQiang = arrPaiku[0];    //获取第一局牌墙
        [userDefaults setObject:thisGame.paiQiang forKey:@"paiQiang"];
    }
    
    //剩余牌库数量 108 - 52
    thisGame.lastCount = 56;
    
    return thisGame;
}

/**
 *根据东西南北获取手牌
 */
- (NSMutableArray *) getShouPai:(NSInteger ) num {
    NSMutableArray  *shouPai = [[NSMutableArray alloc] init];
    for (NSInteger i = num * 13; i < (num + 1) * 13; i ++) {
        [shouPai addObject:self.paiQiang[i]];
    }
    
    return shouPai;
}

/**
 *抓一张牌
 */
- (NSString *) getOneCard {

    NSString *str = self.paiQiang[108 - self.lastCount--];
    NSLog(@"抓一张牌:%@",str);
    return str;
}
@end
