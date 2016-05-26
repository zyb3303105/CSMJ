//
//  ACTIONManager.h
//  CSMJ
//
//  Created by 彭征新 on 16/5/25.
//  Copyright © 2016年 彭征新. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProtocolFile.h"

@interface ACTIONManager : NSObject
@property NSMutableArray *responseArr;  //玩家响应数组

- (void) getResponse:(int) count resType:(NSString *) resType myCount:(int) myCount; //获取玩家响应
- (ACTIONManager *) initArray;
- (void) cleanResponse;
@property (nonatomic,retain) id<ActionDelegate> delegate;   //代理类
@end
