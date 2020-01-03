//
//  ViewControllerTwo.m
//  demo
//
//  Created by 赵学良 on 2019/12/24.
//  Copyright © 2019 学习. All rights reserved.
//

#import "ViewControllerTwo.h"
#import "LYWindowScreenView.h"
#import "ViewControllerThree.h"

@interface ViewControllerTwo ()
@property (nonatomic, strong) UILabel *label3;

@end

@implementation ViewControllerTwo

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"页面B";
    self.label3 = [UILabel new];
    self.label3.text = @"页面B\n\n第一个弹框,优先级一般,点击关闭";
    self.label3.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.3];
    _label3.numberOfLines = 0;
    _label3.textAlignment = NSTextAlignmentCenter;
    self.label3.userInteractionEnabled = YES;
    UITapGestureRecognizer *pan2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissthree)];
    [self.label3 addGestureRecognizer:pan2];
    self.label3.frame = CGRectMake(50, 250, CGRectGetWidth(self.view.frame)-100, CGRectGetHeight(self.view.frame)-270);
    [LYWindowScreenView addWindowScreenView:self.label3 page:self.class level:LYLevelDefault keepAlive:YES addCompleted:^{
        NSLog(@"444");
    }];
}

- (void)dismissthree {
    [LYWindowScreenView removeFromSuperview:_label3];
    _label3 = nil;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (IBAction)present:(id)sender {
    // 如果弹窗是添加到keywindow上，模态是另一个keywindow，所以弹窗本身不会出现
    // 如果弹框是iOS13的模态，viewWillDisappear 不会执行
    ViewControllerThree *vc = [ViewControllerThree new];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)dealloc {
    
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
