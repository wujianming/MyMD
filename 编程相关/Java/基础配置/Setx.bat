:: 设置环境变量
 
:: 关闭终端回显
@echo off
 
set ENV_PATH=%PATH%
@echo ====current environment：
@echo %ENV_PATH%
 
:: 添加环境变量,即在原来的环境变量后加上英文状态下的分号和路径
set M2_HOME=C:\MyTools\apache-maven-3.6.3
set M2=%M2_HOME%\bin
set MAVEN_OPTS=-Xms256m -Xmx512m

@echo ====new environment：
@echo %ENV_PATH%