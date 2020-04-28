# CentOS7 Zookeeper 安装

 集群部署

192.16.2.5 zk01
192.16.2.4 zk02
192.16.2.247 zk03

安装zookeeper，必须安装jdk。

**1.下载**

```
$ cd /usr/local
$ wget https://downloads.apache.org/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz
```

 

**2.解压并重命名**

```
$ tar -zxvf zookeeper-3.4.14.tar.gz
$ mv /usr/local/zookeeper-3.4.14 /usr/local/zookeeper
```

**3.文件配置**

（1）在每个节点都创建data目录和logs目录

```
$ mkdir /home/data/zookeeper/
$ mkdir /home/data/zookeeper/data
$ mkdir /home/data/zookeeper/logs
```

 （2）在每个节点的 data目录下创建 myid文件，并输入内容 1/2/3 ；节点zk01的内容为1，节点zk02的内容为2，节点zk03的内容为3

 myid（节点zk01）

```
#这里只有一个数字1
1 
```

myid（节点zk02）

```
#这里只有一个数字2
2
```

myid（节点zk03）

```
#这里只有一个数字3
3
```

 （3）复制zoo_sample.cfg，并编辑zoo.cfg文件

```
$ cp /usr/local/zookeeper/conf/zoo_sample.cfg /usr/local/zookeeper/conf/zoo.cfg
$ vim /usr/local/zookeeper/conf/zoo.cfg
```

 zoo.cfg（节点zk01）

```
dataDir=/home/data/zookeeper/data
dataLogDir=/home/data/zookeeper/logs

clientPort=2181

server.1=172.16.2.5:2881:3881
server.2=172.16.2.4:2881:3881
server.3=172.16.2.247:2881:3881
```

zoo.cfg（节点zk02）

```
dataDir=/home/data/zookeeper/data
dataLogDir=/home/data/zookeeper/logs

clientPort=2182

server.1=172.16.2.5:2881:3881
server.2=172.16.2.4:2881:3881
server.3=172.16.2.247:2881:3881
```

zoo.cfg（节点zk03）

```
dataDir=/home/data/zookeeper/data
dataLogDir=/home/data/zookeeper/logs

clientPort=2183

server.1=172.16.2.5:2881:3881
server.2=172.16.2.4:2881:3881
server.3=172.16.2.247:2881:3881
```

说明：

- 上面的myid 1 2 3 分别对应 配置文件server.1 server.2 server.3，并且不能有空格或空行；
- serverid的范围为1~255，且不可以重复；也就是说zookeeper集群中最多可安装255个节点；
- 2881为“选主端口”，3881为“通信端口”；
- zookeeper 集群中节点并不是越多越好，越多性能越低。生产环境中最佳集群节点个数为 7~15 个

 **4.关闭防火墙**

```
$ systemctl stop firewalld
```

 **5.启动zookeeper**

 在每一个节点上执行如下命令：

```
$ /usr/local/zookeeper/bin/zkServer.sh start
```

 **6.查看zookeeper状态**

```
$ /usr/local/zookeeper/bin/zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper/bin/../conf/zoo.cfg
Mode: follower
```

leader：主

follower：从 



 常见错误：

Using config: /usr/local/zookeeper/bin/../conf/zoo.cfg

Error contacting service. It is probably not running.　　

可能有以下几个原因：

第一，zoo.cfg文件配置出错：dataLogDir指定的目录未被创建；
第二，myid文件中的整数格式不对，或者与zoo.cfg中的server整数不对应
第三，防火墙未关闭；
第四，2181端口被占用；
第五，zoo.cfg文件中主机名出错；
第六，hosts文件中，本机的主机名有两个对应，只需保留主机名和ip地址的映射