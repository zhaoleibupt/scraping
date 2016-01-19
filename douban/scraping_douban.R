library(XML)
library(stringr)
library(dplyr)
library(ggplot2)
#获取URL
a<-0
for(i in 1:10)
{
a[i]<-paste0("http://movie.douban.com/top250?start=",(i-1)*25,"&filter=&type=%3Ctype%20%27type%27%3E")
}

#获取数据
getdouban = function(URL){
    Sys.sleep(runif(1,1,2))
    doc<-htmlParse(URL[1],encoding="UTF-8")
    rootNode<-xmlRoot(doc)
    #获得电影名称
    title<-xpathSApply(rootNode,"//span[@class='title']",xmlValue)
    title<-title[!str_detect(title,"/")]
    #获取观看人数和评分
    num<-xpathSApply(rootNode,"//div[@class='star']/span",xmlValue)
    score<-as.numeric(num[c(F,T,F,F)])
    people<-num[c(F,F,F,T)]
    people<-as.numeric(str_extract(people,"[0-9]+"))
    data<-data.frame(title=title,score=score,people=people)
    data
}

#数据整合
data<-NULL
for(i in 1:10)
{
   
    data<-rbind(data,getdouban(a[i]))
}

#数据处理及绘图
data$title<-as.character(data$title)
data1<-filter(data,score>=9 & people>=max(data$people)*0.75)

idx<-data$title %in% data1$title

data$name[idx]<-data$title[idx]
p<-ggplot(data,aes(x=log(people),y=score))+geom_point()+geom_vline(x=log(max(data$people)*0.75),linetype="dashed",color="red",size=1)+geom_hline(y=9,linetype="dashed",color="green",size=1)+theme_bw()
p+geom_text(aes(label=name),size=5,color="black",angle=45)
