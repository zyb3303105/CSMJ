//
//  Player.h
//  CSMJ
//
//  Created by 彭征新 on 16/5/11.
//  Copyright © 2016年 彭征新. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloudIM/AVOSCloudIM.h>

@interface Player : NSObject
@property NSString *clientId;  //客户端号
@property NSString *name;  //玩家名称
@property AVIMClient *client;

-(Player *) initWithClientId:(NSString *) clientId;
-(Player *) initWithName:(NSString *) name;
@end
