//
//  LYWindowScreenView.m
//  bangjob
//
//  Created by 赵学良 on 2019/12/23.
//  Copyright © 2019 com.58. All rights reserved.
//

#import "LYWindowScreenView.h"
#import "UIViewController+LYPageWillAppear.h"


@interface LYWindowScreenModel : NSObject
@property (nonatomic, assign) Class pageClass;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) BOOL keepAlive;
@property (nonatomic, weak) id identifier;
@property (nonatomic, copy) dispatch_block_t addCompleted;

@end

@implementation LYWindowScreenModel
@end



@interface LYWindowScreenView ()
@property (nonatomic, strong) NSMutableArray *arrayWaitViews;
@property (nonatomic, strong) NSMutableArray *arrayAliveViews;

@property (nonatomic, strong) UIView *currentView;
@property (nonatomic, assign) BOOL bViewWillDisappear;
@property (nonatomic, assign) BOOL bViewWillAppear;
@property (nonatomic, assign) BOOL keepAlive;
@property (nonatomic, copy) dispatch_block_t addCompleted;
@property (nonatomic, assign) Class pageClass;

@end

@implementation LYWindowScreenView

+ (LYWindowScreenView *)shareInstance {
    static LYWindowScreenView *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [LYWindowScreenView new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.arrayWaitViews = [NSMutableArray array];
        self.arrayAliveViews = [NSMutableArray array];
        self.bViewWillDisappear = NO;
        self.bViewWillAppear = NO;
    }
    return self;
}

- (void)setCurrentView:(UIView *)currentView {
    _currentView = currentView;
    if (_currentView == nil) {
        _keepAlive = NO;
        _pageClass = nil;
        _addCompleted = nil;
    }
    [LYWindowScreenView addKeepAliveNotification];
}

#pragma mark - 添加视图
+ (void)addWindowScreenView:(UIView *)view
                       page:(Class)page

{
    [self addWindowScreenView:view page:page level:LYLevelDefault keepAlive:NO addCompleted:nil];
}

+ (void)addWindowScreenView:(UIView *)view
                       page:(Class)page
               addCompleted:(dispatch_block_t)addCompleted
{
    [self addWindowScreenView:view page:page level:LYLevelDefault keepAlive:NO addCompleted:addCompleted];
}

+ (void)addWindowScreenView:(UIView *)view
                       page:(Class)page
                      level:(NSInteger)level
                  keepAlive:(BOOL)keepAlive
               addCompleted:(dispatch_block_t)addCompleted
{
    UIViewController *currentController = [UIViewController currentViewController];
    UIViewController *parentViewController = currentController.parentViewController;
        
    if ([self shareInstance].currentView == nil &&
        ([currentController isMemberOfClass:page] ||
         [parentViewController isMemberOfClass:page]))
    {
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        NSAssert(window, @"检查window");
        [window addSubview:view];
        [self shareInstance].keepAlive = keepAlive;
        [self shareInstance].pageClass = page;
        [self shareInstance].currentView = view;
        [self shareInstance].addCompleted = addCompleted;
        if ([self shareInstance].addCompleted) {
            [self shareInstance].addCompleted();
        }
    } else {
        LYWindowScreenModel *model = [LYWindowScreenModel new];
        model.view = view;
        model.pageClass = page;
        model.level = level;
        model.keepAlive = keepAlive;
        model.addCompleted = addCompleted;
        [[self shareInstance].arrayWaitViews addObject:model];
        [self addWaitShowNotification];
    }
}

+ (void)showView:(UIView *)view
            page:(Class)page
{
    UIViewController *currentController = [UIViewController currentViewController];
    if ([self shareInstance].currentView == nil &&
        [currentController isMemberOfClass:page]) {
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        [window addSubview:view];
    } else {
        LYWindowScreenModel *model = [LYWindowScreenModel new];
        model.view = view;
        model.pageClass = page;
        [[self shareInstance].arrayWaitViews addObject:model];
    }
}

+ (void)dismiss:(UIView *)view {
    if ([self shareInstance].currentView == view) {
        // 删除当前弹窗
        [view removeFromSuperview];
        [[self shareInstance] setCurrentView:nil];
    } else {
        // 删除队列中的弹窗
        for (int i = 0; i < [self shareInstance].arrayWaitViews.count; i++) {
           LYWindowScreenModel *model = [self shareInstance].arrayWaitViews[i];
           if (model.view == view) {
               [[self shareInstance].arrayWaitViews removeObject:model];
           }
        }
    }
    
    // 展示下一个弹窗
    if ([self shareInstance].arrayWaitViews.count > 0) {
        for (int i = 0; i < [self shareInstance].arrayWaitViews.count; i++) {
           LYWindowScreenModel *model = [self shareInstance].arrayWaitViews[i];
           if (model.view) {
               UIWindow *window = [UIApplication sharedApplication].delegate.window;
               [window addSubview:view];
           }
        }
    }
}

// 有待显示的视图时添加监听
+ (void)addWaitShowNotification {
    if (([self shareInstance].arrayWaitViews.count ||
        [self shareInstance].arrayAliveViews.count) &&
        ![self shareInstance].bViewWillAppear) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillAppearNotification:) name:LYViewControllerViewWillAppearNotification object:nil];
        [self shareInstance].bViewWillAppear = YES;
    }
}

// 当前视图需要缓存时添加监听
+ (void)addKeepAliveNotification {
    if (![self shareInstance].bViewWillDisappear &&
        [self shareInstance].currentView) {
           [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillDisAppearNotification:) name:LYViewControllerViewWillDisappearNotification object:nil];
           [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidDisAppearNotification:) name:LYViewControllerViewDidDisappearNotification object:nil];
           [self shareInstance].bViewWillDisappear = YES;
    }
}

// 当前无视图，并且没有等待展示的视图时，移除监听
+ (void)removeNotification {
    if (![self shareInstance].arrayWaitViews.count &&
        ![self shareInstance].arrayAliveViews.count &&
        [self shareInstance].currentView == nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self shareInstance].bViewWillDisappear = NO;
        [self shareInstance].bViewWillAppear = NO;
    }
}

#pragma mark - 删除视图
+ (void)removeFromSuperview:(UIView *)view {
    if ([self shareInstance].currentView == view) {
        [view removeFromSuperview];
        [[self shareInstance] setCurrentView:nil];
    } else {
        for (int i = 0; i < [self shareInstance].arrayWaitViews.count; i++) {
            LYWindowScreenModel *model = [self shareInstance].arrayWaitViews[i];
            if (model.view == view) {
                [[self shareInstance].arrayWaitViews removeObject:model];
            }
        }
        for (int i = 0; i < [self shareInstance].arrayAliveViews.count; i++) {
            LYWindowScreenModel *model = [self shareInstance].arrayAliveViews[i];
            if (model.view == view) {
                [[self shareInstance].arrayAliveViews removeObject:model];
            }
        }
    }
    
    if ([self shareInstance].arrayWaitViews.count > 0) {
        [self viewNeedShowFromQueueWithPage:[UIViewController currentViewController]];
    }
    
    [self removeNotification];
}

#pragma mark - notification
+ (void)viewWillAppearNotification:(NSNotification *)notification {
    id identifier = notification.object[LYViewControllerClassIdentifier];
    [self viewNeedShowFromQueueWithPage:identifier];
}

+ (void)viewWillDisAppearNotification:(NSNotification *)notification {
    NSString *strClass = notification.object[LYViewControllerClassName];
    id identifier = notification.object[LYViewControllerClassIdentifier];
    if ([self shareInstance].currentView && [strClass isEqualToString:NSStringFromClass([self shareInstance].pageClass)]) {
        // 如果当前有展示视图，保留当前视图到队列顶部，避免window出现在下个页面,返回时再存活展示
        if ([self shareInstance].keepAlive) {
            LYWindowScreenModel *model = [LYWindowScreenModel new];
            model.view = [self shareInstance].currentView;
            model.pageClass = [self shareInstance].pageClass;
            model.level = LYLevelHigh;
            model.keepAlive = [self shareInstance].keepAlive;
            model.identifier = identifier;
            model.addCompleted =  [self shareInstance].addCompleted;
            [[self shareInstance].arrayAliveViews addObject:model];
            [self addWaitShowNotification];
        }
        [[self shareInstance].currentView removeFromSuperview];
        [[self shareInstance] setCurrentView:nil];
        [self removeNotification];
    }
}

+ (void)viewDidDisAppearNotification:(NSNotification *)notification  {
    // 如果存活弹框的归属页面已移除，则移除该页面的所有弹框
    if ([self shareInstance].arrayAliveViews.count) {
        for (int i = 0; i < [self shareInstance].arrayAliveViews.count; i++) {
            LYWindowScreenModel *model = [self shareInstance].arrayAliveViews[i];
            BOOL exist = [UIViewController existViewController:model.identifier];
            if (!exist) {
                [[self shareInstance].arrayAliveViews removeObject:model];
                [self removeNotification];
            }
        }
    }
}


#pragma mark - 推出队列中需要展示的视图进行展示
+ (void)viewNeedShowFromQueueWithPage:(UIViewController *)page {
    if (!page || ![page isKindOfClass:[UIViewController class]]) {
        return;
    }
    // 判断当前页是否有存活的弹框，有则加入队列中。
    if ([self shareInstance].arrayAliveViews.count) {
        for (int i = 0; i < [self shareInstance].arrayAliveViews.count; i++) {
            LYWindowScreenModel *model = [self shareInstance].arrayAliveViews[i];
            if (page == model.identifier) {
                [[self shareInstance].arrayWaitViews addObject:model];
                [[self shareInstance].arrayAliveViews removeObject:model];
            }
        }
    }

    // 当前屏幕有弹框，则不显示
    if ([self shareInstance].currentView) {
        return;
    }
    // 队列里无等待显示的视图
    if (![self shareInstance].arrayWaitViews.count) {
        return;
    }
    
    // 重新根据优先级排列队列
    [[self shareInstance].arrayWaitViews sortUsingComparator:^NSComparisonResult(LYWindowScreenModel *obj1, LYWindowScreenModel * obj2) {
        return obj1.level <= obj2.level ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    // 推出队列中需要展示的视图进行展示
    __block LYWindowScreenModel *model = nil;
    [[self shareInstance].arrayWaitViews enumerateObjectsUsingBlock:^(LYWindowScreenModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.pageClass && obj.view) {
            if ([page isKindOfClass:obj.pageClass]) {
                UIWindow *window = [UIApplication sharedApplication].delegate.window;
                NSAssert(window, @"检查window");
                [window addSubview:obj.view];
                [self shareInstance].keepAlive = obj.keepAlive;
                [self shareInstance].pageClass = obj.pageClass;
                [self shareInstance].currentView = obj.view;
                [self shareInstance].addCompleted = obj.addCompleted;
                if ([self shareInstance].addCompleted) {
                    [self shareInstance].addCompleted();
                }
                model = obj;
                *stop = YES;
            }
        }
    }];
    if (model) {
        [[self shareInstance].arrayWaitViews removeObject:model];
    }
}


+ (void)removeAllQueueViews {
    [[self shareInstance].arrayAliveViews removeAllObjects];
    [[self shareInstance].arrayWaitViews removeAllObjects];
    [[self shareInstance].currentView removeFromSuperview];
    [[self shareInstance] setCurrentView:nil];
    [self removeNotification];
}

@end
