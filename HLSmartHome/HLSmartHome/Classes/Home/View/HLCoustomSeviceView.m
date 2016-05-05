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
    HLCoustomSeviceView *view = [[HLCoustomSeviceView alloc] initWithFrame:frame];
    NSLog(@"%@", NSStringFromCGRect(frame));
    view.service = service;
    view.index = index;
    return view;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
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
