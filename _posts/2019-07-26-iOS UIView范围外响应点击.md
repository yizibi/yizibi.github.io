---
layout:     post
title:    "iOS UIView范围外响应点击"
subtitle:   "子控件超出父控件范围,无法响应了"
date: 2019-07-26 13:32:24.000000000 +09:00
author:     "陕西毅杰"
header-img: "img/post-bg-afnbiaodantijiao.jpg"
header-mask: 0.3
catalog:    true
tags:
- iOS技术
- iOS问题
---

## 场景

开发中，总会遇到这样的场景，子控件的响应范围在父控件的响应范围之外，这时候，点击子控件就没响应了；

比如，在我的项目中，tableView的`sectionnHeadView`,加了一个下拉菜单，高度只有80，但是，点击下拉框，下拉的条目无法响应，原因就是：子空间的尺寸在父控件范围之外；

![](http://yizhibi.6chemical.com/1564130199.png)

又例如：按钮一部分悬空在父视图的上面，但是当我们点击该按钮时，超出了父视图的悬空部分不会响应该按钮的点击事件。

![](http://yizhibi.6chemical.com/1564129650.png)

图片来源：[iOS中子视图超出父视图的按钮点击事件响应处理
](https://www.jianshu.com/p/79775e5eda61)

这个搜了好多，比如这个文章[iOS中子视图超出父视图的按钮点击事件响应处理
](https://www.jianshu.com/p/79775e5eda61)，就没用，还有这个[iOS中超出父视图的按钮点击事件响应处理
](https://www.jianshu.com/p/9425ad480ddd),也没用，也是醉了；

最后虽然也是通过重写 -hitTest: 这个方法，但是实现方式不一样，文末有贴代码

> UIView继承自UIResponder所以可以相应一系列的事件，但有时子视图控件超出了自身父视图的范围这时候就无法响应事件了，如果想要子视图响应事件就需要另寻他法了。

## 子视图响应事件的范围

子视图被添加到父视图以后，每次在屏幕上的点击事件都会触发一条响应链来逐层判断该由哪个视图来响应事件。当一个自视图添加到父视图以后其响应事件的范围就是父视图的bounds，如果子视图的bounds超出了父视图则超出的部分就会被响应链判断为不能响应事件而被抛弃。

假设有4个视图如下图所示

![](http://yizhibi.6chemical.com/1564129093.png)


在一个浅灰色的主视图上分别添加了灰色，深灰色和黑色三个方形的按钮，他们分别在浅灰色主视图的内部，边界上和外部，并给这三个按钮添加了点击事件的响应方法。

```Object-C
- (void)onClick:(UIButton *)button {
NSLog(@"%@按钮被点击",button.currentTitle);
}

```

分别点击三个按钮发现内部的按钮每次的按钮每次都能响应，而边界上的按钮则有时响应有时则不会，至于外部的按钮则完全不响应。这是因为虽然三个按钮都可见但是只要不在父视图的bounds内的部分便无法响应点击，边界上的按钮只有部分在其父视图之内所以不是每次点击都会响应，只有点击其在父视图之内的部分才能响应。UIView有个property叫做clipsToBounds，这个Boolean属性的值决定了父视图的子视图是否被限制在父视图的边界内，在默认情况下这个值是NO，所以即使在父视图中添加的子视图即使超出了父视图的边界也是可见的。现在把灰色的主视图的clipsToBounds设为YES，下图中可见的部分也就是父视图的bounds同时也就是父视图中子视图可以响应事件的范围。

![](http://yizhibi.6chemical.com/1564129148.png)

## - hitTest:withEvent: & - pointInside:withEvent:

为了使超出主视图的范围的子视图需要自己实现主视图的- hitTest:withEvent:方法。在官方文档其表述如下

> hitTest:withEvent: Returns the farthest descendant of the receiver in the view hierarchy (including itself) that contains a specified point.

```Object-C

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event

```

![参考](http://yizhibi.6chemical.com/1564129358.png)


由此可见，– hitTest:withEvent:是通过- pointInside:withEvent:来判断点击的点是否在视图中然后判断这个视图是否接受当前事件，关于- pointInside:withEvent:这个方法在文档中说明了正是通过bounds判断的。

> Returns a Boolean value indicating whether the receiver contains the specified point.

## 超出父视图的子视图响应事件

在父视图添加如下代码。其思路是遍历父视图的所有子视图，并判断触发事件的点是否在子视图的bounds内，如果在，就返回这个子视图。

```Object-C
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
UIView *view = [super hitTest:point withEvent:event];
if (view == nil) {
for (UIView *subView in self.subviews) {
CGPoint p = [subView convertPoint:point fromView:self];
if (CGRectContainsPoint(subView.bounds, p)) {
view = subView;
}
}
}
return view;
}
```
end;

有想法,可以留言,谢谢!
