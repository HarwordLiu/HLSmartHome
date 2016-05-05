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

@interface HLCoustomViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, HMAccessoryDelegate, UITableViewDelegate, UITableViewDataSource>

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

- (void)viewWillDisappear:(BOOL)animated {
    [self saveSqliteCoustomSevice];
}

- (void)initHomeKit {
//    _data = [NSMutableArray array];
    
    if (_accessory.services.count != 0) {
        _data = [NSMutableArray arrayWithArray:_accessory.services];
    }
    

    _accessory.delegate = self;

    
}

- (void)creatSubView {
    
    _stateViewArray = [NSMutableArray array];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 736 * SCREENFRAMEHEIGHT, 414 * SCREENFRAMEWEIGHT)];
    _imageView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_imageView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _menuView = [[UIView alloc] initWithFrame:CGRectMake(736 * SCREENFRAMEHEIGHT, 0, 170 * SCREENFRAMEHEIGHT, 414 * SCREENFRAMEWEIGHT)];
    _menuView.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:_menuView];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, 170, [UIScreen mainScreen].bounds.size.width - 100)];
    tableView.backgroundColor = [UIColor colorWithWhite:0.33 alpha:1];
    tableView.delegate = self;
    tableView.dataSource = self;
    [_menuView addSubview:tableView];
    
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(686 * SCREENFRAMEHEIGHT, 20 * SCREENFRAMEWEIGHT, SCREENFRAMEHEIGHT * 40, SCREENFRAMEWEIGHT * 40);
    [menuBtn setImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];
    [menuBtn setImage:[UIImage imageNamed:@"setSelected"] forState:UIControlStateSelected];
    [menuBtn addTarget:self action:@selector(clickMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:menuBtn];
    _menuBtn = menuBtn;
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20 * SCREENFRAMEWEIGHT, 10 * SCREENFRAMEHEIGHT, 50 * SCREENFRAMEWEIGHT, 50 * SCREENFRAMEHEIGHT);
    backBtn.backgroundColor = [UIColor greenColor];
    [backBtn addTarget:self action:@selector(clickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    _lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _lockBtn.frame = CGRectMake(0, 0, 100, 50);
    _lockBtn.backgroundColor = [UIColor greenColor];
    [_lockBtn setTitle:@"锁定" forState:UIControlStateNormal];
    [_lockBtn setTitle:@"已锁定" forState:UIControlStateSelected];
    [_lockBtn addTarget:self action:@selector(clickLockBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_lockBtn];
    
    _textLabelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 726 * SCREENFRAMEHEIGHT, 50 * SCREENFRAMEHEIGHT)];
    _textLabelTitle.textAlignment = NSTextAlignmentCenter;
    _textLabelTitle.backgroundColor = [UIColor colorWithWhite:0.33 alpha:0.66];
    _textLabelTitle.text = _accessory.name;
    [_textLabelTitle sizeToFit];
    _textLabelTitle.center = CGPointMake([UIScreen mainScreen].bounds.size.height / 2, 30);
    _textLabelTitle.textColor = [UIColor whiteColor];
    [self.view addSubview:_textLabelTitle];
    
    _imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _imageBtn.frame = CGRectMake(0, 0, 200 * SCREENFRAMEHEIGHT, 50 * SCREENFRAMEWEIGHT);
    _imageBtn.center = CGPointMake([UIScreen mainScreen].bounds.size.height / 2, [UIScreen mainScreen].bounds.size.width / 2);
    _imageBtn.backgroundColor = [UIColor colorWithWhite:0.33 alpha:0.66];
    [_imageBtn setTitle:@"设置家居整体背景" forState:UIControlStateNormal];
    [_imageBtn addTarget:self action:@selector(photoFromCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_imageBtn];
    
    _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveBtn.frame = CGRectMake(10, (414 - 90), 50, 50);
    _saveBtn.backgroundColor = [UIColor colorWithWhite:0.33 alpha:0.66];
    _saveBtn.alpha = 1;
    [_saveBtn setTitle:@"存储" forState:UIControlStateNormal];
    [_saveBtn addTarget:self action:@selector(saveSqliteCoustomSevice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_saveBtn];
    
    
    
}


#pragma mark - tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count ? : 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"menuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    HMService *service = _data[indexPath.row];
    cell.textLabel.text = service.localizedDescription;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    for (UIView *stateView in self.stateViewArray) {
        if (stateView.tag == indexPath.row + 1000) {
            return;
        }
    }
    
    [self addSeviceView:indexPath.row];
    [self clickMenuBtn:self.menuBtn];
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
            }
        }
    } else {
        if (_stateViewArray.count != 0) {
            for (HLCoustomSeviceView *view in _stateViewArray) {
                view.lockState = YES;
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
    [self.view addSubview:view];
    [self.stateViewArray addObject:view];
    
    
    
}


// 点击设置按钮
- (void)clickMenuBtn:(UIButton *)sender {
    if (sender.selected == YES) {
        [UIView animateWithDuration:0.5 animations:^{
            _menuView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, 0, 170, [UIScreen mainScreen].bounds.size.width);
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            _menuView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 170, 0, 170, [UIScreen mainScreen].bounds.size.width);
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

        
        return peekViewController;
    }
}

// pop
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    
    [self showViewController:viewControllerToCommit sender:self];
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
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
 
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
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
        [dataBase executeUpdate:@"CREATE TABLE IF NOT EXISTS t_CoustomSevice (IndexRow integer, Frame text)"];
        
        FMResultSet *result = [dataBase executeQuery:@"SELECT * FROM t_CoustomSevice"];
        while (result.next) {
            
            // 获取本地存储数据进行布局
            NSInteger index = [result intForColumn:@"IndexRow"];
            NSString *strFrame = [result stringForColumn:@"Frame"];
            CGRect frame = CGRectFromString(strFrame);
            
            HLCoustomSeviceView *view = [HLCoustomSeviceView getCoustomSeviceViewWithFrame:frame  Index:index sevice:_accessory.services[index]];
            view.backgroundColor = [UIColor colorWithWhite:0.33 alpha:0.66];
            view.tag = 1000 + index;
            [self.view addSubview:view];
            [self.stateViewArray addObject:view];
            
            
        }
        
        [dataBase close];
    }
}

- (void)saveSqliteCoustomSevice {
    BOOL result = [self.dataBase open];
    if (result) {
        [self.dataBase executeUpdate:@"DELETE FROM t_CoustomSevice"];
        if (self.stateViewArray.count != 0) {
            
            for (HLCoustomSeviceView *view in self.stateViewArray) {
//                CGRect myRect = CGRectMake(view.frame.origin.x * kSCREENFRAMEWEIGHT, view.frame.origin.y * kSCREENFRAMEHEIGHT, view.frame.size.width, view.frame.size.height);
                [self.dataBase executeUpdate:@"INSERT INTO t_CoustomSevice (IndexRow, Frame) VALUES (?,?)", [NSNumber numberWithInteger:view.index], NSStringFromCGRect(view.frame)];
            }            
        }
        [self.dataBase close];
    }
    NSLog(@"%ld", _stateViewArray.count);
    
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