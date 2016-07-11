//
//  HLServiceTableViewCell.m
//  HLSmartHome
//
//  Created by HarwordLiu on 16/6/6.
//  Copyright © 2016年 HarwordLiu. All rights reserved.
//

#import "HLServiceTableViewCell.h"

@implementation HLServiceTableViewCell{
    NSArray *_position_3;
}

//static NSString const *position_3[3] = {
//    @"",
//    @"",
//    @""
//};




- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor randomColor];
        [self creatSubView];
    }
    return self;
}

- (void)creatSubView {
    
    _textLabelName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 70)];
    _textLabelName.backgroundColor = [UIColor colorWithWhite:0.33 alpha:0.66];
    _textLabelName.lineBreakMode = NSLineBreakByClipping;
    _textLabelName.numberOfLines = 0;
    _textLabelName.textColor = [UIColor whiteColor];
    
    [self.contentView addSubview:_textLabelName];
    
    _position_3 = @[@"Decreasing", @"Increasing", @"Stopped"];
    
    _switchMyCell = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    _switchMyCell.center = CGPointMake(330, 35);
     _switchMyCell.transform = CGAffineTransformMakeScale(1.25, 1.25);
    [_switchMyCell addTarget:self action:@selector(clickSwitch:) forControlEvents:UIControlEventValueChanged];
    _switchMyCell.alpha = 0;
    [self.contentView addSubview:_switchMyCell];
    
    _sliderMyCell = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
    _sliderMyCell.center = CGPointMake(170, 45);
    _sliderMyCell.thumbTintColor = [UIColor randomColor];
    [_sliderMyCell addTarget:self action:@selector(clickSlider:) forControlEvents:UIControlEventValueChanged];
    _sliderMyCell.alpha = 0;
    [self.contentView addSubview:_sliderMyCell];
    
    _sliderNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    _sliderNumber.backgroundColor = [UIColor colorWithWhite:0.33 alpha:0.66];
    _sliderNumber.text = [NSString stringWithFormat:@"%d", (int)_sliderMyCell.value];
    _sliderNumber.alpha = 0;
    _sliderNumber.textAlignment = NSTextAlignmentCenter;
    _sliderNumber.textColor = [UIColor whiteColor];
    _sliderNumber.center = CGPointMake(345, 45);
    [self.contentView addSubview:_sliderNumber];
    

    
}


- (void)clickSwitch:(UISwitch *)sender {
    [self.delegate changValueSwitch:sender Characteristic:self.character];
}

- (void)clickSlider:(UISlider *)sender {
    [self.delegate changValueSlider:sender Characteristic:self.character];
    _sliderNumber.text = [NSString stringWithFormat:@"%d", (int)_sliderMyCell.value];
}

- (void)clickSegment:(UISegmentedControl *)sender {
    [self.delegate changValueSegment:sender Characteristic:self.character];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

// 重写set方法 进行不同Cell赋值
- (void)setCharacter:(HMCharacteristic *)character {
    if (_character != character) {
        _character = character;
    }
    _switchMyCell.alpha = 0;
    _textLabelName.frame = CGRectMake(0, 0, 300, 200);
    
    
    
    _textLabelName.text = character.metadata.manufacturerDescription;
    [_textLabelName sizeToFit];
    if ([character.metadata.format isEqual: @"bool"]) {
        _switchMyCell.alpha = 1;
        _textLabelName.center = CGPointMake(50, 35);
        _switchMyCell.on = [character.value boolValue];
        
        if ([character.properties containsObject:@"HMCharacteristicPropertyWritable"]) {
            _switchMyCell.enabled = YES;
        } else {
            _switchMyCell.enabled = NO;
        }
        
    } else {
        if ([character.metadata.maximumValue intValue] < 10) {
            NSLog(@"segement");
            _segmentMyCell = [[UISegmentedControl alloc] initWithItems:_position_3];
            
            if ([character.properties containsObject:@"HMCharacteristicPropertyWritable"]) {
                _segmentMyCell.enabled = YES;
            } else {
                _segmentMyCell.enabled = NO;
            }
            
            _segmentMyCell.frame = CGRectMake(0, 0, 330, 30);
            _segmentMyCell.center = CGPointMake(170, 45);
            _segmentMyCell.selectedSegmentIndex = [character.value integerValue];
            [self.contentView addSubview:_segmentMyCell];
            [_segmentMyCell addTarget:self action:@selector(clickSegment:) forControlEvents:UIControlEventValueChanged];
            
        } else {
            NSLog(@"slider");
            _sliderNumber.alpha = 1;
            _sliderMyCell.alpha = 1;
            _sliderMyCell.minimumValue = [character.metadata.minimumValue intValue];
            _sliderMyCell.maximumValue = [character.metadata.maximumValue intValue];
            _sliderMyCell.value = [character.value intValue];
            _sliderNumber.text = [NSString stringWithFormat:@"%d", [character.value intValue]];
            NSLog(@"%d", [character.value intValue]);
            
            if ([character.properties containsObject:@"HMCharacteristicPropertyWritable"]) {
                _sliderMyCell.enabled = YES;
            } else {
                _sliderMyCell.enabled = NO;
            }
        }
    }
}

    
    

    


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
