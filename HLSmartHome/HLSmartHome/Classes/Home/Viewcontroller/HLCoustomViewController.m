//
//  HLCoustomViewController.m
//  HLSmartHome
//
//  Created by HarwordLiu on 16/4/19.
//  Copyright © 2016年 HarwordLiu. All rights reserved.
//

#import "HLCoustomViewController.h"
#import "HLCoustomSeviceView.h"
#import "HLSeviceContentViewController.h"
#import "FMDB.h"
#import "VVSpringCollectionViewFlowLayout.h"
#import <AudioToolbox/AudioToolbox.h>



@interface HLCoustomViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, HMAccessoryDelegate, HLCoustomSeviceViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) NSMutableArray<HMService *> *data;

@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIView *stateView;

@property (nonatomic, assign) CGAffineTransform transform;

@property (nonatomic, strong) UILabel *textLabelTitle;

@property (nonatomic, strong) UIButton *imageBtn;
@property (nonatomic, strong) UIButton *menuBtn;
@property (nonatomic, strong) UIButton *lockBtn;
@property (nonatomic, strong) UIButton *saveBtn;
@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) NSMutableArray<HLCoustomSeviceView *> *stateViewArray;
@property (nonatomic, strong) FMDatabase *dataBase;




@end

@implementation HLCoustomViewController

// 设置横屏显示
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initHomeKit];
    [self creatSubView];
    [self creatTableSqliteInitCoustomSeviceView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self lockCoustomView];
}

- (void)lockCoustomView {
    if (self.lockBtn.isSelected == NO) {
        
        [self clickLockBtn:self.lockBtn];
        
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self saveSqliteCoustomSevice];
}

- (void)initHomeKit {
//    _data = [NSMutableArray array];
    if (_accessory.services.count != 0) {
        _data = [NSMutableArray arrayWithArray:_accessory.services];
    }
    _accessory.delegate = self;
    [self registerHomeKitNotification];
}

- (void)registerHomeKitNotification {
    
    for (HMService *service in self.accessory.services) {
        
        for (HMCharacteristic *characteristic in service.characteristics) {
            [characteristic enableNotification:YES completionHandler:^(NSError * _Nullable error) {
                if (error != nil) {
                    NSLog(@"Something went wrong when enbling nofification a characteristic with error = %@", error);
                }
            }];
        }
    }
}

#pragma mark - 智能家居空间数据回调更新UI


- (void)accessoryDidUpdateServices:(HMAccessory *)accessory {
    
}

- (void)accessory:(HMAccessory *)accessory service:(HMService *)service didUpdateValueForCharacteristic:(HMCharacteristic *)characteristic {
    
    HLCoustomSeviceView *view;
    for (HLCoustomSeviceView *temp in self.stateViewArray) {
        if (temp.service.uniqueIdentifier == service.uniqueIdentifier) {
            view = temp;
            break;
        }
    }
    view.stateBtn.selected = [service.characteristics[1].value boolValue];
    // 火灾闹钟
//    if ([service.localizedDescription isEqualToString:@"烟雾传感器"]) {
//        NSLog(@"%@", characteristic.value);
//        if ([characteristic.value integerValue]> 50) {
//            static dispatch_once_t onceToken;
//            dispatch_once(&onceToken, ^{
//                AudioServicesPlaySystemSound(1001);
//            });
//        }
//        
//    }

}

//// 闹钟
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(alarmClock) userInfo:nil repeats:YES];
//    
//    
//}
//- (void)alarmClock {
//    AudioServicesPlaySystemSound(1005);
//
//}

//调用震动
-(void)systemShake
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

//调用系统铃声
-(void)createSystemSoundWithName:(NSString *)soundName soundType:(NSString *)soundType
{
    NSString *path = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/%@.%@",soundName,soundType];
    if (path) {
        
//        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
        AudioServicesPlaySystemSound(1001);
        
    }
}


- (void)creatSubView {
    
    _stateViewArray = [NSMutableArray array];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 736 * SCREENFRAMEHEIGHT, 414 * SCREENFRAMEWEIGHT)];
    _imageView.backgroundColor = [UIColor randomColor];
    _imageView.image = [self getPlaceHolderPNG];
    [self.view addSubview:_imageView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _menuView = [[UIView alloc] initWithFrame:CGRectMake(736 * SCREENFRAMEHEIGHT, 0, 200 * SCREENFRAMEHEIGHT, 414 * SCREENFRAMEWEIGHT)];
    _menuView.backgroundColor = [UIColor randomColor];
    [self.view addSubview:_menuView];
    
//    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, 170, [UIScreen mainScreen].bounds.size.width - 100)];
//    tableView.backgroundColor = [UIColor colorWithWhite:0.33 alpha:1];
//    tableView.delegate = self;
//    tableView.dataSource = self;
//    [_menuView addSubview:tableView];
    
    
    VVSpringCollectionViewFlowLayout *layout = [[VVSpringCollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(180, 44);
    
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 10, 180, [UIScreen mainScreen].bounds.size.width - 100) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor colorWithWhite:0.22 alpha:0.33];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [_menuView addSubview:collectionView];
    
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"chara"];
    
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(686 * SCREENFRAMEHEIGHT, 10 * SCREENFRAMEWEIGHT, SCREENFRAMEHEIGHT * 40, SCREENFRAMEWEIGHT * 40);
    [menuBtn setImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];
//    [menuBtn setImage:[UIImage imageNamed:@"setSelected"] forState:UIControlStateSelected];
    [menuBtn addTarget:self action:@selector(clickMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:menuBtn];
    _menuBtn = menuBtn;
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(10 * SCREENFRAMEWEIGHT, 10 * SCREENFRAMEHEIGHT, 50 * SCREENFRAMEWEIGHT, 50 * SCREENFRAMEHEIGHT);
    [backBtn setImage:[UIImage imageNamed:@"photoback"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(clickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    _lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _lockBtn.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.width - 80, 80, 50);
    _lockBtn.backgroundColor = [UIColor colorWithWhite:0.33 alpha:0.66];
    [_lockBtn setTitle:@"锁定" forState:UIControlStateNormal];
    [_lockBtn setTitle:@"已锁定" forState:UIControlStateSelected];
    [_lockBtn addTarget:self action:@selector(clickLockBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_lockBtn];
    
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteBtn.frame = CGRectMake(100, [UIScreen mainScreen].bounds.size.width - 80, 100, 50);
    _deleteBtn.backgroundColor = [UIColor colorWithWhite:0.33 alpha:0.66];
    _deleteBtn.alpha = 1;
    [_deleteBtn setTitle:@"删除模式" forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(clickDeleteState:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_deleteBtn];
    
    _textLabelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 726 * SCREENFRAMEHEIGHT, 50 * SCREENFRAMEHEIGHT)];
    _textLabelTitle.textAlignment = NSTextAlignmentCenter;
    _textLabelTitle.backgroundColor = [UIColor colorWithWhite:0.33 alpha:0.66];
    _textLabelTitle.text = _accessory.name;
    [_textLabelTitle sizeToFit];
    _textLabelTitle.center = CGPointMake([UIScreen mainScreen].bounds.size.height / 2, 30);
    _textLabelTitle.textColor = [UIColor whiteColor];
    [self.view addSubview:_textLabelTitle];
    
    _imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _imageBtn.alpha = 0;
    _imageBtn.frame = CGRectMake(0, 0, 200 * SCREENFRAMEHEIGHT, 50 * SCREENFRAMEWEIGHT);
    _imageBtn.center = CGPointMake([UIScreen mainScreen].bounds.size.height / 2, [UIScreen mainScreen].bounds.size.width / 2);
    _imageBtn.backgroundColor = [UIColor colorWithWhite:0.33 alpha:0.66];
    [_imageBtn setTitle:@"设置家居整体背景" forState:UIControlStateNormal];
    [_imageBtn addTarget:self action:@selector(clickImageBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_imageBtn];
    
    
    
//    _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _saveBtn.frame = CGRectMake(10, (414 - 90), 50, 50);
//    _saveBtn.backgroundColor = [UIColor colorWithWhite:0.33 alpha:0.66];
//    _saveBtn.alpha = 1;
//    [_saveBtn setTitle:@"存储" forState:UIControlStateNormal];
//    [_saveBtn addTarget:self action:@selector(saveSqliteCoustomSevice) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_saveBtn];
    
//    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _deleteBtn.frame = CGRectMake(10, (414 - 160), 100, 50);
//    _deleteBtn.backgroundColor = [UIColor colorWithWhite:0.33 alpha:0.66];
//    _deleteBtn.alpha = 1;
//    [_deleteBtn setTitle:@"删除模式" forState:UIControlStateNormal];
//    [_deleteBtn addTarget:self action:@selector(clickDeleteState:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_deleteBtn];
    
    
    
}

- (void)clickDeleteState:(UIButton *)sender {
    if (sender.selected) {
        for (HLCoustomSeviceView *view in self.stateViewArray) {
            view.deleBtn.alpha = 0;
        }
    } else {
        for (HLCoustomSeviceView *view in self.stateViewArray) {
            view.deleBtn.alpha = 1;
            NSLog(@"$$$$$$$$$$");
        }
        
    }
    
    [self clickMenuBtn:self.menuBtn];
    
    sender.selected =! sender.isSelected;
}


#pragma mark - collection delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _data.count ? : 0;
//    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"chara" forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, SCREENFRAMEHEIGHT * 44)];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    HMService *service = _data[indexPath.row];
    if (indexPath.row == 0) {
        label.text = @"点击添加如下配件";
    } else {
        label.text = service.name;
    }
    
    cell.backgroundColor = [UIColor colorWithWhite:0.33 alpha:0.66];
    [cell.contentView addSubview:label];
    
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return;
    }
    
    for (UIView *stateView in self.stateViewArray) {
        if (stateView.tag == indexPath.row + 1000) {
            return;
        }
    }
    
    [self addSeviceView:indexPath.row];
    [self clickMenuBtn:self.menuBtn];
    if (self.lockBtn.isSelected == YES) {
        
        [self clickLockBtn:self.lockBtn];
    }
}





// 点击锁定按钮
- (void)clickLockBtn:(UIButton *)sender {
    if (_stateViewArray.count != 0) {
        for (HLCoustomSeviceView *view in _stateViewArray) {
            [self check3DTouchAvailableWithCell:view];
            
        }
    }
    if (sender.selected) {
        if (_stateViewArray.count != 0) {
            for (HLCoustomSeviceView *view in _stateViewArray) {
                view.lockState = NO;
                view.stateBtn.alpha = 0;
                view.backgroundColor = [UIColor colorWithWhite:0.33 alpha:0.66];
            }
        }
    } else {
        if (_stateViewArray.count != 0) {
            for (HLCoustomSeviceView *view in _stateViewArray) {
                view.lockState = YES;
                view.stateBtn.alpha = 1;
                view.backgroundColor = [UIColor clearColor];

            }
        }
    }
    sender.selected =! sender.isSelected;
}

// 点击添加自定义模块
- (void)addSeviceView:(NSInteger)index {
    HLCoustomSeviceView *view = [HLCoustomSeviceView getCoustomSeviceViewWithFrame:CGRectMake(0, 0, 50 * kSCREENFRAMEWEIGHT, 50 * kSCREENFRAMEHEIGHT) Index:index sevice:_accessory.services[index]];
    view.center = self.view.center;
    view.backgroundColor = [UIColor colorWithWhite:0.33 alpha:0.66];
    view.tag = 1000 + index;
    view.delegate = self;
    [self.view addSubview:view];
    [self.stateViewArray addObject:view];
    
}

#pragma mark - HLCoustomSeviceView delegate

- (void)stateBtn:(UIButton *)sender SeviceIndex:(NSInteger)index {
    HMService *service = _accessory.services[index];
    HMCharacteristic *tempC = service.characteristics[1];
    BOOL changeState = YES;
    changeState = [tempC.value boolValue] ? NO : YES;
    
    NSLog(@"%d", sender.selected ? NO : YES);

    sender.enabled = NO;
    NSLog(@"changeState = %d charaValue = %@", changeState, tempC.value);
    [tempC writeValue:[NSNumber numberWithBool:changeState] completionHandler:^(NSError * _Nullable error) {
        sender.enabled = YES;
        if (error != nil) {
            NSLog(@"change failed %@", error);
        } else {
            NSLog(@"Success");
        }
    }];
    sender.selected =! sender.isSelected;
}

- (void)deleView:(HLCoustomSeviceView *)view {
    [self.stateViewArray removeObject:view];
    
}



// 点击设置按钮
- (void)clickMenuBtn:(UIButton *)sender {
    if (sender.selected == YES) {
        [UIView animateWithDuration:0.5 animations:^{
            _menuView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, 0, 200, [UIScreen mainScreen].bounds.size.width);
            self.imageBtn.alpha = 0;
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            _menuView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 200, 0, 200, [UIScreen mainScreen].bounds.size.width);
            self.imageBtn.alpha = 1;
        }];
    }
    sender.selected =! sender.isSelected;
}

// 返回按钮
- (void)clickBackBtn:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}


#pragma mark - 给stateView 添加3Dtouch
- (void)check3DTouchAvailableWithCell:(HLCoustomSeviceView *)view {
    // 如果开启了3D touch，注册
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:(id)self sourceView:view];
    }
}

// peek
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)context viewControllerForLocation:(CGPoint)point {
    //防止重复加入
    if ([self.presentedViewController isKindOfClass:[HLCoustomSeviceView class]]){
        return nil;
    }
    else {
        HLSeviceContentViewController *peekViewController = [[HLSeviceContentViewController alloc] init];
        ;
//        CGPoint tempPoint = [self.view convertPoint:point toView:self.view];
        
        HLCoustomSeviceView *view = (HLCoustomSeviceView *)context.sourceView;
        
        peekViewController.service = view.service;
        peekViewController.accessory = self.accessory;


        
        return peekViewController;
    }
}

// pop
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    
    [self showViewController:viewControllerToCommit sender:self];
}


- (void)clickImageBtn:(UIButton *)sender {
    
    UIAlertAction *photo = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self photoFromCamera];
    }];
    UIAlertAction *album = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self photoFromAlbum];
    }];
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择设置背景来源" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:photo];
    [alert addAction:album];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
    
    
}

#pragma mark - 相册
- (void)photoFromAlbum{
    
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //pickerImage.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
    }
    pickerImage.delegate = self;
    pickerImage.allowsEditing = NO;
    [self presentViewController:pickerImage animated:YES completion:^{
    }];
    
}


#pragma mark - 调用系统相机拍摄房间内部布局
- (void)photoFromCamera {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = sourceType;
        for (NSString *temp in picker.mediaTypes) {
            NSLog(@"%@", temp);
        }
        picker.showsCameraControls = YES;
        picker.allowsEditing = YES;
//        picker.cameraOverlayView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [self presentViewController:picker animated:YES completion:^{
            
        }];
        
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.imageView.image = image;
        // 将拍摄的照片存入图库
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
        [self savePlaceHolderPNG:image];
    }
    
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.imageView.image = image;


        [self savePlaceHolderPNG:image];
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
 
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

// 存储和获取背景图
- (UIImage *)getPlaceHolderPNG{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", _accessory.name]];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    return image; 
}

- (void)savePlaceHolderPNG:(UIImage *)image {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", _accessory.name]];   // 保存文件的名称
    
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (blHave) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    BOOL result = [UIImagePNGRepresentation(image)writeToFile:filePath atomically:YES];
    if (result) {
        NSLog(@"save success");
    } else {
        NSLog(@"save failed");
    }
}



#pragma mark - 建表存储布局信息


- (void)creatTableSqliteInitCoustomSeviceView {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingString:@"/HLSmartHome.sqlite"];
    NSLog(@"%@", path);
    FMDatabase *dataBase = [FMDatabase databaseWithPath:path];
    self.dataBase = dataBase;
    BOOL open = [dataBase open];
    if (open) {
        [dataBase executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS t_%@ (IndexRow integer, Frame text)", _accessory.name]];
        
        FMResultSet *result = [dataBase executeQuery:[NSString stringWithFormat:@"SELECT * FROM t_%@", _accessory.name]];
        while (result.next) {
            
            // 获取本地存储数据进行布局
            NSInteger index = [result intForColumn:@"IndexRow"];
            NSString *strFrame = [result stringForColumn:@"Frame"];
            CGRect frame = CGRectFromString(strFrame);
            
            HLCoustomSeviceView *view = [HLCoustomSeviceView getCoustomSeviceViewWithFrame:frame Index:index sevice:_accessory.services[index]];
            view.backgroundColor = [UIColor clearColor];
            view.tag = 1000 + index;
            view.delegate = self;

            [self.view addSubview:view];
            [self.stateViewArray addObject:view];
        
        }
        
        [dataBase close];
    }
}

- (void)saveSqliteCoustomSevice {
    BOOL result = [self.dataBase open];
    if (result) {
        NSLog(@"%d", [self.dataBase executeUpdate:[NSString stringWithFormat:@"DELETE FROM t_%@", _accessory.name]]);
        if (self.stateViewArray.count != 0) {
            
            for (HLCoustomSeviceView *view in self.stateViewArray) {
                [self.dataBase executeUpdate:[NSString stringWithFormat:@"INSERT INTO t_%@ (IndexRow, Frame) VALUES (?,?)", _accessory.name], [NSNumber numberWithInteger:view.index], NSStringFromCGRect(view.frame)];
            }            
        }
        [self.dataBase close];
    }
    NSLog(@"%ld", (unsigned long)_stateViewArray.count);
    
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
