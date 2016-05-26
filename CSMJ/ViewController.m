//
//  ViewController.m
//  CSMJ
//
//  Created by 彭征新 on 16/5/9.
//  Copyright © 2016年 彭征新. All rights reserved.
//

#import "ViewController.h"
#import <AVOSCloud/AVOSCloud.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *clientIdInput;
@property (weak, nonatomic) IBOutlet UITextField *roomNumInput;
@end

@implementation ViewController
- (IBAction)changeUser:(id)sender {
    _user.client = [[AVIMClient alloc] initWithClientId:_clientIdInput.text];
    _user.clientId = _clientIdInput.text;
    _user.name = _clientIdInput.text;
    _user.client.delegate = _table; //设置代理
}

//创建房间
- (IBAction)CreateRoom:(id)sender {
    // 在 iOS SDK 中，AVCloud 提供了一系列静态方法来实现客户端调用云函数
    // 构建传递给服务端的参数字典
    NSDictionary *dicParameters = [NSDictionary new];

    //产生房间号
    [AVCloud callFunctionInBackground:@"CreateRoom" withParameters:dicParameters block:^(id object, NSError *error) {
        if (error == nil) {
            _roomNum = object;
            NSLog(@"%@",_roomNum);
            
            //打开Client
            [_user.client openWithCallback:^(BOOL succeeded, NSError *error) {
                if (error == nil) {
                    NSLog(@"打开Client成功");
                    [_user.client createConversationWithName:[NSString stringWithFormat:@"%@",_roomNum] clientIds:@[_user.clientId] callback:^(AVIMConversation *conversation, NSError *    error) {
                            //此处first需要用用户ID替换
                        if (error == nil) {
                            //跳转画面到牌桌
                            NSLog(@"创建对话成功");
                            [_table getPlayers];    //先在此将已有的玩家加入进牌桌数组
                            //跳转画面到牌桌
                            _table.conversation = conversation;
                            [_table setRoomNum:[NSString stringWithFormat:@"%@",_roomNum]];
                            [self presentViewController:_table animated:YES completion:^{
                                    NSLog(@"进入牌桌");
                                //显示玩家
                                [_table showPlayers];
                                //创建牌库
                                [_table createPaiKu:8 roomNum:_roomNum];
                            }];
                        }else {
                            NSLog(@"创建对话失败");
                        }
                    }];
                }else {
                    NSLog(@"打开Client失败");
                }
            }];
        }else {
            NSLog(@"产生房间号失败");
        }
    }];
}



//加入房间
- (IBAction)JoinRoom:(id)sender {
    NSLog(@"%@",_clientIdInput.text);

    [_user.client openWithCallback:^(BOOL succeeded, NSError *error) {
        NSLog(@"打开Client成功");
        AVIMConversationQuery *query = [_user.client conversationQuery];
        //此处需要将房间号替换成用户输入
        [query whereKey:@"name" containsString:_roomNumInput.text];
        [query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
            if (objects.count > 0) {
                NSLog(@"查找房间成功!");
                _table.conversation = objects[0];
                NSLog(@"%@",_table.conversation.members);
                [_table getPlayers];    //先在此将已有的玩家加入进牌桌数组
                
                //查询房间人数
                
                [_table.conversation countMembersWithCallback:^(NSInteger number, NSError *error) {
                    if (number < 4) {
                        [_table.conversation joinWithCallback:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                
                                NSLog(@"加入成功!");
                                
                                //跳转画面到牌桌
                                [self presentViewController:_table animated:YES completion:^{
                                    NSLog(@"进入牌桌");
                                }];
                                [_table setRoomNum:_roomNumInput.text];//显示房间号
                                [_table showPlayers];   //显示玩家
                                //                                //玩家已满 开始游戏
                                //                                if (number == 3) {
                                //                                    [_table startGames];
                                //                                }
                            }
                        }];
                    }else {
                        BOOL bExist = NO;
                        //判断自己是否在房间里
                        for (NSString *member in _table.conversation.members) {
                            if ([member isEqualToString:_user.clientId]) {
                                NSLog(@"返回房间!");
                                //跳转画面到牌桌
                                [self presentViewController:_table animated:YES completion:^{
                                    NSLog(@"进入牌桌");
                                }];
                                [_table showPlayers];   //显示玩家
                                [_table setRoomNum:_roomNumInput.text];//显示房间号
                                [_table startGames]; //开始游戏
                                bExist = YES;
                            }
                        }
                        
                        if (!bExist) {
                            //提示房间满员
                            NSLog(@"房间已满!");
                        }
                    }
                }];
            }else {
                NSLog(@"未找到房间!");
            }
            
        }];
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建客户端
    _user = [[Player alloc] initWithClientId:@"zyb"];  ////此处clientId需要用用户ID替换
    _table = [[TableVC alloc] init];
    _table.playerArr = [[NSMutableArray alloc] init];
    [_table setUser:_user];
    

    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
