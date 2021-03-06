# NoSQL：如何使用NoSQL架构构建实时广告系统

> 以下文章来源于京东零售技术 ，作者郑思城

> 链接：[mp.weixin.qq.com/s/OFkRnbWEa…](https://mp.weixin.qq.com/s/OFkRnbWEa7vxm3V3OmTk-g?utm_source=tuicool&utm_medium=referral)

**JDNoSQL平台是什么**

JDNoSQL平台是一个分布式面向列的KeyValue毫秒级存储服务，存储结构化数据和非机构化数据，支持随机读写与更新，灵活的动态列机制，架构上支持水平扩容，提供高并发、低延迟、高可用、强一致数据库服务，可满足各种业务场景。完善的平台支持，支持业务自助化建表，查看监控，在线DDL等。

**1.1  JDNoSQL所处生态的位置**



![img](https://user-gold-cdn.xitu.io/2020/1/14/16fa375bbd9ec36b?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



从上图可以看出，JDNoSQL是一种构建在HDFS之上的分布式、面向列的存储系统。在需要实时读写、随机访问超大规模数据集时，可以使用JDNoSQL。 目前市面上的一些关系类型数据库，在构建时并没有考虑超大规模和分布式的特点。许多商家通过复制和分区的方法来扩充数据库使其突破单个节点的界限，但这些功能通常都是事后增加的，安装和维护都很复杂。同时，也会影响RDBMS的特定功能，例如联接、复杂的查询、触发器、视图和外键约束这些操作在大型的RDBMS上的代价相当高，甚至根本无法实现。JDNoSQL从另一个角度处理伸缩性问题。它通过线性方式从下到上增加节点来进行扩展。JDNoSQL不是关系型数据库，也不支持SQL目前可以通过JDPhoenix支持SQL，但是它有自己的特长，这是RDBMS不能处理的，JDNoSQL巧妙地将大而稀疏的表放在商用的服务器集群上。JDNoSQL有如下特点：

- 大：一个表可以有上亿行，上百万列。
- 面向列：面向列表（簇）的存储和权限控制，列（簇）独立检索。
- 稀疏：对于为空（NULL）的列，并不占用存储空间，因此，表可以设计的非常稀疏。
- 无模式：每一行都有一个可以排序的主键和任意多的列，列可以根据需要动态增加，同一张表中不同的行可以有截然不同的列。
- 数据多版本：每个单元中的数据可以有多个版本，默认情况下，版本号自动分配，版本号就是单元格插入时的时间戳。
- 数据类型单一：JDNoSQL中的数据都是字符串，没有类型。

**应用场景**

NoSQL在京东的使用主要涉及一下场景：

- 时序型业务（监控，IOT）
- 消息订单（订单/保单，聊天记录）
- CUBE分析（实时宽表，报表，搜索推荐）
- 监控（UMP/MDC/CAP/JDH）
- Feeds流业务（评价信息，问答信息，瀑布流，朋友圈）
- AI Storage（用户特征、NLP语料、模型存储）
- 时空数据（轨迹、气象网络）
- 金融业务（关联分析、信用分析、风控/白条/支付/资管）

**2.1  基于NoSQL的广告实时计算系统**

### **2.1.1  网络广告的几个大特性：**

相对传统广告，网络广告呈现出一些自身特点，了解这些特点，是网络广告营销策略实质的基础。网络广告的特点如下：

- 传播范围广：网络广告的传播范围广，不受时空的限制，可以通过互联网把广告信息全天候不间断的传播到世界各地。我国网民数量巨大，而且还在快速发展，这些网民有较高的消费能力，是网络广告的受众，可以在世界任何地方的互联网上随意的浏览广告，这种传播效果是任何一种传统媒体都无法达到的。
- 非强迫性传播资讯：网络广告属性按需广告，具有报纸分类广告的性质，却不需要受众彻底浏览，可以自由查询，并根据潜在顾客的需要主动呈现和展示，这样就节省了整个社会的注意力资源，提高了广告的针对性和有效性。
- 受众数据量可精准统计：传统的媒体广告，很难精准知道有多少人接触了广告信息，互联网广告，可以通过权威、公正的流量统计系统，精准统计每个广告的浏览人数以前这些用户查阅时长和地域分布，从而有利于正确的评估广告效果，进一步优化广告投放策略。
- 灵活的时效性：互联网广告能按需要及时更新广告内容。
- 强烈的交换性和感官性：网络广告的载体基本都是多媒体，超文本等，需要受众对产品感兴趣，仅需要点击进一步了解更多、更详细、更生动的信息，甚至还能让消费者亲自体验产品，服务和品牌，通过虚拟现实技术，可以让顾客身临其境。

### **2.1.2 网络广告的数据类型：**

网络广告相关的采集数据很多种，其中最关键的有四类：展现、点击、行为、和第三方数据监控。

- **广告展现数据**

广告展现数据是指广告位获得的展现的数据，一般该数据都需要发送到服务器端，用于广告展现量（adpv）的统计分析。一般数据包含日期、用户ID、广告ID和IP等信息。下面是一种广告展现的数据格式，其中JSON字段扩展：

```
2015-01-13 19:11:55{00D81D1D-00A291-0E2300-87DBCE0DA90} {“adia”:"31769","asid": "2","aspid":"0","ptime": "14","ag":"4,5.20,26.1908","ecode": "15","type":"2","dp1": "1","adpid":"0","dsp": "0","source": "s"}61.237.239.3 天津 天津市
复制代码
```

- **广告点击数据**

广告点击数据是指各个广告位获取的用户点击的数据，一般该数据也都需要发送到服务器端，用于广告点击量（adclick）的统计分析。一般点击数据包含日期、用户ID、广告ID和IP等信息。下面是一种广告点击的数据格式，与广告展示并没有多少区别：

```
2015-01-13 00:11:06{D33333C3-000C84-2345FB-DB768EC56} {"wid":"13","aid": "103297","vid":"1446779","adid": "29260","asid":"1","aspid": "1","mid":"16507","mg": "155","area":"13","dsp": "3"} 175.8.146.246 湖南省 长沙市
复制代码
```

- **广告行为数据**

广告行为数据是指广告位获得的用户下载、安装或者交易的数据，一般该数据也都需要发送到服务器端，用于广告行为（adaction）的他那个就分析。一般行为数据包含日期、用户ID、广告ID和IP等信息。下面是一种广告行为的数据格式，与广告展示数据也没有多少区别，只是JSON扩展字段总的一些信息不同：

```
2015-01-13 09:59:39{00567D26AD-565D01-C2238-F99000C0A0} {"adid":"234555","asid": "562", "aspid":"12","type": "1"} 120.29.183.47 福建省 宁德市
复制代码
```

- **第三方监控数据**

为使得广告主方便了解目标消费的网络媒体浏览习惯，转化成顾客的概率等，并且获取公正、客观、权威的统计信息，非常的有必要使用第三方广告监控公司参与广告投放的监控。而第三方的监控也会生产监控数据，包含日期、广告ID和用户ID等。下面是第三方监控数据的示例：

```
2014-12-31 108A451BD3787_22E6_D020_786DF2695B {000AD54073-19DDC2-971F26-36F4119425}
复制代码
```

### **2.1.3.  广告数据的挑战**

数据价值随着时间的流逝而降低，所以事件出现后必须尽快对他们进行处理，最好数据出现后便立刻能对其进行处理，发生一个事件进行一次处理，而不是缓存起来成批再处理，在数据流模型中，需要处理的输入数据（全部或是部分）并不存储在可随机访问的磁盘或是内存中，他们以一个或是多个“连续数据流”的形式到达。数据不同于传统的存储关系模型，主要有一下几个方面特点：

- 流中的数据元素在线到达，需要实时处理
- 系统无法控制将要处理的新到达的数据元素的顺序，无论这些数据元素是在一个数据流中还在跨多个数据流；也即重放的数据流可能和上次数据流的元素顺序不一致。
- 数据流的潜在大小也许是无穷无尽的。
- 一旦数据流中的某个元素经过处理，要么被丢弃，要么被归档存储。

### **2.1.4 系统主要功能**

该系统目前只为广告业服务，要求广告展现数据和广告点击数据能够实时的反映到库存系统，库存系统可以根据现有投放量计算之后的投放策略。同时，能提供某些广告在月每天的展现量统计，并且可以分省，市和用户三个维度统计。在满足上面功能的前提下，对系统性能要求延时在30秒内，支持峰值在TPS=500W的访问请求。

### **2.1.5.  系统架构**

根据前面的需求分析，设计目标和主要功能的要求，将整个广告实时计算系统划分为六层：日志接收层、生产者层、消费队列层、消费者层、业务逻辑层和存储层。其中消息队列选用京东JDQ实时数据管道，提供基于Kafka实现的高吞吐的分布式消息队列，供流式计算场景使用，业务逻辑层选用京东JRC 流式计算，提供基于Flink的流式计算引擎，用于流式计算，存储选用高并发、低延迟、高可用，满足千万级QPS高吞吐、随机读写的NoSQL分布式存储。架构图如下：



![img](https://user-gold-cdn.xitu.io/2020/1/14/16fa375bbe20850a?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



- 日志接收层

该层是数据源头，通过日志接收工具生产本地日志文件。常用的接收工具包括Scribe、Nginx、Syslog-ng和Apache Http Server等，接收后这些数据流将存储到本地磁盘文件中。

- 生产者层

该层是数据传输层，用于将日志文件从本地发生到Kafka集群，实时监控指定的文件或是目录，提取增量数据发送到Kafka集群。

- 消息队列层

该层是Kafka集群，负责输入数据的负载均衡、消息缓冲、同时具备高吞吐、水平扩展性好等特征。消息队列层之所以选择Kafka，是因为Kafka侧重吞吐量的特性，并且具备缓冲的功能。

- 消费者层

该层应用消费kafka队列中的消息，并且将消息数输入到业务逻辑层，是承上启下的子层。由于业务逻辑层使用Flink框架，所有消费层需要连通Kafka和Flink两个集群。

- 业务逻辑层

该层是实现需求的重要子层，使用Flink框架，能够非常方便的部署不同规则的业务需求，并且可以实现快速计算。

- 存储层

目标存储选择使用的分布式存储NoSQL，可以满足高吞吐低延时实时更新、查找某些特定场景的的业务需求，也可以满足水平扩展的需求。

### **2.1.6.  表设计**

为满足最终结果的实时查询和周期性统计需求，将结果数据存在NoSQL中，首先需要定义表的结构。因为数据包括广告展现和广告点击两类无关联的数据，并且业务方向也不同，所以需要创建两个表来存储这两类数据的统计结构。

- 广告实时展现统计表

广告实时展示统计表的结构设计如下：



![img](https://user-gold-cdn.xitu.io/2020/1/14/16fa375bbf976a82?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



其中，行建的设计非常关键，该表包含三种类型的行建，分别以省名称、市名称和uid作为区分，用于更高效地统计这三个维度的数据；列族和列的数量都是1。下面是广告实时统计表的一行数据实例，其中value字段采用十六进制字节码表示，是长整型。

```
29260_{2EEBEE83-EEE4-EAE6-1F0D-A27AB14549FC}_20150117 column=pv:cnt,timestamp=1390261754783,
value= \x00\x00\x00\x00\x00\x00\x00\x02
复制代码
```

- 广告实时点击统计表

广告实时点击统计表的结构设如下：



![img](https://user-gold-cdn.xitu.io/2020/1/14/16fa375bc0099a77?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



相比广告实时展现统计表，实时点击统计表明显简单一些，行建只有一种类型：adid_加上日期，很常规的一种设计方案；列族和列的数据量都是1。下面是广告实时点击统计表的一行数据示例，其中value字段采用十六进制字节码表示，是长整型。

```
36713_20150117 column=clk:cnt, timestamp=1390374472961, value=\x00\x00\x00\x00\x00\x00\x00\x06
复制代码
```

### **2.1.7.  使用NoSQL统计数据**

根据上面表结构设计的描述和实现，该结构支持下面的多种实时查询的需求：

- 某个广告在某省的当前投放量。
- 某个广告在某市的当前投放量。
- 某个广告在某个用户客户端上的当前投放量
- 某个广告的当前点击量
- 某个广告在累计一段时间内（如一个月）的某个省的历史投放趋势
- 某个广告在累计一段时间内（如一个月）的某个市的历史投放趋势
- 某个广告在累计一段时间内（如一个月）的某个用户客户端上的历史投放趋势
- 某个广告在累计一段时间内（如一个月）的点击量趋势

以上提到的这些需求，通过封装NoSQL客户端可以非常方便的实现，并且满足实时性的需求。前端数据可视化可以借助开源的JavaScript的框架快速实现，如：echarts,highcharts, d3.js等

**总结**

根据Gartner的预计，全球非关系型数据库（NoSQL）在2020~2022预计保持在30%左右高速增长，远高于数据库整体市场。伴随着NoSQL和大数据技术的兴起和发展，基于NoSQL及NoSQL生态构建的低成本一站式数据处理平台正在蓬勃发展。目前支持：NoSQLAPI、关系PhoenixSQL、时序OpenTSDB、全文检索Solr/ES、时空GeoMesa、图HGraph、分析Spark on HBase等。随着NoSQL的高速发展，NoSQL用户群体越来越庞大，未来NoSQL及NoSQL生态也会更好的满足各种业务场景。