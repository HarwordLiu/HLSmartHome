//
//  HLSeviceContentViewController.m
//  HLSmartHome
//
//  Created by HarwordLiu on 16/5/4.
//  Copyright © 2016年 HarwordLiu. All rights reserved.
//

#import "HLSeviceContentViewController.h"

@interface HLSeviceContentViewController ()

@end

@implementation HLSeviceContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame = CGRectMake(20, 20, 50, 50);
    btnBack.backgroundColor = [UIColor greenColor];
    btnBack.layer.cornerRadius = 50;
    [btnBack addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnBack];
    
    for (HMCharacteristic *cha in _service.characteristics) {
        NSLog(@"type ==== %@", cha.characteristicType);
    }
    
    
    
    
    
    
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
