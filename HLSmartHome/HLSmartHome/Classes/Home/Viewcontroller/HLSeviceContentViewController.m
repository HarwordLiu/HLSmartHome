//
//  HLSeviceContentViewController.m
//  HLSmartHome
//
//  Created by HarwordLiu on 16/5/4.
//  Copyright © 2016年 HarwordLiu. All rights reserved.
//

#import "HLSeviceContentViewController.h"
#import "HLServiceTableViewCell.h"
#import <HomeKit/HomeKit.h>

@interface HLSeviceContentViewController ()<UITableViewDelegate, UITableViewDataSource, HLServiceTableViewCellDelegate, HMAccessoryDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HLSeviceContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor randomColor];
    
    [self registerHomeKitNotification];
    [self creatSubView];
    [self creatNav];
    
    
    
}

- (void)registerHomeKitNotification {
    _accessory.delegate = self;
    for (HMCharacteristic *characteristic in self.service.characteristics) {
        [characteristic enableNotification:YES completionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Something went wrong when enbling nofification a characteristic with error = %@", error);
            }
        }];
    }
}




- (void)creatNav {
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, 64)];
    imageView.image = [UIImage imageNamed:@"backNaV"];
    [self.view addSubview:imageView];
    
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, 64)];
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    [self.view addSubview:toolBar];
    
//    UIView *viewNav = [UIView alloc] initWithFrame:CGRectMake(0, 0, <#CGFloat width#>, <#CGFloat height#>)
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame = CGRectMake(10, 20, 30, 30);
    [btnBack setImage:[UIImage imageNamed:@"photoback"] forState:UIControlStateNormal];
    //    btnBack.layer.cornerRadius = 50;
    [btnBack addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:btnBack];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.height, 40)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = self.service.name;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:label];
    
    
    for (HMCharacteristic *cha in _service.characteristics) {
        NSLog(@"type ==== %@", cha.metadata.format);
    }
    
    
    
}


- (void)creatSubView {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width - 64)];
    tableView.backgroundColor = [UIColor colorWithWhite:0.33 alpha:0.66];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight = 70;
    [self.view addSubview:tableView];
    _tableView = tableView;
    
    [tableView registerClass:[HLServiceTableViewCell class] forCellReuseIdentifier:@"serviceCell"];
    


    

}

#pragma mark - 智能家居空间数据回调更新UI


- (void)accessoryDidUpdateServices:(HMAccessory *)accessory {
    
}

- (void)accessory:(HMAccessory *)accessory service:(HMService *)service didUpdateValueForCharacteristic:(HMCharacteristic *)characteristic {
    NSInteger i = 0;
    for (i = 0; i < service.characteristics.count; i++) {
        if ([service.characteristics[i].uniqueIdentifier isEqual:characteristic.uniqueIdentifier]) {
            break;
        }
    }
    HMCharacteristic *charater = service.characteristics[i];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i - 1 inSection:0];
    HLServiceTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([charater.metadata.format isEqual: @"bool"]) {
        cell.switchMyCell.alpha = 1;
        cell.textLabelName.center = CGPointMake(50, 35);
        cell.switchMyCell.on = [charater.value boolValue];
    } else {
        if ([charater.metadata.maximumValue intValue] < 10) {
            NSLog(@"segement");
             cell.segmentMyCell.selectedSegmentIndex = [charater.value integerValue];
        } else {
            NSLog(@"slider");
            cell.sliderNumber.alpha = 1;
            cell.sliderMyCell.alpha = 1;
            cell.sliderMyCell.minimumValue = [charater.metadata.minimumValue intValue];
            cell.sliderMyCell.maximumValue = [charater.metadata.maximumValue intValue];
            cell.sliderMyCell.value = [charater.value intValue];
            cell.sliderNumber.text = [NSString stringWithFormat:@"%d", [charater.value intValue]];
            NSLog(@"%d", [charater.value intValue]);
            
            
        }
    }
    
    
    
    

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.service.characteristics.count - 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HLServiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"serviceCell"];
    
    
    cell.character = self.service.characteristics[indexPath.row + 1];
    cell.delegate = self;
    
    
    
    
    
    
    
    
    
    return cell;
}

#pragma mark - serviceCell delegate

- (void)changValueSegment:(UISegmentedControl *)sender Characteristic:(HMCharacteristic *)characteristic {
    sender.userInteractionEnabled = NO;
    
    NSLog(@"changeState = %ld charaValue = %@", (long)sender.selectedSegmentIndex, characteristic.value);
    [characteristic writeValue:[NSNumber numberWithInteger:sender.selectedSegmentIndex] completionHandler:^(NSError * _Nullable error) {
        sender.userInteractionEnabled = YES;
        if (error != nil) {
            NSLog(@"change failed %@", error);
        } else {
            NSLog(@"Success");
        }
    }];
}

- (void)changValueSlider:(UISlider *)sender Characteristic:(HMCharacteristic *)characteristic {
    sender.userInteractionEnabled = NO;
    
    NSLog(@"changeState = %f charaValue = %@", sender.value, characteristic.value);
    [characteristic writeValue:[NSNumber numberWithInt:sender.value] completionHandler:^(NSError * _Nullable error) {
        sender.userInteractionEnabled = YES;
        if (error != nil) {
            NSLog(@"change failed %@", error);
        } else {
            NSLog(@"Success");
        }
    }];
}

- (void)changValueSwitch:(UISwitch *)sender Characteristic:(HMCharacteristic *)characteristic {
    sender.userInteractionEnabled = NO;
    
    
    BOOL changeState = YES;
    changeState = [characteristic.value boolValue] ? NO : YES;
    
    
    NSLog(@"changeState = %d charaValue = %@", changeState, characteristic.value);
    [characteristic writeValue:[NSNumber numberWithBool:changeState] completionHandler:^(NSError * _Nullable error) {
        sender.userInteractionEnabled = YES;
        if (error != nil) {
            NSLog(@"change failed %@", error);
        } else {
            NSLog(@"Success");
        }
    }];

    
    
    
    
    
}

- (void)clickBtn:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
