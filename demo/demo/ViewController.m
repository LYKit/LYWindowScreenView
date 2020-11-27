//
//  ViewController.m
//  demo
//
//  Created by langezhao on 2019/12/3.
//  Copyright © 2019 学习. All rights reserved.
//

#import "ViewController.h"
#import "LYWindowScreenView.h"
#import "ViewControllerTwo.h"
#import "ViewControllerFour.h"

@interface ViewController ()
@property (nonatomic, strong) UILabel *label1;
@property (nonatomic, strong) UILabel *label2;
@property (nonatomic, strong) UILabel *label3;
@property (nonatomic, strong) UIViewController *controller;
@property (strong, nonatomic) IBOutlet UIView *activityView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"页面A";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _activityView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];

}

- (IBAction)didPressedClick:(id)sender {
    [LYWindowScreenView removeFromSuperview:_label1];
    [LYWindowScreenView removeFromSuperview:_label2];
    [LYWindowScreenView removeFromSuperview:_label3];

    {
        _label1 = [UILabel new];
        _label1.text = @"页面A\n\n 优先级1";
        _label1.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
        _label1.frame = CGRectMake(50, 250, CGRectGetWidth(self.view.frame)-100, CGRectGetHeight(self.view.frame)-270);
        _label1.userInteractionEnabled = YES;
        self.label1.numberOfLines = 0;
        _label1.textAlignment = NSTextAlignmentCenter;
        UITapGestureRecognizer *pan = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissone)];
        [_label1 addGestureRecognizer:pan];
        [LYWindowScreenView addWindowScreenView:_label1 pages:@[self.class] level:LYLevelHigh keepAlive:NO controller:nil showCompleted:nil];
    }

    {
        self.label2 = [UILabel new];
        self.label2.text = @"页面A\n\n优先级4";
        self.label2.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.3];
        self.label2.numberOfLines = 0;
        self.label2.userInteractionEnabled = YES;
        _label2.textAlignment = NSTextAlignmentCenter;
        UITapGestureRecognizer *pan = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismisstwo)];
          [self.label2 addGestureRecognizer:pan];
        self.label2.frame = CGRectMake(50, 250, CGRectGetWidth(self.view.frame)-100, CGRectGetHeight(self.view.frame)-270);
        [LYWindowScreenView addWindowScreenView:self.label2 pages:@[self.class] level:LYLevelLow keepAlive:YES controller:nil showCompleted:^{
            self.label2.frame = CGRectMake(50, 700, CGRectGetWidth(self.view.frame)-100, CGRectGetHeight(self.view.frame)-270);
            [UIView animateWithDuration:0.3 animations:^{
                self.label2.frame = CGRectMake(50, 250, CGRectGetWidth(self.view.frame)-100, CGRectGetHeight(self.view.frame)-270);
            }];
        }];
        
        
    }
    
    {
        self.label3 = [UILabel new];
        self.label3.text = @"页面A\n\n 优先级2";
        self.label3.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:1];
        self.label3.numberOfLines = 0;
        _label3.textAlignment = NSTextAlignmentCenter;
        self.label3.userInteractionEnabled = YES;
        UITapGestureRecognizer *pan2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissthree)];
        [self.label3 addGestureRecognizer:pan2];
        self.label3.frame = CGRectMake(50, 250, CGRectGetWidth(self.view.frame)-100, CGRectGetHeight(self.view.frame)-270);
        [LYWindowScreenView addWindowScreenView:self.label3 pages:@[self.class, [ViewControllerTwo class]] level:LYLevelDefault keepAlive:YES  controller:nil showCompleted:nil];
    }
}

- (IBAction)didPressedClickTwo:(id)sender {
    _controller = [ViewControllerTwo new];
    [self.navigationController pushViewController:_controller animated:YES];
}

- (IBAction)activity:(id)sender {
    [LYWindowScreenView addWindowScreenView:self.activityView pages:@[self.class] level:LYLevelDefault keepAlive:YES controller:nil showCompleted:nil];
}

- (IBAction)activityOne:(id)sender {
    [self.navigationController pushViewController:[ViewControllerFour new] animated:YES];
}

- (IBAction)activityTwo:(id)sender {
    [self.navigationController pushViewController:[ViewControllerFour new] animated:YES];
}

- (IBAction)didPressedClose:(id)sender {
    [LYWindowScreenView removeFromSuperview:_activityView];
}

- (void)dismissone {
    [LYWindowScreenView removeFromSuperview:_label1];
    _label1 = nil;
}
- (void)dismisstwo {
    [LYWindowScreenView removeFromSuperview:_label2];
    _label2 = nil;

}
- (void)dismissthree {
    [LYWindowScreenView removeFromSuperview:_label3];
    _label3 = nil;

}
@end
