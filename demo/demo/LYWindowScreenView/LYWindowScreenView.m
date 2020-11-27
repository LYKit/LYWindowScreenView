//
//  LYWindowScreenView.m
//  bangjob
//
//  Created by langezhao on 2019/12/23.
//  Copyright © 2019 com.58. All rights reserved.
//

#import "LYWindowScreenView.h"
#import "UIViewController+LYPageWillAppear.h"


@interface LYWindowScreenModel : NSObject
@property (nonatomic, strong) UIView *view;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) BOOL keepAlive;
@property (nonatomic, assign) BOOL bindPage;
@property (nonatomic, weak) id identifier;
@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, copy) dispatch_block_t showCompleted;
@property (nonatomic, strong) NSArray<Class> *pagesClass;

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
@property (nonatomic, copy) dispatch_block_t showCompleted;
@property (nonatomic, strong) NSArray<Class> *pagesClass;

@end

@implementation LYWindowScreenView

static BOOL _hideAllAlert = NO;

+ (BOOL)hideAllAlert
{
    return _hideAllAlert;
}

+ (void)setHideAllAlert:(BOOL)hideAllAlert
{
    _hideAllAlert = hideAllAlert;
}

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
        _pagesClass = nil;
        _showCompleted = nil;
    }
    [LYWindowScreenView addKeepAliveNotification];
}

#pragma mark - 添加视图

+ (void)jsAddWindowScreenView:(UIView *)view
                    keepAlive:(BOOL)keepAlive
                         page:(NSString *)pageName
{
    [self addWindowScreenView:view page:NSClassFromString(pageName) level:LYLevelDefault keepAlive:keepAlive controller:nil showCompleted:nil];
}
+ (void)addWindowScreenView:(UIView *)view
                       page:(Class)page
{
    [self addWindowScreenView:view page:page level:LYLevelDefault keepAlive:NO controller:nil showCompleted:nil];
}

+ (void)addWindowScreenView:(UIView *)view
                  keepAlive:(BOOL)keepAlive
                       page:(Class)page
{
    [self addWindowScreenView:view page:page level:LYLevelDefault keepAlive:keepAlive controller:nil showCompleted:nil];
}

+ (void)addWindowScreenView:(UIView *)view
                       page:(Class)page
               showCompleted:(dispatch_block_t)showCompleted
{
    [self addWindowScreenView:view page:page level:LYLevelDefault keepAlive:NO controller:nil showCompleted:showCompleted];
}


+ (void)addWindowScreenView:(UIView *)view
                       page:(Class)page
                      level:(NSInteger)level
                  keepAlive:(BOOL)keepAlive
                 controller:(UIViewController *)controller
               showCompleted:(dispatch_block_t)showCompleted
{
    if (page) {
        [self addWindowScreenView:view pages:@[page] level:level keepAlive:keepAlive controller:controller showCompleted:showCompleted];
    }
}

+ (void)addWindowScreenView:(UIView *)view
                       pages:(NSArray *)pages
                      level:(NSInteger)level
                  keepAlive:(BOOL)keepAlive
                controller:(UIViewController *)controller
               showCompleted:(dispatch_block_t)showCompleted
{
    UIViewController *currentController = [UIViewController currentViewController];
    UIViewController *parentViewController = currentController.parentViewController;
    
    if ([currentController isKindOfClass:[controller class]] && currentController != controller) {
        return;
    }

    if ([self shareInstance].currentView == nil &&
        ([self isMemberOfClass:currentController.class pages:pages] ||
         [self isMemberOfClass:parentViewController.class pages:pages]))
    {
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        NSAssert(window, @"检查window");
        [window addSubview:view];
        [self shareInstance].keepAlive = keepAlive;
        [self shareInstance].pagesClass = pages;
        [self shareInstance].currentView = view;
        [self shareInstance].showCompleted = showCompleted;
        if ([self shareInstance].showCompleted) {
            [self shareInstance].showCompleted();
        }
    } else {
        LYWindowScreenModel *model = [LYWindowScreenModel new];
        model.view = view;
        model.pagesClass = pages;
        model.level = level;
        model.keepAlive = keepAlive;
        model.showCompleted = showCompleted;
        model.controller = controller;
        model.bindPage = controller ? YES : NO;
        [[self shareInstance].arrayWaitViews addObject:model];
        [self addWaitShowNotification];
    }
}


+ (BOOL)isMemberOfClass:(Class)currentClass pages:(NSArray<Class> *)pages {
    BOOL isMember = NO;
    for (Class class in pages) {
        if ([NSStringFromClass(currentClass) isEqualToString:NSStringFromClass(class)]) {
            isMember = YES;
            break;
        }
    }
    return isMember;
}

// 有待显示的视图时添加监听
+ (void)addWaitShowNotification {
    if (([self shareInstance].arrayWaitViews.count ||
        [self shareInstance].arrayAliveViews.count) &&
        ![self shareInstance].bViewWillAppear) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillAppearNotification:) name:LYViewControllerViewDidAppearNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyWindowDidChange:) name:UIWindowDidBecomeKeyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyWindowDidChange:) name:UIWindowDidResignKeyNotification object:nil];
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
        NSLog(@"删除视图");
    } else {
        for (NSInteger i = [self shareInstance].arrayWaitViews.count-1; i >= 0; i--) {
            LYWindowScreenModel *model = [self shareInstance].arrayWaitViews[i];
            if (model.view == view) {
                [[self shareInstance].arrayWaitViews removeObject:model];
            }
        }
        for (NSInteger i = [self shareInstance].arrayAliveViews.count-1; i >= 0 ; i--) {
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
    if ([self shareInstance].currentView && [self isMemberOfClass:NSClassFromString(strClass) pages:[self shareInstance].pagesClass]) {
        
        // 如果当前有展示视图，保留当前视图到队列顶部，避免window出现在下个页面,返回时再存活展示
        if ([self shareInstance].keepAlive) {
            LYWindowScreenModel *model = [LYWindowScreenModel new];
            model.view = [self shareInstance].currentView;
            model.pagesClass = [self shareInstance].pagesClass;
            model.level = LYLevelHigh;
            model.keepAlive = [self shareInstance].keepAlive;
            model.identifier = identifier;
            model.showCompleted =  [self shareInstance].showCompleted;
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
        for (NSInteger i = [self shareInstance].arrayAliveViews.count-1; i >= 0; i--) {
            LYWindowScreenModel *model = [self shareInstance].arrayAliveViews[i];
            BOOL exist = [UIViewController existViewController:model.identifier];
            if (!exist) {
                [[self shareInstance].arrayAliveViews removeObject:model];
                [self removeNotification];
            }
        }
    }
    
    for (NSInteger i = [self shareInstance].arrayWaitViews.count-1; i >= 0; i--) {
        LYWindowScreenModel *obj = [self shareInstance].arrayWaitViews[i];
        if (obj.bindPage && !obj.controller) {
            [[self shareInstance].arrayWaitViews removeObject:obj];
            [self removeNotification];
        }
    }
}


+ (void)keyWindowDidChange:(NSNotification *)notification {
    UIViewController *controller = [UIViewController currentViewController];
    [self viewNeedShowFromQueueWithPage:controller];
}



#pragma mark - 推出队列中需要展示的视图进行展示
+ (void)viewNeedShowFromQueueWithPage:(UIViewController *)page {
    if (!page || ![page isKindOfClass:[UIViewController class]]) {
        return;
    }
    
    // 判断当前页是否有存活的弹框，有则加入队列中。
    if ([self shareInstance].arrayAliveViews.count) {
        for (NSInteger i = [self shareInstance].arrayAliveViews.count-1; i >= 0 ; i--) {
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
    
    // 有指定页面，但页面实例发生变化，都清除
    for (NSInteger i = [self shareInstance].arrayWaitViews.count-1; i >= 0; i--) {
        LYWindowScreenModel *obj = [self shareInstance].arrayWaitViews[i];
        if ([self isMemberOfClass:page.class pages:obj.pagesClass]) {
            if (obj.bindPage && (!obj.controller || obj.controller != page)) {
                [[self shareInstance].arrayWaitViews removeObject:obj];
                [self removeNotification];
            }
        }
    }
    
    // 重新根据优先级排列队列
    [[self shareInstance].arrayWaitViews sortUsingComparator:^NSComparisonResult(LYWindowScreenModel *obj1, LYWindowScreenModel * obj2) {
        return obj1.level <= obj2.level ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    //所有弹窗都不展示
    if (LYWindowScreenView.hideAllAlert) {
        return;
    }
    
    // 推出队列中需要展示的视图进行展示
    __block LYWindowScreenModel *model = nil;
    [[self shareInstance].arrayWaitViews enumerateObjectsUsingBlock:^(LYWindowScreenModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.pagesClass && obj.view) {
            if ([self isMemberOfClass:page.class pages:obj.pagesClass]) {
                UIWindow *window = [UIApplication sharedApplication].delegate.window;
                NSAssert(window, @"检查window");
                [window addSubview:obj.view];
                [self shareInstance].keepAlive = obj.keepAlive;
                [self shareInstance].pagesClass = obj.pagesClass;
                [self shareInstance].currentView = obj.view;
                [self shareInstance].showCompleted = obj.showCompleted;
                if ([self shareInstance].showCompleted) {
                    [self shareInstance].showCompleted();
                }
                model = obj;
                *stop = YES;
            }
        }
    }];
    if (model) {
        [[self shareInstance].arrayWaitViews removeObject:model];
        [self removeNotification];
    }
}


+ (NSArray *)waitScreenViews {
    return [[self shareInstance].arrayWaitViews copy];
}


+ (void)removeAllWaitQueueViews {
    [[self shareInstance].arrayWaitViews removeAllObjects];
    [self removeNotification];
}

+ (void)removeAllCacheQueueViews {
    [[self shareInstance].arrayAliveViews removeAllObjects];
    [self removeNotification];
}

+ (void)removeAllQueueViews {
    [[self shareInstance].arrayAliveViews removeAllObjects];
    [[self shareInstance].arrayWaitViews removeAllObjects];
    [[self shareInstance].currentView removeFromSuperview];
    [[self shareInstance] setCurrentView:nil];
    [self removeNotification];
}

@end
