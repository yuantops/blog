---
layout: post    
category: "Tech"   
title: "在GitHub pages中添加标签Tags(非插件方式)"      
tags: [gh-pages, GitHub]
description: "使用GitHub pages搭建的博客默认没有添加标签，不方便组织博客内的文章。本文介绍如何通过改动模板文件，在博客内加入标签功能，使博客按照自己的心意组织起来。"
---

###参考内容
本文参考了以下内容：  

* [Alphabetizing Jekyll Page Tags In Pure Liquid (Without Plugins)](http://blog.lanyonm.org/articles/2013/11/21/alphabetize-jekyll-page-tags-pure-liquid.html)   
* [Tips For Sorting Tags In GitHub Page With Jekyll](http://boylee.me/development/2014/11/20/Tips-For-Sorting-Tags-In-GitHub-Page-With-Jekyll/)     
* [HOW TO USE TAGS AND CATEGORIES ON GITHUB PAGES WITHOUT PLUGINS](http://www.minddust.com/post/tags-and-categories-on-github-pages/)    

###思路
Jekyll引擎按照post/page文件-layout模板-HTML文件的逻辑处理、生成数据，因此添加Tags功能时也应遵循对应的顺序。  
1. 在\_posts目录下新建post文件时，在yaml头中加入tags变量。如果有多个tag，那么用中括号括起来、逗号分开。  
2. 在\_layouts目录下，post文件引用的模板文件中，加入解析单个post文件的tags的逻辑，并显示。  
3. 在博客文件夹的根目录下新建一个tags.html文件，列出博客所有文章的tags，通过Html定位符确定每个tag的位置。将这个页面的链接摆放在首页或者其它合适的地方。  

###步骤
**Step 1**
在\_layouts目录下的post.html文件中，在你想Tags出现的地方加入下面的代码：  
	{% highlight html%}
	<p class="entry-tags"> {% for tag in page.tags %}<a href="{{ site.url }}/tags.html#{{ tag | cgi_    e    scape }}" title="Pages tagged {{ tag }}" rel="tag" class="post-tag">{{ tag }}</a>{% unless forloop.last %}  {%     endunless %}{% endfor %}</p>
	{% endhighlight %}
**Step 2**
在博客的根目录下新建tags.html文件，内容如下:  
{%highlight html%} ---
layout: page
title: Tags
description: "An archive of posts sorted by tag."
--- {%endhighlight%}
{%highlight html%} {%raw%} {% capture site_tags %}{% for tag in site.tags %}{{ tag | first }}{% unless forloop.last %},{% endunless %}{% endfor %}{% endcapture %}
<!-- site_tags: {{ site_tags }} -->
{% assign tag_words = site_tags | split:',' | sort %}
<!-- tag_words: {{ tag_words }} --> {%endraw%}
<div id="tags">
  <ul class="tag-box inline">
{%raw%} {% for item in (0..site.tags.size) %}{% unless forloop.last %}
    {% capture this_word %}{{ tag_words[item] | strip_newlines }}{% endcapture %}
    <li><a href="#{{ this_word | cgi_escape }}" class="tag-in-page">{{ this_word }} <span>{{ site.tags[this_word].size }}</span></a></li>
  {% endunless %}{% endfor %} {%endraw%}
  </ul>
{%raw%} {% for item in (0..site.tags.size) %}{% unless forloop.last %}
    {% capture this_word %}{{ tag_words[item] | strip_newlines }}{% endcapture %}
  <h2 id="{{ this_word | cgi_escape }}">{{ this_word }}</h2> {%endraw%}
  <ul class="posts">
{%raw%} {% for post in site.tags[this_word] %}{% if post.title != null %}
    <li itemscope><span class="entry-date"><time datetime="{{ post.date | date_to_xmlschema }}" itemprop="datePublished">{{ post.date | date: "%B %d, %Y" }}</time></span> &raquo; <a href="{{ post.url }}">{{ post.title }}</a></li>
    {% endif %}{% endfor %} {%endraw%}
  </ul>
{%raw%} {% endunless %}{% endfor %} {%endraw%}
</div>
{%endhighlight%}
   
**Step 3**
将tags.html的链接放到合适的地方：Header，Siderbar，Footer或者其他地方。  
**Step 4**
以后在写博客时，在post的yaml头部加入tags变量。  

###显示效果美化
如果觉得Tags在post页面和tags.html的显示效果不够酷炫，可以自己在对应的css文件中加入/修改规则。  

###例子
- 基于lanyon模板的博客：[lanyonm.github.io GitHub Project](https://github.com/LanyonM/lanyonm.github.io)   
- 想定制Tags显示的排序规则，以及定制CSS效果：[Boyi Li webpage](http://boylee.me/development/2014/11/20/Tips-For-Sorting-Tags-In-GitHub-Page-With-Jekyll/)  
- 本博客： [Yuantops' Blog GitHub Project](https://github.com/yuantops/blog)  

