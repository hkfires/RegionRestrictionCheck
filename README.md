<!-- <p align="center">
<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Flmc999%2FRegionRestrictionCheck&count_bg=%230AC995&title_bg=%23004BF9&icon=&icon_color=%23E7E7E7&title=visitors&edge_flat=false"/></a>
<a href="/LICENSE"><img src="https://img.shields.io/badge/license-GPL-blue.svg" alt="license" /></a>  
</p>
 -->
## Sponsor

<!-- <div align=center>
   <img src="https://user-images.githubusercontent.com/29977021/228770306-6c5d0b8a-c381-4be3-b500-e43fc47298b3.png" width="400px">
</div>
 -->
## For English user please see
### [Introduction](https://github.com/1-stream/RegionRestrictionCheck/blob/main/README_EN.md)

## 脚本介绍
本脚本基于[CoiaPrant/MediaUnlock_Test](https://github.com/CoiaPrant/MediaUnlock_Test)代码进行修改

**支持OS/Platform：CentOS 6+, Ubuntu 14.04+, Debian 8+, MacOS, Android with Termux**

iOS运行方法请参考[此处](https://github.com/lmc999/RegionRestrictionCheck/wiki/iOS%E8%BF%90%E8%A1%8C%E8%84%9A%E6%9C%AC%E6%96%B9%E6%B3%95)

## 使用方法

**使用脚本前请确认curl已安装**

````bash
bash <(curl -L -s https://github.com/1-stream/RegionRestrictionCheck/raw/main/check.sh)
````

##### 只检测IPv4结果：
````bash
bash <(curl -L -s https://github.com/1-stream/RegionRestrictionCheck/raw/main/check.sh) -M 4
````

##### 只检测IPv6结果：
````bash
bash <(curl -L -s https://github.com/1-stream/RegionRestrictionCheck/raw/main/check.sh) -M 6
````

##### 指定检测的网卡名称：
````bash
bash <(curl -L -s https://github.com/1-stream/RegionRestrictionCheck/raw/main/check.sh) -I eth0
````

##### 选择脚本语言为英文：
````bash
bash <(curl -L -s https://github.com/1-stream/RegionRestrictionCheck/raw/main/check.sh) -E
````
<!-- 
**或者直接运行以下Docker命令** (兼容ARM架构)
````docker
docker run --rm -ti --net=host lmc999/regioncheck && docker rmi lmc999/regioncheck
```` -->

<!-- ## 赞助
如果觉得脚本对你有帮助，可以考虑请作者喝一箱健力宝

![image](https://i.imgur.com/HHbZgUsl.jpg)

![image](https://i.imgur.com/MWXifObl.jpg) -->

<!-- ## 交流
脚本使用过程中出现bug欢迎提交issue

你亦可直接添加[TG群组](https://t.me/gameaccelerate)分享你的建议 -->

## 特别鸣谢
[柠檬大佬](https://t.me/ilemonrain),目前市面的流媒体解锁检测脚本都是从[Lemonbench](https://github.com/LemonBench/LemonBench)演化而来

[onoc1yn](https://github.com/onoc1yn) 提供多架构docker解决方案及Hulu Cookies加密方案
