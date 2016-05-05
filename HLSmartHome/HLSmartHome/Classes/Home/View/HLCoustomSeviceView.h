//
//  HLCoustomSeviceView.h
//  HLSmartHome
//
//  Created by HarwordLiu on 16/5/4.
//  Copyright © 2016年 HarwordLiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLCoustomSeviceView : UIView

@property (nonatomic, assign) CGPoint originalLocation;

@property (nonatomic, assign, getter=isLockState) BOOL lockState;

@property (nonatomic, strong) HMService *service;
@property (nonatomic, assign) NSInteger index;

+ (instancetype)getCoustomSeviceViewWithFrame:(CGRect)frame
                                        Index:(NSInteger)index
                                         sevice:(HMService *)service;


@end
