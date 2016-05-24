//
//  HLHomeViewController.m
//  HLSmartHome
//
//  Created by HarwordLiu on 16/4/19.
//  Copyright © 2016年 HarwordLiu. All rights reserved.
//

#import "HLHomeViewController.h"
#import "HLAddNewViewController.h"
#import "HLCoustomViewController.h"
#import "RLNetWorkTool.h"
#import "NSString+MD5.h"

@interface HLHomeViewController ()<UITableViewDelegate, UITableViewDataSource, HMHomeManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) HMHomeManager *homeManager;
@property (nonatomic, strong) HMHome *activeHome;
@property (nonatomic, strong) HMRoom *activeRoom;

@property (nonatomic, assign) BOOL updataState;

@end

@implementation HLHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initHomeManager];
    [self creatSubView];
    [self drawTestBtn];
    
}

- (void)initHomeManager {
    self.title = @"房间列表";
    
    self.homeManager = [[HMHomeManager alloc] init];
    self.homeManager.delegate = self;
}

- (void)initHomeSetup {
    // 防止循环调用系统
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _updataState = YES;
//        self.homeManager = [[HMHomeManager alloc] init];
//        self.homeManager.delegate = self;
        
        __weak __typeof__(self) weakSelf = self;
        [self.homeManager addHomeWithName:@"My Home" completionHandler:^(HMHome * _Nullable home, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"something wrong with error = %@", error);
            } else {
                // 判断home是否为空
                HMHome *sentHome = home;
                if (home) {
                    [home addRoomWithName:@"badroom" completionHandler:^(HMRoom * _Nullable room, NSError * _Nullable error) {
                        if (error != nil) {
                            NSLog(@"Something went wrong when attempting to create our room. %@", error.localizedDescription);
                        } else {
                            [weakSelf updateControllerWithHome:sentHome];
                        }
                    }];
                }
                [weakSelf.homeManager updatePrimaryHome:home completionHandler:^(NSError * _Nullable error) {
                    if (error != nil) {
                        NSLog(@"updatePrimaryHomeWithError: %@", error);
                    }
                }];
            }
        }];
    });
    
}


#pragma mark - homeManager delegate
// 获取系统权限 回调方法更新homes数据
- (void)homeManagerDidUpdateHomes:(HMHomeManager *)manager {
    if (self.homeManager.primaryHome) {
        _activeHome = self.homeManager.primaryHome;
        [self updateControllerWithHome:self.homeManager.primaryHome];
    } else {
        [self initHomeSetup];
    }
    [self.tableView reloadData];
}

- (void)updateControllerWithHome:(HMHome *)home {
    if (home) {
        self.activeRoom = home.rooms.firstObject;
        
    }
}




- (void)viewDidAppear:(BOOL)animated {
    if (_updataState) {
        [self.homeManager.delegate homeManagerDidUpdateHomes:self.homeManager];
        [self.tableView reloadData];
    }
}


- (void)creatSubView {
    
    self.navigationItem.title = @"RoomList";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(clickRightBar:)];
    
    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:HOMECELLKEY];
    
}



- (void)clickRightBar:(UIBarButtonItem *)sender {
    HLAddNewViewController *addVC = [[HLAddNewViewController alloc] init];
    [self.navigationController pushViewController:addVC animated:YES];
    
    
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _activeHome.accessories.count ? : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HOMECELLKEY];
    cell.backgroundColor = [UIColor purpleColor];
    cell.textLabel.text = _activeHome.accessories[indexPath.row].name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HLCoustomViewController *coustomVC = [[HLCoustomViewController alloc] init];
    _activeRoom = [self.homeManager.primaryHome.rooms firstObject];
    coustomVC.accessory = _activeHome.accessories[indexPath.row];
//    if (_activeRoom.accessories.count != 0) {
//        coustomVC.accessory = _activeRoom.accessories[indexPath.row];
//    }
    
    [self presentViewController:coustomVC animated:YES completion:^{
        
    }];
}

// 编辑状态
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deleAccessory:indexPath];
}

- (void)deleAccessory:(NSIndexPath *)indexPath {
    HMAccessory *accessory = _activeHome.accessories[indexPath.row];
    [_activeHome removeAccessory:accessory completionHandler:^(NSError * _Nullable error) {
        if (error == nil) {
            NSLog(@"remove success");
            [self.tableView reloadData];
        } else {
            NSLog(@"%s, error = %@", __FUNCTION__, error);
        }
    }];
}

- (void)drawTestBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(200, 200, 200, 200);
    btn.backgroundColor = [UIColor greenColor];
    [btn addTarget:self action:@selector(clickTestBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
}

- (void)clickTestBtn:(UIButton *)sender {
    NSMutableDictionary *optionDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"2", @"appType", @"wxjsa", @"loginName", @"wxjsa", @"password", nil];
    
    NSMutableDictionary *dic = [HLHomeViewController requestOption];
    [dic addEntriesFromDictionary:optionDic];
    [RLNetWorkTool postWithURL:@"http://101.200.183.165:80/rw/app/login.do" Body:dic BodyType:BodyTypeNormol HttpHeader:nil ResponseType:ResponseTypeJSON Progress:^(NSProgress *progress) {
        
    } Success:^(id result) {
        NSLog(@"result === %@", result);
    } Failure:^(NSError *error) {
        NSLog(@"error === %@", error);
    }];
}

+ (NSMutableDictionary *)requestOption
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    // 时间
    long long timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *rtnStr = [NSString stringWithFormat:@"%lld", timeInterval];
    
    // 随机数字
    NSString *num = [NSString stringWithFormat:@"%i", arc4random() % 1000];
    
    // 机密signature
    NSString *signatureResult = [[NSString stringWithFormat:@"%@%@%@",@"realwish-gasering", rtnStr, num] SHA1];
    NSString *sigStr = signatureResult.uppercaseString;
    
    //    NSLog(@"%@", )
    
    
    
    [dic setObject:[NSString stringWithFormat:@"%@", rtnStr] forKey:@"timestamp"];
    [dic setObject:[NSString stringWithFormat:@"%@", num] forKey:@"nonce"];
    [dic setObject:[NSString stringWithFormat:@"%@", sigStr] forKey:@"signature"];
    
    //    [dic setObject:@"20160105" forKey:@"timestamp"];
    //    [dic setObject:@"2016" forKey:@"nonce"];
    //    [dic setObject:@"565EB2156DEB0BA1844DA3451EA4BE6379FA4B21" forKey:@"signature"];
    //
    
    return dic;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
