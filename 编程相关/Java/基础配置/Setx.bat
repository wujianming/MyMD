:: ���û�������
 
:: �ر��ն˻���
@echo off
 
set ENV_PATH=%PATH%
@echo ====current environment��
@echo %ENV_PATH%
 
:: ��ӻ�������,����ԭ���Ļ������������Ӣ��״̬�µķֺź�·��
set M2_HOME=C:\MyTools\apache-maven-3.6.3
set M2=%M2_HOME%\bin
set MAVEN_OPTS=-Xms256m -Xmx512m

@echo ====new environment��
@echo %ENV_PATH%