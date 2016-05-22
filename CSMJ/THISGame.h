//
//  THISGame.h
//  CSMJ
//
//  Created by 彭征新 on 16/5/17.
//  Copyright © 2016年 彭征新. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

@interface THISGame : NSObject
@property NSMutableArray *paiQiang; //牌墙
@property NSMutableArray *shouPai;  //手牌
@property int lastCount;  //剩余张数

- (THISGame *) initWithRoomNum:(NSString *) roomNum;  //根据房间号获取牌库
- (NSMutableArray *) getShouPai:(NSInteger ) num;   //根据东西南北从牌墙中获取手牌
- (NSString *) getOneCard;  //摸一张牌

@end
