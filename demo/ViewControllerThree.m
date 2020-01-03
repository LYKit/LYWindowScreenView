//
//  ViewControllerThree.m
//  demo
//
//  Created by 赵学良 on 2019/12/27.
//  Copyright © 2019 学习. All rights reserved.
//

#import "ViewControllerThree.h"
#import "LYWindowScreenView.h"

@interface ViewControllerThree ()
@property (nonatomic, strong) UILabel *label3;

@end

@implementation ViewControllerThree

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"页面C";
    self.label3 = [UILabel new];
    self.label3.text = @"页面C\n\n第一个弹框,优先级一般,点击关闭";
    self.label3.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.3];
    _label3.numberOfLines = 0;
    _label3.textAlignment = NSTextAlignmentCenter;
    self.label3.userInteractionEnabled = YES;
    UITapGestureRecognizer *pan2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissthree)];
    [self.label3 addGestureRecognizer:pan2];
    self.label3.frame = CGRectMake(50, 250, CGRectGetWidth(self.view.frame)-100, CGRectGetHeight(self.view.frame)-270);
    [LYWindowScreenView addWindowScreenView:self.label3 page:self.class level:LYLevelDefault keepAlive:YES addCompleted:^{
        NSLog(@"555");
    }];
    
    
}
- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissthree {
    [LYWindowScreenView removeFromSuperview:_label3];
    _label3 = nil;

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
