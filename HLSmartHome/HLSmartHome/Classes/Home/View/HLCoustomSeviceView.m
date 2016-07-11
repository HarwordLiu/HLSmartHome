//
//  HLCoustomSeviceView.m
//  HLSmartHome
//
//  Created by HarwordLiu on 16/5/4.
//  Copyright © 2016年 HarwordLiu. All rights reserved.
//

#import "HLCoustomSeviceView.h"

@implementation HLCoustomSeviceView

+ (instancetype)getCoustomSeviceViewWithFrame:(CGRect)frame
                                        Index:(NSInteger)index
                                       sevice:(HMService *)service {
    HLCoustomSeviceView *view = [[HLCoustomSeviceView alloc] initWithFrame:frame Index:index sevice:service];
    NSLog(@"%@", NSStringFromCGRect(frame));
    view.service = service;
    view.index = index;
    
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
                        Index:(NSInteger)index
                       sevice:(HMService *)service {
    self = [super initWithFrame:frame];
    if (self) {
        
        
        UIButton *stateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        stateBtn.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        stateBtn.backgroundColor = [UIColor clearColor];
//        [stateBtn setTitle:@"关" forState:UIControlStateNormal];
//        [stateBtn setTitle:@"开" forState:UIControlStateSelected];
        
        NSLog(@"%@", service.localizedDescription);
        
        if ([service.localizedDescription isEqualToString:@"灯泡"]) {
            [stateBtn setImage:[UIImage imageNamed:@"lightOff"] forState:UIControlStateNormal];
            [stateBtn setImage:[UIImage imageNamed:@"lightOn"] forState:UIControlStateSelected];
            [stateBtn addTarget:self action:@selector(clickStateBtn:) forControlEvents:UIControlEventTouchUpInside];
        } else if ([service.localizedDescription isEqualToString:@"窗帘"]) {
            [stateBtn setImage:[UIImage imageNamed:@"window"] forState:UIControlStateNormal];
        } else if ([service.localizedDescription isEqualToString:@"风扇"]) {
            [stateBtn setImage:[UIImage imageNamed:@"fanOff"] forState:UIControlStateNormal];
            [stateBtn setImage:[UIImage imageNamed:@"fanOn"] forState:UIControlStateSelected];
            [stateBtn addTarget:self action:@selector(clickStateBtn:) forControlEvents:UIControlEventTouchUpInside];
        } else if ([service.localizedDescription isEqualToString:@"家门"]) {
            [stateBtn setImage:[UIImage imageNamed:@"door"] forState:UIControlStateNormal];
        } else if ([service.localizedDescription isEqualToString:@"恒温器"]) {
            [stateBtn setImage:[UIImage imageNamed:@"temp"] forState:UIControlStateNormal];
        } else if ([service.localizedDescription isEqualToString:@"窗户"]) {
            [stateBtn setImage:[UIImage imageNamed:@"temp"] forState:UIControlStateNormal];
        }

        [self addSubview:stateBtn];
        
        _stateBtn = stateBtn;
        _stateBtn.alpha = 0;
        
        
        self.deleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.deleBtn.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.deleBtn.backgroundColor = [UIColor redColor];
        self.deleBtn.alpha = 0;
        [self.deleBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.deleBtn];
        
        
    }
    return self;
}

- (void)clickStateBtn:(UIButton *)sender {
    [self.delegate stateBtn:sender SeviceIndex:self.index];
}

- (void)clickBtn:(UIButton *)sender {
    [self removeFromSuperview];
    [self.delegate deleView:self];
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@", event);
    if (!self.lockState) {
        
        UITouch *touch = [touches anyObject];
        _originalLocation = [touch locationInView:self];
    }
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.lockState) {

        UITouch *touch = [touches anyObject];
        CGPoint currentLocation = [touch locationInView:self];
        CGRect frame = self.frame;
        // 适配位置
        frame.origin.x += (currentLocation.x - _originalLocation.x) * kSCREENFRAMEWEIGHT;
        frame.origin.y += (currentLocation.y - _originalLocation.y) * kSCREENFRAMEHEIGHT;
        self.frame = frame;
    }
}


@end
