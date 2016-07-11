//
//  HLServiceTableViewCell.h
//  HLSmartHome
//
//  Created by HarwordLiu on 16/6/6.
//  Copyright © 2016年 HarwordLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HomeKit/HomeKit.h>

@protocol HLServiceTableViewCellDelegate <NSObject>

- (void)changValueSwitch:(UISwitch *)sender Characteristic:(HMCharacteristic *)characteristic;
- (void)changValueSlider:(UISlider *)sender Characteristic:(HMCharacteristic *)characteristic;
- (void)changValueSegment:(UISegmentedControl *)sender Characteristic:(HMCharacteristic *)characteristic;


@end

@interface HLServiceTableViewCell : UITableViewCell

@property (nonatomic, strong) HMCharacteristic *character;

@property (nonatomic, strong) UILabel *textLabelName;

@property (nonatomic, strong) UISwitch *switchMyCell;

@property (nonatomic, strong) UISlider *sliderMyCell;
@property (nonatomic, strong) UILabel *sliderNumber;

@property (nonatomic, strong) UISegmentedControl *segmentMyCell;


@property (nonatomic, strong) id delegate;

@end
