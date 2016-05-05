//
//  HLAddNewViewController.m
//  HLSmartHome
//
//  Created by HarwordLiu on 16/4/19.
//  Copyright © 2016年 HarwordLiu. All rights reserved.
//

#import "HLAddNewViewController.h"


@interface HLAddNewViewController ()<UITableViewDelegate, UITableViewDataSource, HMAccessoryBrowserDelegate>

@property (nonatomic, strong) HMHomeManager *homeManager;
@property (nonatomic, strong) HMAccessoryBrowser *browser;
@property (nonatomic, strong) NSMutableArray<HMAccessory *> *accrossorers;

@property (nonatomic, strong) UITableView *tableView;


@end

@implementation HLAddNewViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialization];
    [self creatSubView];
}

- (void)initialization {
    self.homeManager = [[HMHomeManager alloc] init];
    
    self.browser = [[HMAccessoryBrowser alloc] init];
    self.browser.delegate = self;
    [self.browser startSearchingForNewAccessories];
    
    self.accrossorers = [NSMutableArray array];
    
}



- (void)creatSubView {
    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ADDCELLKEY];
    
}

#pragma mark - browser delegate

// 添加新的room组会回调这个方法
- (void)accessoryBrowser:(HMAccessoryBrowser *)browser didFindNewAccessory:(HMAccessory *)accessory {
    [self.accrossorers addObject:accessory];
    [_tableView reloadData];
}

// 删除已添加的room组会回调这个方法
- (void)accessoryBrowser:(HMAccessoryBrowser *)browser didRemoveNewAccessory:(HMAccessory *)accessory {
    for (NSInteger i = 0; i < _accrossorers.count; i++) {
        if (_accrossorers[i].name == accessory.name) {
            [_accrossorers removeObjectAtIndex:i];
        }
    }
    [_tableView reloadData];
}

#pragma mark - tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _accrossorers.count ? : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ADDCELLKEY];
    cell.backgroundColor = [UIColor greenColor];
    cell.textLabel.text = _accrossorers[indexPath.row].name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HMAccessory *accessory = _accrossorers[indexPath.row];
    HMRoom *room = _homeManager.primaryHome.rooms.firstObject;
    __weak __typeof__(self) weakSelf = self;
    if (room) {
        [_homeManager.primaryHome addAccessory:accessory completionHandler:^(NSError * _Nullable error) {
            if (error == nil) {
                NSLog(@"%s, error = %@", __FUNCTION__, error);
            } else {
                [weakSelf.homeManager.primaryHome assignAccessory:accessory toRoom:room completionHandler:^(NSError * _Nullable error) {
                    if (error == nil) {
                        NSLog(@"%s, %@", __FUNCTION__, error);
                    } else {
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }
        }];
    }
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
