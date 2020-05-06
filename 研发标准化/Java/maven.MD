 

```maven配置
<mirror>
	<id>local.public.org</id>
	<name>local public of leadsoft</name>
	<url>http://172.16.2.57:8081/nexus/content/repositories/central/</url>
	<mirrorOf>*</mirrorOf>
</mirror>
<mirror>
	<id>local.releases.org</id>
	<name>local releases of leadsoft</name>
	<url>http://172.16.2.57:8081/nexus/content/repositories/releases/</url>
	<mirrorOf>*</mirrorOf>
 </mirror>
 <mirror>
	<id>local.releases.org</id>
	<name>local public of leadsoft</name>
	<url>http://172.16.2.57:8081/nexus/content/repositories/public/</url>
	<mirrorOf>*</mirrorOf>
 </mirror>
```
