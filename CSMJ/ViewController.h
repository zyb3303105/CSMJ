//
//  ViewController.h
//  CSMJ
//
//  Created by 彭征新 on 16/5/9.
//  Copyright © 2016年 彭征新. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloudIM/AVOSCloudIM.h>
#import "TableVC.h"
#import "Player.h"

@class TableVC;

@interface ViewController : UIViewController
@property NSNumber *roomNum;   //房间号
@property TableVC *table;  //牌桌
@property Player *user;    //当前用户
@end

