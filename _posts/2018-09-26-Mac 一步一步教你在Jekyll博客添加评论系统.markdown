---
layout:     post
title:    "Mac 一步一步教你在Jekyll博客添加评论系统"
subtitle:   "你的博客有评论系统吗"
date: 2018-09-26 09:32:24.000000000 +09:00
author:     "一之笔"
header-img: "img/home-bg-o.jpg"
header-mask: 0.3
catalog:    true
tags:
- Linux
- 博客
---

文章原创如需转载，请注明出处"本文首发于[一之笔](https://yizibi.github.io/)";

> 最近收拾了一下自己的博客系统,添加了一套基于`Github`的评论[gitalk](https://gitalk.github.io/),效果还不错,之前用的[disqus](https://disqus.com)由于其他原因,打不开了;其他评论系统,如 

* 多说,多说已经关闭;
* [畅言](http://changyan.kuaizhan.com/static/help/),,畅言需要ICP备案;
* 网易云跟贴，曾被当作“多说”的替代品，可惜官方通报说也将在2017.08.01关闭了;
* [disqus](https://disqus.com)，国外比较火的评论系统，但在国内墙了，故也不考虑。
* [gitalk](https://gitalk.github.io/),支持 markdown,类似 issue,依托 github,不太可能被和谐;

考虑到自己的博客是基于github，并且国内几个比较主流的评论系统目前都无法在Github Pages上的个人博客使用， 无意间浏览别人的博客,发现了别人的博客评论,类似Github的issue,细查之下,我发现了gitalk，一款由国内大神imsun开发的基于github issues的评论系统;

## 最终成果

![Gitalk](http://o9zpq25pv.bkt.clouddn.com/lucyBlog/gitalkComment.png)

## 博主环境

* MacOS High Serria
* Jekyll驱动,原主题由[Hux](https://github.com/Huxpro/huxpro.github.io)提供,我在此基础上修改后的主题[在这儿](https://github.com/yizibi/yizibi.github.io),你可以点击[clone或者fork](https://github.com/yizibi/yizibi.github.io)

## 申请一个Github OAuth Application

> Github头像下拉菜单 > Settings > 左边Developer settings下的OAuth Application > Register a new application，填写相关信息：

`注意`:我下面的截图是因为我已经有注册好的GitHubAPP,因此可能跟你的不一样,大概流程是一样的;

![Git创建APP](http://o9zpq25pv.bkt.clouddn.com/lucyBlog/gitsetingnext.png)

感谢这个[作者文章](https://jacobpan3g.github.io/cn/2017/07/17/gitment-in-jekyll/),说明,博客网站的回调地址,一定要填写博客的域名,切记切记;
## 在jekyll博客添加gitalk

###  1.博客源码目录

> 一般博客源码下载下基本都是以下的目录:

```

├── 404.html
├── CNAME
├── Gruntfile.js
├── LICENSE
├── README.md
├── README.zh.md
├── _config.yml
├── _includes
│   ├── about
│   │   ├── en.md
│   │   └── zh.md
│   ├── comments.html
│   ├── dashang.html
│   ├── footer.html
│   ├── head.html
│   ├── mathjax_support.html
│   ├── nav.html
│   └── posts
│       └── 2017-07-12-upgrading-eleme-to-pwa
│           ├── en.md
│           └── zh.md
├── _layouts
│   ├── default.html
│   ├── keynote.html
│   ├── page.html
│   └── post.html
├── _posts
│   ├── 2015-12-12-iOS中�\233��\211\207�\232\204�\234\206�\222设置\ .markdown
│   ├── 2016-01-16-AFNetworking�\212��\224\231415.markdown

```

### 2.增加关键代码

> 你需要在 `_layouts` 下的`_post.html`,打开这个html,最好用 sublime Text或者X-code打开,在代码的一开始,加入如下代码:

```
<!--//添加评论系统-->
<link rel="stylesheet" href="../../../../css/gitalk.css">
<script src="../../../../js/gitalk.min.js"></script>

```

这个脚本有 两个 文件 `gitalk.css` 与 `gitalk.min.js`,

这两个文件在哪里呢;

你需要把我的博客源码下载下载,找到对应的步骤,然后,把这两个文件分别放到对应的文件中,保存即可;

当然了,你也可以用这个[default.css](https://imsun.github.io/gitment/style/default.css)

### 3.添加评论框

还是在那个 `_post.html`文件中,找到 关键字 评论框 在下面添加 gitalk 代码,如下

```

{% if site.disqus_username %}
<!-- disqus 评论框 start -->
<div class="comment">
<div id="disqus_thread" class="disqus-thread"></div>
</div>
<!-- disqus 评论框 end -->
{% endif %}

{% if site.netease_comment %}
<!-- 网易云跟帖 评论框 start -->
<div id="cloud-tie-wrapper" class="cloud-tie-wrapper"></div>
<!-- 网易云跟帖 评论框 end -->
{% endif %}

<!--   gitalk       -->
{% if site.gitalk %}
<div class="comment">
{% include comments.html %}
</div>
{% endif %}
```

### 4.添加鉴权代码

这个在 `_config.yml`中,打开这个文件,在对应的评论模块添加如下代码:

```
# Disqus settings

# disqus_username: Lucy

# Netease settings
netease_comment: false
// 添加这个就行,上面的只是为了你能方便找到地方
gitalk:
enable: true
owner: ***zibi
repo: *****.github.io
clientID: ****c08c2ec52afbcb30
clientSecret: *******79e7b42cf782a1d2d1b5a410d27c5ab57
admin: **zibi

```
这些参数怎么来的,是第一步,通过github,申请的,同时,也是我们评论的用户鉴权;

以上就是 在Jekyll中添加Gitalk评论系统,有什么不懂的,可以留言或者issue我;

