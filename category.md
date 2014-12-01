---
layout: page
title: Categories
---
{% for cat in site.categories %} 
	{% if cat[0] != 'blog' %} 
##   {{ cat[0] }}({{ cat[1].size }})
     {% for post in cat[1] %} 
####    {{ post.date | date_to_string }} &raquo; [{{ post.title }}]({{ post.url }} )
	{% endfor %}
   {% endif %} 
{% endfor %} 
