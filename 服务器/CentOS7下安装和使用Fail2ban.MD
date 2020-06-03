本文主要介绍一下CentOS7下Fail2ban安装以及如何和iptables联动来阻止恶意扫描和密码猜测等恶意攻击行为。

从CentOS7开始，官方的标准防火墙设置软件从iptables变更为firewalld。 为了使Fail2ban与iptables联动，需禁用自带的firewalld服务，同时安装iptables服务。因此，在进行Fail2ban的安装与使用前需根据博客[CentOS7安装和配置iptables防火墙](https://bolerolily.github.io/2018/09/06/CentOS7安装和配置iptables防火墙/)进行环境配置。

## 关于Fail2ban

- Fail2ban可以监视你的系统日志，然后匹配日志的错误信息（正则式匹配）执行相应的屏蔽动作（一般情况下是调用防火墙屏蔽），如:当有人在试探你的HTTP、SSH、SMTP、FTP密码，只要达到你预设的次数，fail2ban就会调用防火墙屏蔽这个IP，而且可以发送e-mail通知系统管理员，是一款很实用、很强大的软件！
- Fail2ban由python语言开发，基于logwatch、gamin、iptables、tcp-wrapper、shorewall等。如果想要发送邮件通知道，那还需要安装postfix或sendmail。
- 在外网环境下，有很多的恶意扫描和密码猜测等恶意攻击行为，使用Fail2ban配合iptables，实现动态防火墙是一个很好的解决方案。

## 安装Fail2ban

首先需要到Fail2ban官网下载程序源码包，本文中通过稳定版Fail2ban-0.8.14做演示。



```cpp
wget https://codeload.github.com/fail2ban/fail2ban/tar.gz/0.8.14
```

成功下载之后，解压源码包并进行安装。



```css
tar -xf 0.8.14.tar.gz
cd fail2ban-0.8.14
python setup.py install
```

安装完成后要手动生成一下程序的启动脚本。



```csharp
cp files/redhat-initd /etc/init.d/fail2ban
chkconfig --add fail2ban
```

使用下列命令检查Fail2ban是否加入开机启动项。结果如下图所示。



```cpp
chkconfig --list fail2ban
```

![img](https:////upload-images.jianshu.io/upload_images/10345735-62c5d56793e351d5.JPG?imageMogr2/auto-orient/strip|imageView2/2/w/617/format/webp)

Fail2ban加入开机自启动项.JPG

安装完成后程序文件都是保存在/etc/fail2ban目录下，目录结构如下图所示。

![img](https:////upload-images.jianshu.io/upload_images/10345735-13c278803b1b59e2.JPG?imageMogr2/auto-orient/strip|imageView2/2/w/450/format/webp)

Fail2ban程序文件的目录结构.JPG

其中jail.conf为主配置文件，相关的正则匹配规则位于filter.d目录，其它目录/文件一般很少用到，如果需要详细了解可自行搜索。

## 配置Fail2ban

### 联动iptables

新建jail.local来覆盖Fail2ban在jail.conf的默认配置。



```undefined
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
vim /etc/fail2ban/jail.local
```

对jail.conf做以下两种修改。

1. 防止SSH密码爆破

   [ssh-iptables]模块的配置修改如下。其中，port应按照实际情况填写。

   

   ```csharp
    [ssh-iptables]
   
    enabled  = true
    filter   = sshd
    action   = iptables[name=SSH, port=22, protocol=tcp]
    logpath  = /var/log/secure
    maxretry = 3
    findtime  = 300
   ```

2. 阻止恶意扫描

   新增[nginx-dir-scan]模块，配置信息如下。此处，port和logpath应按照实际情况填写。

   

   ```ruby
    [nginx-dir-scan]
   
    enabled = true
    filter = nginx-dir-scan
    action   = iptables[name=nginx-dir-scan, port=443, protocol=tcp]
    logpath = /path/to/nginx/access.log
    maxretry = 1
    bantime = 172800
    findtime  = 300
   ```

   然后在filter.d目录下新建nginx-dir-scan.conf。

   

   ```swift
   cp /etc/fail2ban/filter.d/nginx-http-auth.conf /etc/fail2ban/filter.d/nginx-dir-scan.conf
   vim /etc/fail2ban/filter.d/nginx-dir-scan.conf
   ```

   对nginx-dir-scan.conf进行修改，具体配置信息如下。

   

   ```csharp
    [Definition]
   
    failregex = <HOST> -.*- .*Mozilla/4.0* .* .*$
    ignoreregex =
   ```

   此处的正则匹配规则是根据nginx的访问日志进行撰写，不同的恶意扫描有不同的日志特征。

   本文采用此规则是因为在特殊的应用场景下有绝大的把握可以肯定Mozilla/4.0是一些老旧的数据采集软件使用的UA，所以就针对其做了屏蔽。不可否认Mozilla/4.0 这样的客户端虽然是少数，但仍旧存在。因此，此规则并不适用于任何情况。

   使用如下命令，可以测试正则规则的有效性。

   

   ```cpp
   fail2ban-regex /path/to/nginx/access.log /etc/fail2ban/filter.d/nginx-dir-scan.conf
   ```

   Fail2ban已经内置很多匹配规则，位于filter.d目录下，包含了常见的SSH/FTP/Nginx/Apache等日志匹配，如果都还无法满足需求，也可以自行新建规则来匹配异常IP。总之，使用Fail2ban+iptables来阻止恶意IP是行之有效的办法，可极大提高服务器安全。

### 变更iptables封禁策略

Fail2ban的默认iptables封禁策略为 REJECT --reject-with icmp-port-unreachable，需要变更iptables封禁策略为DROP。

在/etc/fail2ban/action.d/目录下新建文件iptables-blocktype.local。



```bash
cd /etc/fail2ban/action.d/
cp iptables-blocktype.conf iptables-blocktype.local
vim iptables-blocktype.local
```

修改内容如下：



```csharp
[INCLUDES]

after = iptables-blocktype.local

[Init]

blocktype = DROP
```

最后，别忘记重启fail2ban使其生效。



```undefined
systemctl restart fail2ban
```

### Fail2ban常用命令

启动Fail2ban。



```undefined
systemctl start fail2ban
```

停止Fail2ban。



```undefined
systemctl stop fail2ban
```

开机启动Fail2ban。



```bash
systemctl enable fail2ban
```

查看被ban IP，其中ssh-iptables为名称，比如上面的[ssh-iptables]和[nginx-dir-scan]。



```undefined
fail2ban-client status ssh-iptables
```

添加白名单。



```bash
fail2ban-client set ssh-iptables addignoreip IP地址 
```

删除白名单。



```bash
fail2ban-client set ssh-iptables delignoreip IP地址
```

查看被禁止的IP地址。



```undefined
iptables -L -n
```

## 参考资料

1.[centos下fail2ban安装与配置详解 centos7 下安装使用fail2ban](https://www.bnxb.com/linuxserver/27516.html)
 2.[Linux系统通过fail2ban对暴力破解进行防护](https://yq.aliyun.com/articles/195078)
 3.[fail2ban变更iptables封禁策略为DROP](http://bookshadow.com/weblog/2017/05/05/fail2ban-iptables-drop/)
 4.[Fail2ban防止网站CC](https://www.jianshu.com/p/92473cf0acc9)
 5.[FAIL2BAN ON UBUNTU](https://www.liukang.com/tag/fail2ban/)
 6.[CentOS7 - 安装配置Fail2ban教程](https://www.douban.com/note/626688457/)



4人点赞



[Fail2ban]()





作者：testtest2333
链接：https://www.jianshu.com/p/4fdec5794d08
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。