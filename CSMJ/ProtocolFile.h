//
//  ProtocolFile.h
//  CSMJ
//
//  Created by 彭征新 on 16/5/25.
//  Copyright © 2016年 彭征新. All rights reserved.
//

//定义协议
@protocol ActionDelegate <NSObject>

//执行动作
@optional
- (void) doAction:(int ) action;

@end