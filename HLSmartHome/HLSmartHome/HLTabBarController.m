//
//  HLTabBarController.m
//  HLSmartHome
//
//  Created by HarwordLiu on 16/4/19.
//  Copyright © 2016年 HarwordLiu. All rights reserved.
//

#import "HLTabBarController.h"
#import "HLHomeViewController.h"
#import "HLMoreViewController.h"


@interface HLTabBarController ()

@end

@implementation HLTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatSubVC];
}

- (void)creatSubVC {
    HLHomeViewController *homeVC = [[HLHomeViewController alloc] init];
    [self addChild:homeVC image:@"home" imageSele:@"home" title:@"room"];
    
//    HLMoreViewController *moreVC = [[HLMoreViewController alloc] init];
//    [self addChild:moreVC image:@"more" imageSele:@"more" title:@"more"];
    
    
}

- (void)addChild:(UIViewController *)childVC
           image:(NSString *)image
       imageSele:(NSString *)imageSele
           title:(NSString *)title{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:childVC];
    childVC.tabBarItem.title = title;
    childVC.tabBarItem.image =
    [UIImage imageNamed:image];
    childVC.tabBarItem.selectedImage =
    [[UIImage imageNamed:imageSele] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    // 取消tabbar文字渲染效果,属性字符串
    NSMutableDictionary *dicTemp = [NSMutableDictionary dictionary];
    dicTemp[NSForegroundColorAttributeName] = [UIColor grayColor];
    
    NSMutableDictionary *dicTempTwo = [NSMutableDictionary dictionary];
    dicTempTwo[NSForegroundColorAttributeName] = [UIColor blackColor];
    
    [childVC.tabBarItem
     setTitleTextAttributes:dicTemp forState:UIControlStateNormal];
    [childVC.tabBarItem setTitleTextAttributes:dicTempTwo forState:
     UIControlStateSelected];
    
    [self addChildViewController:nav];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
