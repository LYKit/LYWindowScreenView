//
//  LYWindowScreenView.h
//  bangjob
//
//  Created by langezhao on 2019/12/23.
//  Copyright © 2019 com.58. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum : NSInteger {
    LYLevelHigh = -100,
    LYLevelMedium = -1,
    LYLevelDefault = 0,
    LYLevelLow = 100,
} LYWindowScreenLevel;

@interface LYWindowScreenView : UIView


/// 是否关闭所有弹窗
@property (class) BOOL hideAllAlert;

+ (void)jsAddWindowScreenView:(UIView *)view
                    keepAlive:(BOOL)keepAlive
                         page:(NSString *)pageName;


+ (void)addWindowScreenView:(UIView *)view
                       page:(Class)page;

+ (void)addWindowScreenView:(UIView *)view
                  keepAlive:(BOOL)keepAlive
                       page:(Class)page;

+ (void)addWindowScreenView:(UIView *)view
                       page:(Class)page
               showCompleted:(dispatch_block_t)showCompleted;

/// 添加弹框
/// @param view 弹窗视图
/// @param pagesClass 绑定页面归属类，指定后弹窗只会在指定页面类出现,可以指定多个页面
/// @param level 优先级，默认 LYLevelDefault
/// @param keepAlive 弹窗存活，对弹窗进行缓存，默认NO不缓存；离开页面时弹窗消失，重新回到该页面时，弹窗仍在该页面，
/// @param controller 绑定具体的页面，指定弹框的页面实例，默认nil。未设置时未展示的弹窗都会加入等待队列中， 设置后弹窗只有当此页面还在页面栈里时才添加到等待队列中，页面消失，弹窗也移除。一般复杂异步情况下的弹窗使用。
/// @param showCompleted 当视图添加到window上时的回调，即弹窗显示后的回调。
+ (void)addWindowScreenView:(UIView *)view
                       pages:(NSArray *)pages
                      level:(NSInteger)level
                  keepAlive:(BOOL)keepAlive
                controller:(UIViewController *)controller
               showCompleted:(dispatch_block_t)showCompleted;

/// 获取未展示的弹框数据
+ (NSArray *)waitScreenViews;

/// 删除弹框
+ (void)removeFromSuperview:(UIView *)view;

/// 删除当前及未展示的所有弹框
+ (void)removeAllQueueViews;

/// 删除所有等待展示的弹框
+ (void)removeAllWaitQueueViews;

/// 删除所有缓存的弹框
+ (void)removeAllCacheQueueViews;
@end

