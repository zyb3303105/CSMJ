//
//  TableVC.m
//  CSMJ
//
//  Created by 彭征新 on 16/5/11.
//  Copyright © 2016年 彭征新. All rights reserved.
//

#import "TableVC.h"
#import "Player.h"

@interface TableVC ()
{
    UILabel *bottom;
    UILabel *right;
    UILabel *top;
    UILabel *left;
    UILabel *roomNumLabel;
}

@end

@implementation TableVC

- (void)sendMessage{
    [self sendMessageWithConversion:_conversation message:@"testtest"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    
    //退出房间按钮配置
    UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    exitBtn.frame = CGRectMake(0, 0, 100, 50);
    [exitBtn setTitle:@"退出房间" forState:UIControlStateNormal];
    [exitBtn addTarget:self action:@selector(exitRoom) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exitBtn];
    
    //退出房间按钮配置
    UIButton *sendMsg = [UIButton buttonWithType:UIButtonTypeCustom];
    sendMsg.frame = CGRectMake(100, 0, 100, 50);
    [sendMsg setTitle:@"发送消息" forState:UIControlStateNormal];
    [sendMsg addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendMsg];
    
    //房间号
    roomNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 100, 50)];
    roomNumLabel.textColor = [UIColor blackColor];
    [self.view addSubview:roomNumLabel];
    
    //创建麻将功能类
    _mjManager = [[MJManager alloc] init];
    
    bottom = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    [bottom setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height - 50)];
    [bottom setText:@"aaaa"];
    [bottom setTextColor:[UIColor blackColor]];
    
    right= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    [right setCenter:CGPointMake(self.view.frame.size.width - 100, self.view.frame.size.height / 2)];
    
    top= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    [top setCenter:CGPointMake(self.view.frame.size.width / 2, 50)];
    
    left = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    [left setCenter:CGPointMake(100, self.view.frame.size.height / 2)];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)exitRoom{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"退出房间");
        [_conversation quitWithCallback:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"退出房间成功！");
                [_playerArr removeAllObjects];
                _conversation = nil;
            }
        }];
    }];
}

//获取房间已有玩家
//玩家顺序不在此做排序，保持所有人顺序不变，在显示的时候做顺序修改。
- (void) getPlayers {
    BOOL bExist = NO;

    for (id member in _conversation.members) {
        Player *player = [[Player alloc] initWithClientId:member];  //这里的member存的即是用户的ClientId
        [_playerArr addObject:player];
        
        if ([member isEqualToString:_user.clientId]) {
            bExist = YES;
        }
    }
    
    //将其他玩家加完后 加自己
    if (!bExist) {
        [_playerArr addObject:_user];
    }
    
    //如果人数不够，暂时先补全数组
    NSUInteger count = _playerArr.count;
    if (count < 4) {
        for (int i = 0; i < 4 - count; i ++) {
            Player *player = [[Player alloc] initWithName:@"等待中"];
            [_playerArr addObject:player];
        }
    }
}

//根据用户数组，按东南西北显示玩家
- (void) showPlayers {
    [self setPlayers];
    
    [self.view addSubview:bottom];
    [self.view addSubview:right];
    [self.view addSubview:top];
    [self.view addSubview:left];
}

- (void) setPlayers {
    
    int count = 0;
    for (Player *player in _playerArr) {
        if ([player.clientId isEqualToString:_user.clientId]) {
            for (int i = 0; i < 4; i ++) {
                Player *temp = _playerArr[count];
                switch (i) {
                    case 0:
                        [bottom setText:temp.name];
                        break;
                    case 1:
                        [right setText:temp.name];
                        break;
                    case 2:
                        [top setText:temp.name];
                        break;
                    case 3:
                        [left setText:temp.name];
                        break;
                    default:
                        break;
                }
                
                if (count == 3) {
                    count = 0;
                }else {
                    count ++;
                }
            }
            break;
        }
        count ++;
    }
}

//设置房间号
- (void) setRoomNum:(NSString *) roomNum {
    roomNumLabel.text = roomNum;
}

- (void) sendMessageWithConversion:(AVIMConversation *) conversion message:(NSString *) message {
    [conversion sendMessage:[AVIMTextMessage messageWithText:message attributes:nil] callback:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"消息发送成功！！");
        }
    }];
}

//创建牌库
- (void) createPaiKu:(NSInteger ) num roomNum:(NSNumber *) roomNum {
    roomNumLabel.text = [NSString stringWithFormat:@"%@",roomNum];
    NSLog(@"创建牌库!");
    NSMutableArray *paiKu = [_mjManager createPaiKu:num];
    AVQuery *query = [AVQuery queryWithClassName:@"Room"];

    [query whereKey:@"roomNum" equalTo:roomNum];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count != 0) {
            AVObject *room = objects[0];
            [room setObject:paiKu forKey:@"paiKu"];
            [room saveInBackground];
        } else {
            NSLog(@"创建牌库时查找房间失败！");
        }
        
    }];
}

/*!
 对话中有新成员加入的通知。
 @param conversation － 所属对话
 @param clientIds - 加入的新成员列表
 @param clientId - 邀请者的 id
 @return None.
 */
-(void)conversation:(AVIMConversation *)conversation membersAdded:(NSArray *)clientIds byClientId:(NSString *)clientId {
    for (NSString *clientId in clientIds) {
        if ([clientId isEqualToString:_user.clientId]) {
            continue;
        }
        Player *newPlayer = [[Player alloc] initWithClientId:clientId];
        [_playerArr insertObject:newPlayer atIndex:_conversation.members.count - 1];
        [_playerArr removeLastObject];
    }
    
    [self setPlayers];  //重新设置名字
}

/*!
 对话中有成员离开的通知。
 @param conversation － 所属对话
 @param clientIds - 离开的成员列表
 @param clientId - 操作者的 id
 @return None.
 */
-(void)conversation:(AVIMConversation *)conversation membersRemoved:(NSArray *)clientIds byClientId:(NSString *)clientId {
    for (NSString *clientId in clientIds) {
        for (Player *player in _playerArr) {
            if ([clientId isEqualToString:player.clientId]) {
                [_playerArr removeObject:player];
                Player *waitPlayer = [[Player alloc] initWithName:@"等待中"];
                //[_playerArr insertObjects:@[waitPlayer] atIndexes:[[NSIndexSet alloc] initWithIndex:count]];
                [_playerArr addObject:waitPlayer];
                break;
            }
        }
    }
    
    [self setPlayers];  //重新设置名字
}

//接受消息消息
- (void) conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message {
    NSLog(@"%@",message.text);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
