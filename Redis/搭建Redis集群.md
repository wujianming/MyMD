## 关于Redis

Redis通常被称为数据结构服务器，可以用作数据库，缓存或消息代理。它存储键值数据。Redis支持多种类型的数据结构，例如字符串，列表，集合，排序集合，哈希，HyperLogLogs，位图。

Redis中包含的数据结构具有一些特殊的属性：

- Redis关心将数据存储在磁盘上，即使它们正在内存中进行处理。这意味着Redis可以通过内存快速处理，并且在将数据存储在磁盘上时也更安全。
- 与具有相同数据结构模型的其他语言相比，Redis使用更少的内存
- Redis提供了全面的功能，例如复制，集群，高可用性
- ![image-20200418095941196](https://raw.githubusercontent.com/wujianming/MyMD_Pic/matser/master/img/image-20200418095941196.png)

## 关于Redis集群

Redis集群提供了一种安装Redis的方法，该方法可以自动跨多个Redis节点分片数据。

Redis集群提供了多个级别的数据分区，允许它们在某些Redis节点不可用或不可用时继续操作数据（当然，因为某些Redis节点发生故障或无法通信。从应用程序到Redis的数据将很慢）。但是，当存在大量错误（例如，许多故障主节点）时，群集将停止工作。

## 从源安装Redis集群

要求：Redis-3.0 +

03个节点：

- node01：192.168.10.111
- node02：192.168.10.112
- 节点03：192.168.10.113

**第一步：下载脚本**

- 将脚本下载到03个节点

在以下位置下载源：[https](https://github.com/antirez/redis) : [//github.com/antirez/redis](https://github.com/antirez/redis)。

当前版本为5。在这里，我们使用4.0的较低版本。

```
cd /opt/
wget https://github.com/antirez/redis/archive/4.0.11.tar.gz
tar zxvf 4.0.11.tar.gz
mv redis-4.0.11 redis
```

**步骤2：建立Redis**

我们在创建实例和集群之前先构建redis

```
cd /opt/redis
make
make test
```

**第三步：在node01上创建一个实例**

我们使用脚本`create-cluster`来创建实例和集群，而不是手动操作它们。

- 在node01上执行redis配置文件

```
cd /opt/redis/utils/create-cluster
```

我们使用以下内容修改**create-cluster**文件以适合需要（从create-cluster中读取）。有一些注意事项如下：

- NODES = 3个Số节点可以创建集群
- REPLICAS = 1表示它将为每个创建的主节点创建1个从节点。
- BIND_HOST = 192.168.1.X分配一个IP地址以允许与集群中的节点通信（默认BIND_HOST = 127.0.0.1，因此只能由其自身访问节点）

`--protected-mode no --bind $BIND_HOST --maxmemory 5120mb`创建实例时还要添加可选值。具有以下含义：

- protected-mode no->设置不需要身份验证的模式以进行测试
- bind $ BIND_HOST->将IP地址值分配给节点
- maxmemory 5120mb->将Redis的内存存储值设置为5120mb

执行启动创建集群以创建实例

```
./create-cluster start
```

检查实例正在运行

```
netstat -ntlp
```

- 查看Redis的版本

```
/opt/redis/src/redis-cli -h 192.168.1.223 -p 30001 -v
```

将**create-cluster**文件的内容复制到其他两个节点

```
scp create-cluster root@192.168.10.112:/opt/redis/utils/create-cluster
scp create-cluster root@192.168.10.113:/opt/redis/utils/create-cluster
```

**步骤4：在其余2个节点上运行redis**

编辑创建集群配置文件的内容

替换与正在配置的Redis服务器的IP对应的值**BIND_HOST = 192.168.1.112**和**BIND_HOST = 192.168.1.113**

开始Redis

```
./create-cluster start
```

**步骤5：创建集群和副本**

创建并运行实例后，我们将创建一个具有副本的集群以供redis使用。使用redis 5，我们可以使用命令行轻松创建集群`redis-cli`。对于Redis版本3或4，我们使用较旧的命令行工具，而不是`redis-trib.rb`。要运行`redis-trib.rb`，我们需要安装**redis gem**

- 安装RVM

rvm（Ruby版本管理器）使用ruby软件包管理。默认情况下，Centos 7存储库仅适用于ruby-2.0。虽然安装Redis更高版本的请求要求ruby高于2.3+。

```
curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
curl -L get.rvm.io | bash -s stable
```

- 加载RVM环境

```
source /etc/profile.d/rvm.sh
rvm reload
```

- 安装红宝石

根据需要安装适当的红宝石版本。在这里，我安装了ruby-2.6。

```
rvm install 2.6
```

- 安装gem和redis

```
yum install gem -y
gem install redis
```

- 对具有6个节点（03个主节点和03个从属节点）的副本执行群集

```
./create-cluster create
>>> Creating cluster
>>> Performing hash slots allocation on 6 nodes...
Using 3 masters:
192.168.1.223:30001
192.168.1.223:30002
192.168.1.223:30003
Adding replica 192.168.1.223:30005 to 192.168.1.223:30001
Adding replica 192.168.1.223:30006 to 192.168.1.223:30002
Adding replica 192.168.1.223:30004 to 192.168.1.223:30003
>>> Trying to optimize slaves allocation for anti-affinity
[WARNING] Some slaves are in the same host as their master
M: 81d8753dcb0e6c6022312511969373aeb580e119 192.168.1.223:30001
   slots:0-5460 (5461 slots) master
M: 1285aab406fb15c4f08c1950fb909fef551e9cc6 192.168.1.223:30002
   slots:5461-10922 (5462 slots) master
M: a613930c2c310008dfa6ca58e4ed10e9e015badc 192.168.1.223:30003
   slots:10923-16383 (5461 slots) master
S: 70ef3ed73afada2484d678cb186e89aec95e6602 192.168.1.223:30004
   replicates 1285aab406fb15c4f08c1950fb909fef551e9cc6
S: e648bad5eaed144c4339120f779d771ce386c7a7 192.168.1.223:30005
   replicates a613930c2c310008dfa6ca58e4ed10e9e015badc
S: 44fe5f17f9ae41649b3a3fbd88cfcb5c36230fd5 192.168.1.223:30006
   replicates 81d8753dcb0e6c6022312511969373aeb580e119
Can I set the above configuration? (type 'yes' to accept): yes
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join..
>>> Performing Cluster Check (using node 192.168.1.223:30001)
M: 81d8753dcb0e6c6022312511969373aeb580e119 192.168.1.223:30001
   slots:0-5460 (5461 slots) master
   1 additional replica(s)
M: 1285aab406fb15c4f08c1950fb909fef551e9cc6 192.168.1.223:30002
   slots:5461-10922 (5462 slots) master
   1 additional replica(s)
M: a613930c2c310008dfa6ca58e4ed10e9e015badc 192.168.1.223:30003
   slots:10923-16383 (5461 slots) master
   1 additional replica(s)
S: e648bad5eaed144c4339120f779d771ce386c7a7 192.168.1.223:30005
   slots: (0 slots) slave
   replicates a613930c2c310008dfa6ca58e4ed10e9e015badc
S: 44fe5f17f9ae41649b3a3fbd88cfcb5c36230fd5 192.168.1.223:30006
   slots: (0 slots) slave
   replicates 81d8753dcb0e6c6022312511969373aeb580e119
S: 70ef3ed73afada2484d678cb186e89aec95e6602 192.168.1.223:30004
   slots: (0 slots) slave
   replicates 1285aab406fb15c4f08c1950fb909fef551e9cc6
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

**步骤6：执行集群信息检查**

- 使用redis-cli工具访问redis

```
/opt/redis/src/redis-cli -h 192.168.1.223 -p 30001
```

- 查看集群概述

```
192.168.1.223:30001> INFO
#Server
redis_version:4.0.11
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:3020d12947b9f562
redis_mode:cluster
os:Linux 3.10.0-957.5.1.el7.x86_64 x86_64
arch_bits:64
multiplexing_api:epoll
atomicvar_api:atomic-builtin
gcc_version:4.8.5
process_id:9043
run_id:3a28ff03429ad6123e3fdcd89638ada4b5ff53c6
tcp_port:30001
uptime_in_seconds:3504
uptime_in_days:0
hz:10
lru_clock:413144
executable:/root/redis/src/redis-server
config_file:

#Clients
connected_clients:1
client_longest_output_list:0
client_biggest_input_buf:0
blocked_clients:0

#Memory
used_memory:2642048
used_memory_human:2.52M
used_memory_rss:10076160
used_memory_rss_human:9.61M
used_memory_peak:2681768
used_memory_peak_human:2.56M
used_memory_peak_perc:98.52%
used_memory_overhead:2560504
used_memory_startup:1445368
used_memory_dataset:81544
used_memory_dataset_perc:6.81%
total_system_memory:3973615616
total_system_memory_human:3.70G
used_memory_lua:37888
used_memory_lua_human:37.00K
maxmemory:5368709120
maxmemory_human:5.00G
maxmemory_policy:noeviction
mem_fragmentation_ratio:3.81
mem_allocator:jemalloc-4.0.3
active_defrag_running:0
lazyfree_pending_objects:0

#Persistence
loading:0
rdb_changes_since_last_save:2
rdb_bgsave_in_progress:0
rdb_last_save_time:1560690832
rdb_last_bgsave_status:ok
rdb_last_bgsave_time_sec:1
rdb_current_bgsave_time_sec:-1
rdb_last_cow_size:6467584
aof_enabled:1
aof_rewrite_in_progress:0
aof_rewrite_scheduled:0
aof_last_rewrite_time_sec:-1
aof_current_rewrite_time_sec:-1
aof_last_bgrewrite_status:ok
aof_last_write_status:ok
aof_last_cow_size:0
aof_current_size:81
aof_base_size:0
aof_pending_rewrite:0
aof_buffer_length:0
aof_rewrite_buffer_length:0
aof_pending_bio_fsync:0
aof_delayed_fsync:0

#Stats
total_connections_received:11
total_commands_processed:3301
instantaneous_ops_per_sec:1
total_net_input_bytes:174311
total_net_output_bytes:112410
instantaneous_input_kbps:0.04
instantaneous_output_kbps:0.00
rejected_connections:0
sync_full:1
sync_partial_ok:0
sync_partial_err:1
expired_keys:0
expired_stale_perc:0.00
expired_time_cap_reached_count:0
evicted_keys:0
keyspace_hits:0
keyspace_misses:0
pubsub_channels:0
pubsub_patterns:0
latest_fork_usec:649
migrate_cached_sockets:0
slave_expires_tracked_keys:0
active_defrag_hits:0
active_defrag_misses:0
active_defrag_key_hits:0
active_defrag_key_misses:0
#Replication
role:master
connected_slaves:1
slave0:ip=192.168.1.223,port=30006,state=online,offset=1036,lag=1
master_replid:80dcd3540523da23fb78280576aaa609a45eaf2b
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:1036
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:1036

#CPU
used_cpu_sys:1.26
used_cpu_user:0.64
used_cpu_sys_children:0.00
used_cpu_user_children:0.00

#Cluster
cluster_enabled:1

#Keyspace
```

然后，我们会看到有关redis的信息，例如：版本，连接，cpu，内存等。

- 检查复制信息

```
192.168.1.223:30001> info replication
#Replication
role:master
connected_slaves:1
slave0:ip=192.168.1.223,port=30006,state=online,offset=4463,lag=0
master_replid:80dcd3540523da23fb78280576aaa609a45eaf2b
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:4463
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:4463
```

在这里，我们看到当前的绑定端口192.168.1.223:30001担任主角色，并且有01 slave0连接到192.168.1.223:30006

```
172.25.80.78:30001> INFO replication
#Replication
role:master
connected_slaves:1
slave0:ip=172.25.80.77,port=30002,state=online,offset=142295630168,lag=1
master_replid:93ac7e41dd61cbb298bf864fb270b49e16400f70
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:142295630182
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:142294581607
repl_backlog_histlen:1048576
172.25.80.78:30001> 
```

**检查基准重做**

```
redis-benchmark -h localhost -p 30001 -q -n 1000 -c 10 -P 5
```

含义：

在安静模式下运行redis-benchmark，发出1000个请求，使用10个并行连接运行，并管道5条请求。

结果：

```
PING_INLINE: 142857.14 requests per second
PING_BULK: 166666.67 requests per second
SET: 124999.99 requests per second
GET: 124999.99 requests per second
INCR: 124999.99 requests per second
LPUSH: 111111.12 requests per second
RPUSH: 124999.99 requests per second
LPOP: 124999.99 requests per second
RPOP: 124999.99 requests per second
SADD: 142857.14 requests per second
HSET: 142857.14 requests per second
SPOP: 142857.14 requests per second
LPUSH (needed to benchmark LRANGE): 142857.14 requests per second
LRANGE_100 (first 100 elements): 43478.26 requests per second
LRANGE_300 (first 300 elements): 15873.02 requests per second
LRANGE_500 (first 450 elements): 8695.65 requests per second
LRANGE_600 (first 600 elements): 7042.25 requests per second
MSET (10 keys): 111111.12 requests per second
```