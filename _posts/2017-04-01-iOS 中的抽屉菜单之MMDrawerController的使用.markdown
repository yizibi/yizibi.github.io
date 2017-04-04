---
layout: post
title: iOS 中的抽屉菜单之MMDrawerController的使用
date: 2017-04-01 15:32:24.000000000 +09:00
---



# iOS 中的抽屉菜单

### 前言
在移动应用的软件设计当中,由于扣扣的侧滑抽屉,通过右划展示大半屏的个人UI,在用户交互上,新颖方便,因此在大部分应用也借鉴了扣扣的效果,我们项目中便在此基础上,修改了一下,实际上,扣扣的抽屉效果,在Android和iOS两个不同的平台,还有些稍微不一样:

* iOS 抽屉,二级页面会直接返回到中间的页面;
* Android 抽屉,二级页面会返回到左边页面;

而我们需求是跟Android的抽屉效果接近;

### 先看一下最终效果

![](http://o9zpq25pv.bkt.clouddn.com/ceahuchouti.gif)

### 初期探索

一开始接到这个需求,表示懵了,因为项目已经上线一段时间,不是一开始从头开始,项目的页面结构在一开始就确定好了,要更改项目的结构,容易产生一些意料之外的坑,而且让人摸不着头脑;

下图是app更改前后的结构对比图:

![](http://o9zpq25pv.bkt.clouddn.com/chouti.png?imageMogr2/thumbnail/1000x400)

* 开始尝试一:(不更改原来项目的结构)
   
    实现思路:
	* 用一个父控制器同时管理两个子控制器,也即就是在父控制器的scrollView上添加两个子控制器的view
   	
   	缺点:
   	* 一开始就会加载左边的页面,性能不好
   	* 由于tabbar优先级比较高,往右边滑动拉出左边的时候,或者往左滑动显示中间页面时候,底部的tabbar会突然显示或者消失,体验不好
 
  优化:
  	 * 朋友提示可以截图优化底部tabbar的突然显示或者隐藏,具体就是:用户刚拉出左边的页面,就截取当前显示的页面,然后当左边页面完全消失后,移除中间页面显示最上层的截图,但是这样做,有一个bug,就是用户快速点击左上角两次,会截取正在滑动的页面的图,然后在回到中间页面的时候,会出现视觉上界面元素混乱
	
* 开始尝试二:(不更改项目结构)

	实现思路:
	app一启动,直接在当前window添加左边的控制器,通过添加手势,改变左边VC-View的frame;
	缺点:
	* 左边页面push时,需要切换app的根控制器,然后再切换中间页面时,又需要改变当前窗口的根控制器,来回频繁切换并且都是一开始加载不显示的页面,性能体验不好;
	
### 最终做法

最后,通过查找摸索,采用第三方__MMDrawerController__,通过在基类VC中增加一个开关,来控制哪些页面,可以打开抽屉,哪些不能打开;

* 传送门:[MMDrawerController](https://github.com/mutualmobile/MMDrawerController)
* star✨:7000+经得起考验;
* 效果图:

![](http://o9zpq25pv.bkt.clouddn.com/1649244b7-2.gif)

### MMDrawerController使用简介

#### 优点: 

* 左边VC和右边VC,显示时加载,消失时,销毁,性能较好;
* 左边VC出现的菜单边距可控,还有各种效果,如3D旋转,平移,位移差平移;

#### 使用方法

导入头文件

```
#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "UIViewController+MMDrawerController.h"
```

* 设置根控制器

```
- (MMDrawerController *)drawerController{
    if (!_drawerController) {
        leftViewController *leftVc = [[leftViewController alloc] init];
        LX_NavgationViewController *leftNavVc = [[LX_NavgationViewController alloc] initWithRootViewController:leftVc];
        
        LX_NavgationViewController *centerNavVc = [[LX_NavgationViewController alloc] initWithRootViewController:self.mainTabBarController];
        centerNavVc.navigationBar.hidden = YES;
        _drawerController = [[MMDrawerController alloc] initWithCenterViewController:centerNavVc leftDrawerViewController:leftNavVc rightDrawerViewController:nil];
        _drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
        
        //初始化手势控制
        _drawerController.closeDrawerGestureModeMask =MMCloseDrawerGestureModeAll;
        _drawerController.maximumLeftDrawerWidth = leftSideBarWidth;
        
        //阴影效果
        _drawerController.showsShadow = NO;
        
        //菜单效果
        [_drawerController
         setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
             MMDrawerControllerDrawerVisualStateBlock block;
             block = [[MMExampleDrawerVisualStateManager sharedManager]
                      drawerVisualStateBlockForDrawerSide:drawerSide];
             if(block){
                 block(drawerController, drawerSide, percentVisible);
             }
         }];
    }
    return _drawerController;
}


```

* 设置抽屉菜单的效果;




```

typedef NS_ENUM(NSInteger, MMDrawerAnimationType){
    MMDrawerAnimationTypeNone,  //无效果
    MMDrawerAnimationTypeSlide, //滑动
    MMDrawerAnimationTypeSlideAndScale, //井深效果
    MMDrawerAnimationTypeSwingingDoor, //开门效果
    MMDrawerAnimationTypeParallax,//位移差,视觉差效果
};

   
    [[MMExampleDrawerVisualStateManager sharedManager] setLeftDrawerAnimationType:MMDrawerAnimationTypeParallax];

```

* 基类设置开关 

```

- (void)enableOpenCenterDrawer:(BOOL)enable{
    if (enable == YES) {
        // 能够打开
        [AppDelegate appDelegate].drawerController.closeDrawerGestureModeMask =MMCloseDrawerGestureModeAll;
    } else {
        // 不能打开抽屉
        [AppDelegate appDelegate].drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeNone;
    }
    
}


- (void)enableOpenLeftDrawer:(BOOL)enable
{
    if (enable == YES) {
        // 能够打开
        LX_NavigationController *leftNav = [[LX_NavigationController alloc] initWithRootViewController:[LX_MeViewController meViewController]];
        [[AppDelegate appDelegate].drawerController setLeftDrawerViewController:leftNav];
        [AppDelegate appDelegate].drawerController.closeDrawerGestureModeMask =MMCloseDrawerGestureModeAll;

    } else {
        // 不能打开抽屉
        [AppDelegate appDelegate].drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeNone;

        [[AppDelegate appDelegate].drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
            [[AppDelegate appDelegate].drawerController setLeftDrawerViewController:nil];
        }];
    }
}

- (void)enableOpenRightDrawer:(BOOL)enable
{
    if (enable == YES) {
        // 能够打开
        //                UINavigationController *RightNav = [[UINavigationController alloc] initWithRootViewController:[[RightViewController alloc] init]];
        //        RightViewController *rightVC = [[RightViewController alloc] init];
        //        [ShareApp.drawerController setRightDrawerViewController:rightVC];
    } else {
        // 不能打开抽屉
        [[AppDelegate appDelegate].drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
            [[AppDelegate appDelegate].drawerController setRightDrawerViewController:nil];
        }];
    }
}



```

### 末尾

* demo地址:[LXMMDrawerController](https://github.com/lucyios/LXMMDrawerController)

* 关于控制显示隐藏抽屉的开关参考:

[抽屉效果的一个第三方库的使用MMDrawerController](http://www.jianshu.com/p/573aeb157754)

如果在使用中,有任何问题,欢迎留言,谢谢