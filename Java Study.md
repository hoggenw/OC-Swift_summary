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