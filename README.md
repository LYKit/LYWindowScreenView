> App里总会有很多的弹窗，为了美观，大多数弹窗都需要盖住导航栏；这时弹窗会添加到window上以满足需求。但添加到window上的弹窗却不方便管理，也与页面脱离关系。

###window弹窗面临的问题：
1、**多个弹窗可能会产生重叠**：如app启动的时候有2个弹窗，正巧2个弹窗都触发展示，这时候这2个弹窗就会重叠在一起。

2、**弹窗无法与页面关联**：例如网络请求弹窗的数据，弹窗的展示因此而延时，如用户在此期间跳转其他页面，因为是window弹窗，弹窗则会展示在不应该展示的页面上

3、**弹窗无法设置优先级**：一个比较简单的例子：多个弹层的新手引导，用户关闭引导页1时，按顺序呈现引导页2、引导页3， 如果中间有其他弹窗出现的逻辑，应该等待引导页结束再展示。

4、**弹窗无法留活**：一个简单的例子：一个活动弹窗含有2个活动，点击活动A进入详情页，此时window弹窗应该消失，当从详情页返回时，活动弹窗应该继续展示，才能点击进入活动B查看详情。为了避免重新触发弹窗的逻辑，应该对弹窗进行缓存。

5、**弹窗不能自动关闭**：例如用户被迫下线，此时app的所有弹窗都应该自动移除，或者弹窗展示情况下app发生页面跳转，避免弹窗忘记关闭的情况，也应该自动移除现有的弹窗。

问题4效果对比-前：
![t6znx-4jxkk.gif](https://upload-images.jianshu.io/upload_images/7174973-523ac5bfeb22a035.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/250)



问题4效果对比-后：
![tugcl-llxv1.gif](https://upload-images.jianshu.io/upload_images/7174973-65cf15cc74379153.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/250)


###解决方案：
**一、多个弹框重叠冲突：** 这个问题比较好解决，简单的做法是使用信号量来限制当前弹窗的数量，让弹窗一个一个的出现。创建一个弹窗manager，添加show和dismiss方法， show方法lock， dismiss方法 Release Lock。
````
+ (void)showView:(UIView *)view {
    if ([self shareInstance].currentView == nil) {
        // 当前无弹窗展示直接展示
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        [window addSubview:view];
    } else {
        // 当前有弹窗则加入队列中
        LYWindowScreenModel *model = [LYWindowScreenModel new];
        model.view = view;
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
   if ([self shareInstance].arrayWaitViews.count > 0 && [self shareInstance].currentView == nil) {
        for (int i = 0; i < [self shareInstance].arrayWaitViews.count; i++) {
           LYWindowScreenModel *model = [self shareInstance].arrayWaitViews[i];
           if (model.view) {
               UIWindow *window = [UIApplication sharedApplication].delegate.window;
               [window addSubview:view];
           }
        }
    }	
}
````

&emsp;&emsp;但是使用信号量来处理弹窗展示的数量，这种方式只能满足让弹窗一个个出现，没办法删除或者变更未展示的弹框，是不方便对弹窗进行管理的。

&emsp;&emsp;这时候使用队列是一个比较好的选择，在show的时候把弹窗添加进队列中， dismiss的时候从队列里移除，当上一个弹窗dimiss，从队列里选出下一个要展示的，这样也能做到弹窗始终只会有一个正在展示，而未展示的弹窗则在队列中等待展示。






````
+ (void)showView:(UIView *)view {
    if ([self shareInstance].currentView == nil) {
        // 当前无弹窗展示直接展示
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        [window addSubview:view];
    } else {
        // 当前有弹窗则加入队列中
        LYWindowScreenModel *model = [LYWindowScreenModel new];
        model.view = view;
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
````
<br>
**二、弹窗无法与页面关联**： 弹窗要在页面A显示，因为某些延时，当触发添加弹窗逻辑时，当前页面已经变化成页面B， 弹窗不应该展示。 因为之前已经有了弹窗队列，此时应该把弹窗添加到队列中去等待展示，但是此时队列里的弹窗并没有页面限制，即使放进队列里也会在页面B出现。 所以需要对每个弹窗指定一个展示的页面， 当从队列里推出弹窗进行展示时，判断当前页面是否为可展示的页面，如果不是则继续在队列里等待。

````
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
````
<br>
&emsp;&emsp;给弹窗指定页面后，这时候需要对当前页面的变化进行监听，当指定页面出现时弹窗应该及时呈现出来。替换UIViewController的viewWillAppear方法，在页面变化时发送通知，告诉manager页面发生变化，检索队列里是否有此页面等待展示的弹窗。
&emsp;&emsp;考虑到重写viewWillAppear方法后，每次页面变化都会发送通知，可能会带来一定的性能问题， 所以manager只有在队列里有等待的弹窗时才注册通知，无等待的弹窗则不需要页面的变化可以移除通知。（如果有更好的监听页面变化的方法望告之）




````
+ (void)viewWillAppearNotification:(NSNotification *)notification {
    id identifier = notification.object[LYViewControllerClassIdentifier];
    [self viewNeedShowFromQueueWithPage:identifier];
}

+ (void)viewNeedShowFromQueueWithPage:(UIViewController *)page {
    // 当前屏幕有弹框，则不显示
    if ([self shareInstance].currentView) {
        return;
    }
    // 队列里无等待显示的视图
    if (![self shareInstance].arrayWaitViews.count) {
        return;
    }
    // 推出队列中需要展示的视图进行展示
    __block LYWindowScreenModel *model = nil;
    [[self shareInstance].arrayWaitViews enumerateObjectsUsingBlock:^(LYWindowScreenModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.pageClass && obj.view) {
            if ([page isKindOfClass:obj.pageClass]) {
                UIWindow *window = [UIApplication sharedApplication].delegate.window;
                [window addSubview:obj.view];
                model = obj;
                *stop = YES;
            }
        }
    }];
    if (model) {
        [[self shareInstance].arrayWaitViews removeObject:model];
    }
}
````


<br>
**三、设置弹窗优先级**：因为现在有了弹窗等待队列，弹窗的优先级也就可以很好的解决，在添加进队列时，给弹窗设置一个level值，根据level值排序后从队列里推出展示的弹窗自然是优先级比较高的弹窗。
&emsp;&emsp;因为有时候无法确认其他弹框的level值，level的设定建议以场景来设置level，因为同一场景的多个弹窗大部分情况下无需按优先级展示，只要同等level能一个个展示即可。
如：
````
typedef enum : NSUInteger {
    LYLevelHigh = -100, // 优先级最高, 场景如开屏动画
    LYLevelMedium = -1, // 优先级高, 场景如启动完成广告弹窗
    LYLevelDefault = 0, // 优先级一般，场景如新手引导
    LYLevelLow = 100, // 优先级低，场景如常用弹窗
} LYWindowScreenLevel;
````

开屏动画 > 广告 > 引导 > 业务弹窗，这样可以满足app内绝大多数的弹窗展示顺序，如果有变动可再改动level值。

<br>
**四、弹窗无法留活**：还是之前抛出的问题，点击活动A进入详情页，此时window弹窗应该消失，当从详情页返回时，活动弹窗应该继续展示。为了避免再一次执行弹窗的展示逻辑，所以需要对当前的弹窗进行缓存，等待页面重新回来时展示。 这种情况只是页面暂时离开，页面并未从页面路径栈里消失，如果页面已经不存在，那么缓存里的弹窗也应该移除。 
&emsp;&emsp;新建一个弹框的缓存数组，这里并没有放入之前等待队列里， 是因为等待队列里的弹窗都是仍未展示的，无论页面是否新建，当这个页面是弹窗指定的归属类时都可以展示出来。而缓存的弹窗是与具体的页面关联的，如果页面返回再重新进入，页面已经重新构造，上次缓存的弹窗是不应该再展示的，因为页面重新构造后可能会重新触发弹窗的逻辑，这时候可能就会2个相同的弹窗。

Swizzle UIViewController的viewWillDisappear方法，当有需要缓存的弹窗时添加监听，当页面离开时移除当前展示的弹框，并且添加进缓存数组里。
````
+ (void)viewWillDisAppearNotification:(NSNotification *)notification {
    NSString *strClass = notification.object[LYViewControllerClassName];
    id identifier = notification.object[LYViewControllerClassIdentifier];
    if ([self shareInstance].currentView && [strClass isEqualToString:NSStringFromClass([self shareInstance].pageClass)]) {
        if ([self shareInstance].keepAlive) {
            LYWindowScreenModel *model = [LYWindowScreenModel new];
            model.view = [self shareInstance].currentView;
            model.pageClass = [self shareInstance].pageClass;
            model.level = LYLevelHigh;
            model.keepAlive = [self shareInstance].keepAlive;
            model.identifier = identifier;
            model.addCompleted =  [self shareInstance].addCompleted;
            // 添加进缓存数组
            [[self shareInstance].arrayAliveViews addObject:model];
            [self addWaitShowNotification];
        }
        [[self shareInstance].currentView removeFromSuperview];
        [[self shareInstance] setCurrentView:nil];
        [self removeNotification];
    }
}
````


可以通过Controller是否还有navigationController或者presentingViewController来判断当前页面是否已经从页面栈里移除

````
// 如果存活弹框的归属页面已移除，则移除该页面的所有弹框
+ (void)viewDidDisAppearNotification:(NSNotification *)notification  {
    if ([self shareInstance].arrayAliveViews.count) {
        for (int i = 0; i < [self shareInstance].arrayAliveViews.count; i++) {
            LYWindowScreenModel *model = [self shareInstance].arrayAliveViews[i];
            BOOL exist = model.identifier.navigationController || model.identifier.presentingViewController;
            if (!exist) {
                [[self shareInstance].arrayAliveViews removeObject:model];
                [self removeNotification];
            }
        }
    }
}
````


当页面返回重新出现时，弹窗从缓存队列里删除，并且添加进等待队列里。
````
+ (void)viewNeedShowFromQueueWithPage:(UIViewController *)page {
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
````

<br>
**五、自动删除弹窗**：有些app需要登录之后才能展示弹窗，如果用户下线或者被踢，这个用户的弹窗都应该移除。 因为有了队列，当用户下线时移除当前展示的弹窗和队列里等待弹窗就可以统一移除manager管理的所有弹窗。
````
+ (void)removeAllQueueViews {
    [[self shareInstance].arrayAliveViews removeAllObjects];
    [[self shareInstance].arrayWaitViews removeAllObjects];
    [[self shareInstance].currentView removeFromSuperview];
    [[self shareInstance] setCurrentView:nil];
    [self removeNotification];
}
````

<br>
当页面离开时，为避免忘记手动删除弹窗，window展示在其他地方，此页面的弹窗也应该自动删除，这里在问题四里面已经得到解决，在页面离开时自动移除弹窗。

**这里有个坑**：iOS13的present默认是非全屏的展示，present之后页面并不会走viewWillDisappear方法，导致弹窗不会自动移除。 这种情况需要手动去移除弹窗或者走iOS13以前的present方式。



###补充：
因为最终弹窗添加到window上或者移除都是在manager里处理的，有些情况可能弹窗的出现和移除需要动画进行修饰，而等待队列里的弹窗就无法知道具体的动画。这种情况，可以添加一个block来告诉外界该弹窗刚刚被添加到window上，你可自行处理自己的动画操作
````
 [LYWindowScreenView addWindowScreenView:self.label2 page:self.class level:LYLevelLow keepAlive:YES addCompleted:^{
            self.label2.frame = CGRectMake(50, 700, CGRectGetWidth(self.view.frame)-100, CGRectGetHeight(self.view.frame)-270);
            [UIView animateWithDuration:0.3 animations:^{
                self.label2.frame = CGRectMake(50, 250, CGRectGetWidth(self.view.frame)-100, CGRectGetHeight(self.view.frame)-270);
            }];
        }];
````

<br>
###总结
到此，一开始提出的5个window弹窗问题都已得到解决，实现思路比较简单，主要通过队列和监听页面变化来处理指定页面和顺序的问题。由于keywindow的不确行，这里的弹框都是统一添加到appdelegate.window上。 



大致效果：
![tu690-6ylp0.gif](https://upload-images.jianshu.io/upload_images/7174973-50acdcffea9209b3.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/250)



如果能带来帮助的话，麻烦亲给个星~


