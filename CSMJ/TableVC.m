//
//  TableVC.m
//  CSMJ
//
//  Created by 彭征新 on 16/5/11.
//  Copyright © 2016年 彭征新. All rights reserved.
//

#import "TableVC.h"
#import "Player.h"

#define VIEW_WIDTH self.view.frame.size.width
#define VIEW_HEIGH self.view.frame.size.height
#define MJ_W (VIEW_WIDTH - 50) /15
#define MJ_H (VIEW_HEIGH) / 10

@interface TableVC ()
{
    UILabel *bottom;
    UILabel *right;
    UILabel *top;
    UILabel *left;
    UILabel *roomNumLabel;
    UILabel *lastCountLabel;    //剩余牌量
    
    UIButton *huBtn;    //胡牌按钮
    UIButton *pengBtn;  //碰牌按钮
    UIButton *buZhangBtn;   //补张按钮
    UIButton *gangBtn;  //杠拍按钮
    UIButton *chiBtn;   //吃牌按钮
    UIButton *guoBtn;   //过牌按钮
    
    NSUserDefaults *userDefaults;
    int myCount;    //用于保存自己在牌桌的第几位

    NSMutableArray *shouPai;    //当前手牌
    NSMutableArray *shouPaiTmp;    //其他玩家打牌时，用于临时存储，检测是否胡牌
    NSMutableArray *chiArr; //其他玩家打牌时，用于存储可吃牌组合
    NSString *nowCard;  //当前玩家所打出的牌
    NSMutableArray<NSString *> *nowChiPai;    //当前选择的吃牌组合
    NSMutableArray *zhuoMianPai;    //碰掉\吃掉\补张掉的牌
    int whoPut; //当前是谁打牌
    
    UIView *spView15; //15张牌view   未吃未碰未杠
    UIView *spView12; //12张牌View
    UIView *spView9;  //9张牌view
    UIView *spView6;  //6张牌View
    UIView *spView3;  //3张牌View
    
    UIView *chiPaiView; //用于展现可以选择的吃牌
    UIView *zhuoMianPaiView;    //用于展现桌面的牌
    
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
    
    //创建响应管理类
    _acManager = [[ACTIONManager alloc] initArray];
    _acManager.delegate = self;
    
    //存储对象
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    //初始化手牌
    shouPai = [[NSMutableArray alloc] init];
    shouPaiTmp = [[NSMutableArray alloc] init];
    zhuoMianPai = [[NSMutableArray alloc] init];
    
    //初始化手牌view
    [self initShouPaiView];
    
    //初始化功能按钮
    [self initFunctionBtn];
    
    //初始化玩家头像
    bottom = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    [bottom setCenter:CGPointMake(100, VIEW_HEIGH - 74)];
    [bottom setTextColor:[UIColor blackColor]];
    
    right= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    [right setCenter:CGPointMake(VIEW_WIDTH - 100, VIEW_HEIGH / 2)];
    
    top= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    [top setCenter:CGPointMake(VIEW_WIDTH / 2, 50)];
    
    left = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    [left setCenter:CGPointMake(100, VIEW_HEIGH / 2)];
    
    //剩余牌量
    lastCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    [lastCountLabel setCenter:CGPointMake(VIEW_WIDTH / 2, VIEW_HEIGH / 2)];
    roomNumLabel.textColor = [UIColor blackColor];

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
                [spView15 removeFromSuperview];
                [spView12 removeFromSuperview];
                [chiPaiView removeFromSuperview];
                for (UIView *view in [zhuoMianPaiView subviews]) {
                    [view removeFromSuperview];
                }
                [zhuoMianPaiView removeFromSuperview];
                [shouPai removeAllObjects];
                [shouPaiTmp removeAllObjects];
                [chiArr removeAllObjects];
                nowCard = @"";
                [nowChiPai removeAllObjects];
                [zhuoMianPai removeAllObjects];
                [self hideFuncButton];
                [_acManager cleanResponse]; 
                [lastCountLabel removeFromSuperview];
                _conversation = nil;
                [_user.client closeWithCallback:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"用户client关闭");
                    }
                }];
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
            myCount = count;    //我是第几个玩家
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
    
    [conversion sendMessage:[AVIMMessage messageWithContent:message]  callback:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"发送消息:%@",message);
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

/**
 *展示手牌
 */
- (void) showShouPaiView {
    lastCountLabel.text = [NSString stringWithFormat:@"剩余%d张",_thisGame.lastCount];
    [self.view addSubview:lastCountLabel];
    
    //当前13张
    if (shouPai.count == 13) {
        int count = 0;
        NSArray *arr = [spView15 subviews];
        for (UIButton *btn in arr) {
            if (count < 13) {
                //设置牌面
                [btn setTitle:shouPai[count] forState:UIControlStateNormal];
                count ++;
            }else {
                [btn setTitle:@"" forState:UIControlStateNormal];
            }
            
            //手牌只有13张时，按钮不可用
            [btn setEnabled:NO];
        }
        
        [self.view addSubview:spView15];    //使用15张牌模型
    }
    
    
    //当前14张
    if (shouPai.count == 14) {
        int count = 0;
        NSArray *arr = [spView15 subviews];
        for (UIButton *btn in arr) {
            if (count < 14) {
                //设置牌面
                if (count == 13) {
                    //跳过一个按钮
                    [btn setEnabled:NO];
                    count++;
                    continue;
                } else {
                    [btn setEnabled:YES];
                }
                [btn setTitle:shouPai[count] forState:UIControlStateNormal];
                count ++;
            } else {
                [btn setEnabled:YES];
                [btn setTitle:shouPai[13] forState:UIControlStateNormal];
            }
        }
        
        [self.view addSubview:spView15];    //使用15张牌模型
    }
    
    //当前10张
    if (shouPai.count == 10) {
        //改为使用12张牌模型
        [spView15 removeFromSuperview];
        int count = 0;
        NSArray *arr = [spView12 subviews];
        for (UIButton *btn in arr) {
            if (count < 10) {
                //设置牌面
                [btn setTitle:shouPai[count] forState:UIControlStateNormal];
                count ++;
            }else {
                [btn setTitle:@"" forState:UIControlStateNormal];
            }
            
            //手牌只有10张时，按钮不可用
            [btn setEnabled:NO];
        }
        
        [self.view addSubview:spView12];    //使用12张牌模型
    }
    
    //当前11张
    if (shouPai.count == 11) {
        //改为使用12张模型
        [spView15 removeFromSuperview];
        int count = 0;
        NSArray *arr = [spView12 subviews];
        for (UIButton *btn in arr) {
            if (count < 11) {
                //设置牌面
                if (count == 10) {
                    //跳过一个按钮
                    [btn setEnabled:NO];
                    count++;
                    continue;
                } else {
                    [btn setEnabled:YES];
                }
                [btn setTitle:shouPai[count] forState:UIControlStateNormal];
                count ++;
            } else {
                [btn setEnabled:YES];
                [btn setTitle:shouPai[10] forState:UIControlStateNormal];
            }
        }
        
        [self.view addSubview:spView12];    //使用12张牌模型
    }
    
    //当前7张
    if (shouPai.count == 7) {
        //改为使用9张牌模型
        [spView12 removeFromSuperview];
        int count = 0;
        NSArray *arr = [spView9 subviews];
        for (UIButton *btn in arr) {
            if (count < 7) {
                //设置牌面
                [btn setTitle:shouPai[count] forState:UIControlStateNormal];
                count ++;
            }else {
                [btn setTitle:@"" forState:UIControlStateNormal];
            }
            
            //手牌只有7张时，按钮不可用
            [btn setEnabled:NO];
        }
        
        [self.view addSubview:spView9];    //使用9张牌模型
    }
    
    //当前8张
    if (shouPai.count == 8) {
        //改为使用9张模型
        [spView12 removeFromSuperview];
        int count = 0;
        NSArray *arr = [spView9 subviews];
        for (UIButton *btn in arr) {
            if (count < 8) {
                //设置牌面
                if (count == 7) {
                    //跳过一个按钮
                    [btn setEnabled:NO];
                    count++;
                    continue;
                } else {
                    [btn setEnabled:YES];
                }
                [btn setTitle:shouPai[count] forState:UIControlStateNormal];
                count ++;
            } else {
                [btn setEnabled:YES];
                [btn setTitle:shouPai[7] forState:UIControlStateNormal];
            }
        }
        
        [self.view addSubview:spView9];    //使用9张牌模型
    }
    
    //当前4张
    if (shouPai.count == 4) {
        //改为使用6张牌模型
        [spView9 removeFromSuperview];
        int count = 0;
        NSArray *arr = [spView6 subviews];
        for (UIButton *btn in arr) {
            if (count < 4) {
                //设置牌面
                [btn setTitle:shouPai[count] forState:UIControlStateNormal];
                count ++;
            }else {
                [btn setTitle:@"" forState:UIControlStateNormal];
            }
            
            //手牌只有4张时，按钮不可用
            [btn setEnabled:NO];
        }
        
        [self.view addSubview:spView6];    //使用6张牌模型
    }
    
    //当前5张
    if (shouPai.count == 5) {
        //改为使用6张模型
        [spView9 removeFromSuperview];
        int count = 0;
        NSArray *arr = [spView6 subviews];
        for (UIButton *btn in arr) {
            if (count < 5) {
                //设置牌面
                if (count == 4) {
                    //跳过一个按钮
                    [btn setEnabled:NO];
                    count++;
                    continue;
                } else {
                    [btn setEnabled:YES];
                }
                [btn setTitle:shouPai[count] forState:UIControlStateNormal];
                count ++;
            } else {
                [btn setEnabled:YES];
                [btn setTitle:shouPai[4] forState:UIControlStateNormal];
            }
        }
        
        [self.view addSubview:spView6];    //使用6张牌模型
    }
    
    //当前1张
    if (shouPai.count == 1) {
        //改为使用3张牌模型
        [spView6 removeFromSuperview];
        int count = 0;
        NSArray *arr = [spView3 subviews];
        for (UIButton *btn in arr) {
            if (count < 2) {
                //设置牌面
                [btn setTitle:shouPai[count] forState:UIControlStateNormal];
                count ++;
            }else {
                [btn setTitle:@"" forState:UIControlStateNormal];
            }
            
            //手牌只有1张时，按钮不可用
            [btn setEnabled:NO];
        }
        
        [self.view addSubview:spView3];    //使用3张牌模型
    }
    
    //当前2张
    if (shouPai.count == 2) {
        //改为使用3张模型
        [spView6 removeFromSuperview];
        int count = 0;
        NSArray *arr = [spView3 subviews];
        for (UIButton *btn in arr) {
            if (count < 2) {
                //设置牌面
                if (count == 1) {
                    //跳过一个按钮
                    [btn setEnabled:NO];
                    count++;
                    continue;
                } else {
                    [btn setEnabled:YES];
                }
                [btn setTitle:shouPai[count] forState:UIControlStateNormal];
                count ++;
            } else {
                [btn setEnabled:YES];
                [btn setTitle:shouPai[1] forState:UIControlStateNormal];
            }
        }
        
        [self.view addSubview:spView3];    //使用3张牌模型
    }
    
    //展现桌面牌
    zhuoMianPaiView.frame = CGRectMake(zhuoMianPaiView.frame.origin.x, zhuoMianPaiView.frame.origin.y, zhuoMianPai.count * 3 * MJ_W, MJ_H);
    for (UIView *view in [zhuoMianPaiView subviews]) {
        [view removeFromSuperview];
    }
    int count = 0;
    for (NSArray *arr in zhuoMianPai) {
        //写桌面牌
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(count * 3 * MJ_W + count * 10, 0, MJ_W * 3 - 10,MJ_H)];
        [label setText:[NSString stringWithFormat:@"%@   %@   %@",arr[0],arr[1],arr[2]]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setBackgroundColor:[UIColor lightGrayColor]];
        [zhuoMianPaiView addSubview:label];
        count ++;
    }
    if (![zhuoMianPaiView superview]) {
        [self.view addSubview:zhuoMianPaiView];
    }
}

/**
 *初始化各种手牌模型View
 */
- (void) initShouPaiView {
    //15张牌View
    spView15 = [[UIView alloc] initWithFrame:CGRectMake(10, VIEW_HEIGH - MJ_H - 10,15 * MJ_W, MJ_H)];
    for (int i = 0; i < 15; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        btn.frame = CGRectMake(i * MJ_W, 0, MJ_W, MJ_H);
        [btn addTarget:self action:@selector(putOneCard:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundColor:[UIColor yellowColor]];
        [spView15 addSubview:btn];
    }
    
    //12张牌View
    spView12 = [[UIView alloc] initWithFrame:CGRectMake(10 + 3 * MJ_W + 10, VIEW_HEIGH - MJ_H - 10, 12 * MJ_W, MJ_H)];
    for (int i = 0; i < 12; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        btn.frame = CGRectMake(i * MJ_W, 0, MJ_W, MJ_H);
        [btn addTarget:self action:@selector(putOneCard:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundColor:[UIColor yellowColor]];
        [spView12 addSubview:btn];
    }
    
    //9张牌View
    spView9 = [[UIView alloc] initWithFrame:CGRectMake(10 + 6 * MJ_W + 15, VIEW_HEIGH - MJ_H - 10, 9 * MJ_W, MJ_H)];
    for (int i = 0; i < 9; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        btn.frame = CGRectMake(i * MJ_W, 0, MJ_W, MJ_H);
        [btn addTarget:self action:@selector(putOneCard:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundColor:[UIColor yellowColor]];
        [spView9 addSubview:btn];
    }
    
    //6张牌View
    spView6 = [[UIView alloc] initWithFrame:CGRectMake(10 + 9 * MJ_W + 15, VIEW_HEIGH - MJ_H - 10, 6 * MJ_W, MJ_H)];
    for (int i = 0; i < 6; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        btn.frame = CGRectMake(i * MJ_W, 0, MJ_W, MJ_H);
        [btn addTarget:self action:@selector(putOneCard:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundColor:[UIColor yellowColor]];
        [spView6 addSubview:btn];
    }
    
    //3张牌View
    spView3 = [[UIView alloc] initWithFrame:CGRectMake(10 + 12 * MJ_W + 15, VIEW_HEIGH - MJ_H - 10, 3 * MJ_W, MJ_H)];
    for (int i = 0; i < 3; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        btn.frame = CGRectMake(i * MJ_W, 0, MJ_W, MJ_H);
        [btn addTarget:self action:@selector(putOneCard:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundColor:[UIColor yellowColor]];
        [spView3 addSubview:btn];
    }
    
    //吃牌View
    chiPaiView = [[UIView alloc] initWithFrame:CGRectMake(VIEW_WIDTH - (9 * MJ_W + 180), spView12.frame.origin.y - (MJ_H + 5), 9 * MJ_W + 20, MJ_H)];
    for (int i = 0; i < 3; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        btn.frame = CGRectMake(i * 3 * MJ_W + i * 10, 0, 3 * MJ_W, MJ_H);
        [btn addTarget:self action:@selector(getChiResponse:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundColor:[UIColor yellowColor]];
        [chiPaiView addSubview:btn];
    }
    
    //桌面牌View
    zhuoMianPaiView = [[UIView alloc] initWithFrame:CGRectMake(10, VIEW_HEIGH - MJ_H - 10, 0, MJ_H)];
}

/**
 *初始化功能按钮
 */
- (void) initFunctionBtn {
    //胡牌按钮
    huBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    huBtn.frame = CGRectMake(50, VIEW_HEIGH - 120, 20, 20);
    [huBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [huBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [huBtn setTitle:@"胡" forState:UIControlStateNormal];
    [huBtn setHidden:YES];  //隐藏
    [huBtn addTarget:self action:@selector(huPaiRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:huBtn];
    
    //碰牌按钮
    pengBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pengBtn.frame = CGRectMake(150, VIEW_HEIGH - 120, 20, 20);
    [pengBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [pengBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [pengBtn setTitle:@"碰" forState:UIControlStateNormal];
    [pengBtn setHidden:YES];  //隐藏
    [pengBtn addTarget:self action:@selector(pengPaiRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pengBtn];
    
    //补张按钮
    buZhangBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    buZhangBtn.frame = CGRectMake(250, VIEW_HEIGH - 120, 60, 20);
    [buZhangBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [buZhangBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [buZhangBtn setTitle:@"补张" forState:UIControlStateNormal];
    [buZhangBtn setHidden:YES];  //隐藏
    [buZhangBtn addTarget:self action:@selector(buZhangRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buZhangBtn];
    
    //杠牌按钮
    gangBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    gangBtn.frame = CGRectMake(350, VIEW_HEIGH - 120, 20, 20);
    [gangBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [gangBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [gangBtn setTitle:@"杠" forState:UIControlStateNormal];
    [gangBtn setHidden:YES];  //隐藏
    [gangBtn addTarget:self action:@selector(gangPaiRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gangBtn];
    
    //吃牌按钮
    chiBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    chiBtn.frame = CGRectMake(450, VIEW_HEIGH - 120, 20, 20);
    [chiBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [chiBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [chiBtn setTitle:@"吃" forState:UIControlStateNormal];
    [chiBtn setHidden:YES];  //隐藏
    [chiBtn addTarget:self action:@selector(chiPaiRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:chiBtn];
    
    //过牌按钮
    guoBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    guoBtn.frame = CGRectMake(550, VIEW_HEIGH - 120, 20, 20);
    [guoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [guoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [guoBtn setTitle:@"过" forState:UIControlStateNormal];
    [guoBtn setHidden:YES];  //隐藏
    [guoBtn addTarget:self action:@selector(guoPaiRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:guoBtn];
}

//隐藏功能按钮
- (void) hideFuncButton {
    [huBtn setHidden:YES];
    [pengBtn setHidden:YES];
    [buZhangBtn setHidden:YES];
    [gangBtn setHidden:YES];
    [chiBtn setHidden:YES];
    [guoBtn setHidden:YES];
}

/*
*开始一局新的游戏
*/
- (void) startGames {
    //当局游戏
    _thisGame = [[THISGame alloc] initWithRoomNum:roomNumLabel.text];
    //获取手牌
    shouPai = [_thisGame getShouPai:myCount];
    
    //手牌排序
    shouPai = [[NSMutableArray alloc] initWithArray:[shouPai sortedArrayUsingSelector:@selector(compare:)]];
    
    //如果是庄，抓牌
    if (myCount == 1) {
        //发送消息：抓牌
        [self sendMessageWithConversion:_conversation message:[NSString stringWithFormat:@"1:%d",myCount]];
        //抓一张牌
        [shouPai addObject:[_thisGame getOneCard]];
        
        //展现手牌
        [self showShouPaiView];
    } else {
        [self showShouPaiView];
    }
}

/**
 *其他玩家抓了一张牌的动作
 *@param-count:玩家编号
 */
- (void) othersGetOneCard:(int ) count {
    NSLog(@"玩家:%d抓了一张牌",count);
    _thisGame.lastCount--;
    lastCountLabel.text = [NSString stringWithFormat:@"剩余%d张", _thisGame.lastCount];
}

/**
 *其他玩家打了一张牌的动作
 *胡碰杠吃过的逻辑思路：
 *1、每个玩家在收到其他玩家发出的出牌信息以后，判断自己的最大优先级（胡>碰=补张=杠>吃）
 *2、将自己的最大优先级按照胡=1,碰=2,补张=3,杠=4,吃=5,过=6（因为碰、杠、补张只可能存在一种，所以优先级不同无所谓）发送给其他玩家。
 *3、此时自己知道所有玩家最大能干什么,如果自己此时做了选择（例如碰）,则判断自己是不是最优的（通过ACTIONManager的实例）。
 *4、如果此时自己优先级最高,则执行该动作（通过调用ACTIONManager代理类中的doAction:action方法）
 *5、如果此时自己优先级不是最高(例如有其他玩家可以胡这张牌),则什么也不做,等待。
 *6、当接收到其他玩家（优先级高于自己的玩家）的决策信息（例如胡牌）,自己则无需做任何动作,响应他人动作即可。
 *7、当接收到其他玩家（优先级高于自己的玩家）的决策信息（例如过，不胡）,则判断此时自己的碰牌动作优先级是否最高,如果是,则调用代理类执行该动作,如果不是,则继续等待。
 */
- (void) othersPutOneCard:(int) count card:(NSString *)card {
    NSLog(@"玩家%d打了一张牌:%@",count,card);
    nowCard = card;
    whoPut = count;
    
    //检验胡牌、碰牌/杠牌、吃牌
    //检测胡牌
    [shouPaiTmp removeAllObjects];
    [shouPaiTmp addObjectsFromArray:shouPai];
    [shouPaiTmp addObject:card];
    
    BOOL bHu = NO;
    BOOL bPeng = NO;
    BOOL bGang = NO;
    BOOL bChi = NO;
    //检测是否可胡牌
    if ([_mjManager checkAllPai:shouPaiTmp]) {
        NSLog(@"可胡牌！");
        [huBtn setHidden:NO];
        bHu = YES;
    };
    
    //检测是否可碰牌
    if ([_mjManager checkPengPai:shouPai card:[card intValue]]) {
        NSLog(@"可碰牌！");
        [pengBtn setHidden:NO];
        bPeng = YES;
    }
    
    //检测是否可杠牌或补张
    if ([_mjManager checkGangPai:shouPai card:[card intValue]]) {
        NSLog(@"可杠牌或补张！");
        [gangBtn setHidden:NO];
        [buZhangBtn setHidden:NO];
        bGang = YES;
    }
    
    //检测是否可吃牌
    if (shouPai.count > 2) {
        chiArr = [_mjManager checkChiPai:shouPai card:[card intValue] otherCount:count myCount:myCount];
        if (chiArr.count > 0) {
            NSLog(@"可吃牌:%@",chiArr);
            [chiBtn setHidden:NO];
            bChi = YES;
        }
    }
    
    
    //现将可以做的最大的权限的事情发送出去
    if (bHu) {
        //发送可胡牌消息   消息类型3:自己的编号:1表示可胡牌
        [self sendMessageWithConversion:_conversation message:[NSString stringWithFormat:@"3:%d:1",myCount]];
        [guoBtn setHidden:NO];
    } else if (bPeng ) {
        //发送可碰牌消息   消息类型3:自己的编号:2表示可碰牌
        [self sendMessageWithConversion:_conversation message:[NSString stringWithFormat:@"3:%d:2",myCount]];
        [guoBtn setHidden:NO];
    } else if (bGang ) {
        //发送可杠牌/补张消息   消息类型3:自己的编号:3表示可杠牌/补张（并且跳过一个编号）
        [self sendMessageWithConversion:_conversation message:[NSString stringWithFormat:@"3:%d:3",myCount]];
        [guoBtn setHidden:NO];
    }else if (bChi) {
        //发送可吃牌消息   消息类型3:自己的编号:5表示可吃牌
        [self sendMessageWithConversion:_conversation message:[NSString stringWithFormat:@"3:%d:5",myCount]];
        [guoBtn setHidden:NO];
    } else {
        NSLog(@"啥也不能干");
        //发送啥也不能干的消息   消息类型3:自己的编号:56表示无动作
        [self sendMessageWithConversion:_conversation message:[NSString stringWithFormat:@"3:%d:6",myCount]];
        if (myCount == count+1 ) {  //我是出牌者的下家
            [self zhuaPaiRequest];  //申请抓牌
        }else if (myCount == 0 && count == 3) {
            [self zhuaPaiRequest];  //申请抓牌
        }
        
    }

    
}

//申请胡牌
- (void) huPaiRequest {
    NSLog(@"玩家申请胡牌!");
    [_acManager getResponse:myCount resType:@"1" myCount:myCount];
}

//申请碰牌
- (void) pengPaiRequest {
    NSLog(@"玩家申请碰牌!");
    [_acManager getResponse:myCount resType:@"2" myCount:myCount];
}

//申请补张
- (void) buZhangRequest {
    NSLog(@"玩家申请杠牌!");
    [_acManager getResponse:myCount resType:@"3" myCount:myCount];
}

//申请杠牌
- (void) gangPaiRequest {
    NSLog(@"玩家申请杠牌!");
    [_acManager getResponse:myCount resType:@"4" myCount:myCount];
}

//申请吃牌
- (void) chiPaiRequest {
    NSLog(@"玩家申请吃牌!");
    //弹出可选则的吃牌
    NSArray<UIButton *> *btnArr = [chiPaiView subviews];
    
    for (int i = 0; i < 3 ; i++) {
        if (3 - i > chiArr.count) {
            [btnArr[i] setHidden:YES];
        }else {
            NSArray<NSString *> *tempArr= chiArr[2-i];
            [btnArr[i] setHidden:NO];
            [btnArr[i] setTitle:[self sordChiPai:tempArr[0] second:tempArr[1] third:nowCard] forState:UIControlStateNormal];
        }
    }
    [self.view addSubview:chiPaiView];
}

//将可吃的牌进行排序后输出
- (NSString *) sordChiPai:(NSString *)first second:(NSString *)second third:(NSString *)third {
    NSArray<NSString *> *temp = [@[first,second,third] sortedArrayUsingSelector:@selector(compare:)];
    return [NSString stringWithFormat:@"%d:%d:%d",[temp[0] intValue],[temp[1] intValue],[temp[2] intValue]];
}

//选择如何吃，向ActionManager发送吃牌请求
- (void) getChiResponse:(id) sender{
    UIButton *btn = sender;
    NSString *tmp = [btn titleForState:UIControlStateNormal];
    //将可吃牌进行临时存储
    nowChiPai = [[NSMutableArray alloc] initWithArray:[tmp componentsSeparatedByString:@":"]];
    [_acManager getResponse:myCount resType:@"5" myCount:myCount];
    [chiPaiView removeFromSuperview];
}

//过牌
- (void) guoPaiRequest {
    NSLog(@"玩家选择过牌!");
    [self sendMessageWithConversion:_conversation message:[NSString stringWithFormat:@"3:%d:6",myCount]];
    //隐藏所有功能按钮
    [self hideFuncButton];
    if (myCount == whoPut+1 ) {  //我是出牌者的下家
        [self zhuaPaiRequest];  //申请抓牌
    }else if (myCount == 0 && whoPut == 3) {
        [self zhuaPaiRequest];  //申请抓牌
    }
}

//申请抓牌
- (void) zhuaPaiRequest {
    NSLog(@"玩家申请抓牌!");
    [_acManager getResponse:myCount resType:@"6" myCount:myCount];
}

- (void) doAction:(int) action  {
    switch (action) {
        case 1: //胡牌动作
            //发送胡牌消息
            NSLog(@"玩家%d胡牌!",myCount);
            break;
        case 2: //碰牌动作
            NSLog(@"玩家%d碰牌!",myCount);
            //发送碰牌消息    消息类型4:自己的索引:2代表碰:碰的什么牌
            [self sendMessageWithConversion:_conversation message:[NSString stringWithFormat:@"4:%d:2:%d",myCount,[nowCard intValue]]];
            [self doPengPai:nowCard];
            break;
        case 3: //补张动作
            NSLog(@"玩家%d补张!",myCount);
            break;
        case 4: //杠动作
            NSLog(@"玩家%d杠!",myCount);
            break;
        case 5: //吃牌动作
            NSLog(@"玩家%d吃牌!",myCount);
            //发送吃牌消息    消息类型4:自己的索引:5代表吃:怎么吃(如25-26-27)
            [self sendMessageWithConversion:_conversation message:[NSString stringWithFormat:@"4:%d:5:%@-%@-%@",myCount,nowChiPai[0],nowChiPai[1],nowChiPai[2]]];
            [self doChiPai:nowChiPai card:nowCard];
            break;
        case 6: //如果我是下家 抓牌
            NSLog(@"玩家%d抓牌!",myCount);
            //发送消息：抓牌
            [self sendMessageWithConversion:_conversation message:[NSString stringWithFormat:@"1:%d",myCount]];
            //抓一张牌
            [shouPai addObject:[_thisGame getOneCard]];
            //刷新牌面
            [self showShouPaiView];
            break;
        default:
            break;
    }
    
    //隐藏功能按钮清空
    [self hideFuncButton];
    
}

//执行动作
//碰牌 card:碰的什么牌
- (void) doPengPai:(NSString *) card {
    int count = 0;
    for (NSString *str in shouPai) {
        if ([str isEqualToString:card]) {
            break;
        }
        count ++;
    }
    
    //移除碰的牌
    [shouPai removeObjectsInRange:NSMakeRange(count, 2)];
    //加入底牌数组
    [zhuoMianPai addObject:[NSArray arrayWithObjects:card,card,card,nil]];
    
    //刷新牌面
    [self showShouPaiView];
    
}

//吃牌 chiPaiArr:吃牌组合   card:被吃的牌
- (void) doChiPai:(NSMutableArray *) chiPaiArr card:(NSString *) card {
    NSLog(@"------%@",zhuoMianPai);
    int countBig = -1,countSmall = -1;
    //寻找吃的牌
    for (int i = 0; i < 3; i ++) {
        if ([chiPaiArr[i] isEqualToString:card]) {
            continue;
        } else {
            int count = 0;
            for (NSString *str in shouPai) {
                if ([str isEqualToString:chiPaiArr[i]]) {
                    if (countSmall == -1) {
                        countSmall = count;
                        break;
                    } else {
                        countBig = count;
                        break;
                    }
                }
                count ++;
            }
        }
    }
    
    //移除吃的牌
    [shouPai removeObjectAtIndex:countBig];
    [shouPai removeObjectAtIndex:countSmall];
    
    //加入底牌数组
    [zhuoMianPai addObject:chiPaiArr];
    
    //刷新牌面
    [self showShouPaiView];
}

/**
 *打一张牌
 */
- (void) putOneCard:(id) sender {
    UIButton *btn = sender;
    NSString *str = [btn titleForState:UIControlStateNormal];
    NSLog(@"出牌：%@",str);
    //_thisGame.lastCount --;     //牌库-1
    
    //出掉手牌
    int count = 0;
    for (NSString *strTmp in shouPai) {
        if ([strTmp isEqualToString:str]) {
            [shouPai removeObjectAtIndex:count];
            break;
        }
        count ++;
    }
    
    [self showShouPaiView];
    
    //发送出牌消息
    [self sendMessageWithConversion:_conversation message:[NSString stringWithFormat:@"2:%d:%d",myCount,[str intValue]]];
}

/*!
 对话中有新成员加入的通知。
 @param conversation － 所属对话
 @param clientIds - 加入的新成员列表
 @param clientId - 邀请者的 id
 @return None.
 */
-(void)conversation:(AVIMConversation *)conversation membersAdded:(NSArray *)clientIds byClientId:(NSString *)clientId {
    NSLog(@"玩家进入:%@",clientIds);
    
    for (NSString *clientId in clientIds) {
        if ([clientId isEqualToString:_user.clientId]) {
            continue;
        }
        Player *newPlayer = [[Player alloc] initWithClientId:clientId];
        [_playerArr insertObject:newPlayer atIndex:_conversation.members.count - 1];
        [_playerArr removeLastObject];
    }
    
    [self setPlayers];  //重新设置名字
    
    //玩家已达到4个，开始游戏
    Player *player = _playerArr[3];
    NSLog(@"%@",player.clientId);
    if (player.clientId != nil) {
        [self startGames];
    }
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


/**
 *接收消息，消息类型:
 *1:count 抓牌:抓牌者在玩家数组的索引
 *2:count:card 打牌:打牌者在玩家数组的索引:打的牌
 *3:count:cardCount:type 打牌可以做的响应(胡碰杠吃过):响应者在玩家数组的索引:打牌者在玩家数组的索引:响应类型
 *4:count:2代表碰:碰的什么牌
 */
- (void) conversation:(AVIMConversation *)conversation didReceiveCommonMessage:(AVIMMessage *)message {
    NSLog(@"收到消息：%@",message.content);
    NSArray<NSString *> *msg = [message.content componentsSeparatedByString:@":"];
    
    switch ([msg[0] intValue]) {
        case 1: //其他玩家抓牌
            [self othersGetOneCard:[msg[1] intValue]];
            break;
        case 2: //其他玩家打牌
            [self othersPutOneCard:[msg[1] intValue] card:msg[2]];
            break;
        case 3: //其他玩家响应
            [_acManager getResponse:[msg[1] intValue] resType:msg[2] myCount:myCount];
            break;
        case 4: //其他玩家执行动作
            [_acManager cleanResponse];
        default:
            break;
    }
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
