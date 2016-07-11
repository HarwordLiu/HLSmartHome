//
//  HLSeviceContentViewController.h
//  HLSmartHome
//
//  Created by HarwordLiu on 16/5/4.
//  Copyright © 2016年 HarwordLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HomeKit/HomeKit.h>

@interface HLSeviceContentViewController : UIViewController


@property (nonatomic, strong) HMService *service;
@property (nonatomic, strong) HMAccessory *accessory;



@end
