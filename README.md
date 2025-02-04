# RegionRestrictionCheck
本脚本为 [lmc999/RegionRestrictionCheck](https://github.com/lmc999/RegionRestrictionCheck) 的fork版本，由于基本已经完全重构，目前已取消Fork关系。

## 支持OS

仅在Debian最新稳定版测试通过，其他OS未经测试，如运行出现问题请尝试解决依赖。

## 使用方法

**使用脚本前请确认curl已安装**

````bash
bash <(curl -L -s https://github.com/1-stream/RegionRestrictionCheck/raw/main/check.sh)
````

## 参数

| Flag | Description |
| ---- | ----------- |
| -I \<Interface\>\/\<IP\> | 指定网卡/出口ip |
| -M \<4\/6\> | 指定仅测试IPv4/IPv6 |
| -P \<Proxy\> | 指定测试是使用代理,支持协议请参考curl |
| -F \<Function\> | 仅运行指定函数 |
| -S | 特殊用途 |
| -R \<IP\> | 指定将所有域名解析为指定ip |
| -D \<DNS\> | 指定使用特定DNS **需要使用[启用了c-ares库的curl](https://gist.github.com/nevermosby/88efb9ecc4e61b8f401d449649796dfc)(配合-C参数)**|
| -C \<Path\> | 指定使用特定 Curl 程序
