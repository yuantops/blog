+++
Categories = ["Tech"]
date = "2015-09-08T00:00:00Z"
Description = "LaTeX是学术界的通行排版工具，期刊会议投稿必备。本文简要记录在Ubuntu上的安装步骤，以及处理pdf字体找不到情况。"
title =  "LaTeX安装以及生成pdf时字体找不到的处理办法"
+++

## 安装软件包  
`$ sudo apt-get install texlive texlive-science`

## 编译命令
- tex编译: `$ latex hello.tex`    
- 输出为pdf: `$ dvipdf hello.dvi`     
- 输出为ps: `$ dvips hello.dvi`    

## 如果生成pdf时报"Font Helvetica is not in the mapping file" 类似错误  
出现这种情况，原因可能有几种，最可能的是系统没有安装这个字体。具体解释见[这篇文章](http://www.wkiri.com/today/?p=60)。   

处理办法：安装ghostscript命令，用它自带的命令，先将pdf转成ps，再以强制嵌入字体的方式将ps回转为pdf。详细的步骤见[这篇文章](http://www.grassbook.org/wp-content/uploads/neteler/highres_pdf.html)。   

具体命令:    
1. covert to postscript:     
`$ pdftops origin.pdf origin.ps`    
2. reconvert to pdf, but enforce font embedding:        
`$ ps2pdf14 -dPDFSETTINGS=/prepress -dEmbedAllFonts=true origin.ps new.pdf`     
3. verify format of new file:       
`$ pdffonts new.pdf`    

