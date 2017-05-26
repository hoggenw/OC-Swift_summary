#Java 常用笔记

* 编译javac *****.java
* 运行 java *****


#查询ip命令
ifconfig

#编译运行

./gradlew bootRun
//配置变化
./gradlew idea
//
open JavaPractice.ipr

./gradlew cleanIdea idea


#新建
```
$ mkdir hello-world
$ cd hello-world
$ gradle init --type java-library
$ vim build.gradle  # 添加 apply plugin: 'idea' 后保存退出
$ ./gradlew idea
$ ./gradlew build
$ open hello-world.ipr # 可以直接用IntelliJ打开该文件
```

#5月17日记录心得
* @RequestBody可以自动将json转化为对象类，当相关属性要有set和get方法
* @RequestBody也可以自动将json转化为字典（HashTable）,
* @ResponseBody可以自动将返回值转化为json对象。返回类型可以用Object声明
* @RequestBody接收json请求数据时候，前端传值也应该是json格式


#静态资源访问
1.图片资源
Spring Boot默认提供静态资源目录位置需置于classpath下，目录名需符合如下规则：

/static
/public
/resources
/META-INF/resources
举例：我们可以在src/main/resources/目录下创建static，在该位置放置一个图片文件。启动程序后，尝试访问http://localhost:8080/D.png。

2.web页面(未完全理解HttpServletRequest req, ModelMap)

* 确认路径它们默认的模板配置路径为：src/main/resources/templates
* 在该路径下创建html文件
* 添加支持库
* 使用@Controller
* return模板文件的名称
