---
layout: post    
category: "Tech"   
title: "Git重新应用gitignore文件规则"      
description: "有时候我们更新了gitignore里的排除规则，但Git好像还在继续跟踪那些理应被排除的文件。这时候我们对整个Repo删除缓存、重新应用gitignore规则。"
---

这个问题参见[StackOverflow](https://stackoverflow.com/questions/11451535/gitignore-not-working)，记录在下面：    

1. 保险起见，先对当前Repo提交一个commit，以防丢失数据；    
2. 然后，    
          git rm -r --cached .      
		  git add .        
		  git commit -m "fixed untracked files"      


