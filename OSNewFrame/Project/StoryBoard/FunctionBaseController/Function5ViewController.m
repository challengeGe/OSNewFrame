//
//  Function5ViewController.m
//  OSNewFrame
//
//  Created by Macx on 2017/11/29.
//  Copyright © 2017年 Macx. All rights reserved.
//

#import "Function5ViewController.h"

#import "OSSetupViewController.h"

@interface Function5ViewController ()

@end

@implementation Function5ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doSomething:) name:@"refreshUserInfo" object:nil];
}

/**刷新用户信息*/
- (void) doSomething:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSString * notificationName = [notification name];
    if ([notificationName isEqualToString:@"refreshUserInfo"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //这里进行UI更新
            if ([self isKindOfClass:[Function5ViewController class]]) {
                //code....
                [self showAlertWithTitle:@"通知测试" message:@"刷新用户信息" appearanceProcess:^(EJAlertViewController * _Nonnull alertMaker) {
                    alertMaker.addActionCancelTitle(@"好的");
                } actionsBlock:^(NSInteger buttonIndex, UIAlertAction * _Nonnull action, EJAlertViewController * _Nonnull alertSelf) {
                    
                }];
                NSLog(@">>%@",userInfo);
            }
        });
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configurationNavigation];
}

/**
 搜索框
 */
- (void) configurationNavigation
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:UIIMAGE(@"5s") style:UIBarButtonItemStylePlain target:self action:@selector(setupClick:)];
}

- (void)setupClick:(UIBarButtonItem *)sender {
    OSSetupViewController * ctl = [[OSSetupViewController alloc] init];
    ctl.title = @"属性设置";
    [self.navigationController showViewController:ctl sender:self];
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