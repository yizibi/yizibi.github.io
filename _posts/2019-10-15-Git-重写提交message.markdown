---
layout:     post
title:    "Git-修改提交message"
subtitle:   "git 修改重写commit message"
date: 2019-10-15 18:32:24.000000000 +09:00
author:     "陕西毅杰"
header-img: "img/home-bg-o.jpg"
tags:
- git
- 工具
---


### 情景一

我在开发的过程中,git 提交的 message 不小心把项目名称写错了,需要修改,这时候,本地已经add,并且已经push到服务端了,怎么办?

### 情景二

上一篇我写了[规范杂谈](https://yizibi.github.io/2019/09/04/%E8%A7%84%E8%8C%83%E6%9D%82%E8%B0%88/),里面有git代码提交的简单规范,这时候,我想修改之前提交的message,以便按照提交规范;

### 修改最近的一笔提交

修改最近的提交是最常见的修改历史说明的行为,我隔一段时间就会来一次;

这个很简单,就一个命令:

> ~ git commit --amend

git commit 后增加一个参数,amend,输入命令后,终端会进入 VIM 文本编辑器,按 i 字母,会进入编辑模式,修改你需要改的message,然后,保存,退出编辑,重新push即可

### 修改多个提交说明

修改多个提交说明,这个相对比较复杂,我也是按照某个老师写的,尝试了2次才修改成功;

主要是通过:以下这个命令,其中 HEAD~2 就是最近2笔提交;

> ~ git rebase -i HEAD~2 

运行命令后,终端进入编辑模式,大概就是下面这个样子:

![](http://yizhibi.6chemical.com/1571139797.png)

需要注意的是,这个编辑器给我们呈现的提交顺序跟[ git reflog ]的顺序是相反的; 这个跟我们修改的message没啥关系,但是也需要注意一下;

下来就是重点了,敲黑板

![](http://yizhibi.6chemical.com/1571140070.png)

我们只要将想修改的每一次提交前面的 **pick** 改为 **edit** 。例如，只想修改第一次提交说明的话，就像下面这样修改,看下图：

![](http://yizhibi.6chemical.com/1571140229.png)

退出编辑,保存退出,这时候,会提示你,接下来怎么做,大概是这个样子

![](http://yizhibi.6chemical.com/1571140445.png)

其实分别就是两个命令

* git commit --amend

* git rebase --continue

其中,第一个命令就是修改上面你把 pick 修改 为 edit 的那一笔提交的message,然后保存退出,执行第二个命令

第二个命令,就是自动应用其他的提交,执行后,会有一段提示:

> Successfully rebased and updated refs/heads/ios_fire_control2.0.

然后,git push 就可以了,大功告成!

以上,如有问题,欢迎留言,谢谢!
