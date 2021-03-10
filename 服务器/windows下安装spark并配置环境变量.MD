

# windows下安装spark并配置环境变量

## **一、下载**
https://mirrors.tuna.tsinghua.edu.cn/apache/spark/spark-2.4.7/
不需安装，直接解压放到想要放到的目录底下。

## **二、配置环境变量**
### 添加用户环境变量：
1.SPARK_HOME：D:\spark-2.4.3-bin-hadoop2.7
2.在系统环境变量Path增加：%SPARK_HOME%\bin

### 在控制台输入一下命令：spark-shell





# Spark本地运行increase heap size错误解决方案

#### 解决办法三（线上）

spark-defaults.conf文件中配置键值对：

```
spark.driver.memory              3g
```