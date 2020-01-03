//
//  LYWindowScreenView.h
//  bangjob
//
//  Created by 赵学良 on 2019/12/23.
//  Copyright © 2019 com.58. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum : NSUInteger {
    LYLevelHigh = -100,
    LYLevelMedium = -1,
    LYLevelDefault = 0,
    LYLevelLow = 100,
} LYWindowScreenLevel;

@interface LYWindowScreenView : UIView

+ (void)addWindowScreenView:(UIView *)view
                       page:(Class)page;

+ (void)addWindowScreenView:(UIView *)view
                       page:(Class)page
               addCompleted:(dispatch_block_t)addCompleted;

/// 添加弹框
/// @param view 弹窗视图
/// @param page 绑定页面，指定后弹窗只会在指定页面出现
/// @param level 优先级，
/// @param keepAlive 弹框暂存，默认NO，离开页面时弹窗消失，重新回到该页面时，弹窗仍在该页面，
/// @addCompleted 当视图添加到window上时的回调
+ (void)addWindowScreenView:(UIView *)view
                       page:(Class)page
                      level:(NSInteger)level
                  keepAlive:(BOOL)keepAlive
               addCompleted:(dispatch_block_t)addCompleted;

/// 删除弹框
+ (void)removeFromSuperview:(UIView *)view;

/// 删除当前及未展示的所有弹框
+ (void)removeAllQueueViews;
@end

