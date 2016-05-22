//
//  Player.m
//  CSMJ
//
//  Created by 彭征新 on 16/5/11.
//  Copyright © 2016年 彭征新. All rights reserved.
//

#import "Player.h"
#import <AVOSCloudIM/AVOSCloudIM.h>

@implementation Player

-(Player *)initWithClientId:(NSString *) clientId {
    Player *player = [[Player alloc] init];
    [player setClientId:clientId];
    player.name = clientId;
    return player;
}

-(Player *) initWithName:(NSString *) name {
    Player *player = [[Player alloc] init];
    [player setName:name];
    return player;
}

@end
