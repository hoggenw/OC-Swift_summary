####一个NSObject对象占用多少内存?
a、系统会分配16个字节给NSObject对象（导入<malloc/malloc.h>，通过[malloc_size((__bridge const void *)obj]()函数来获取，注意：结构体会有字节对其原则，所以内存都会是16的倍数）

b、但是NSObject对象内部实际上只占用了8个字节（导入<objc/runtime.h>，64位环境下，通过class_getInstanceSize([NSObject class])函数获得，注意：同上根据字节对其原则，这个实际内存都会是8的倍数）

####对象的isa指针指向哪里?

对象分三种：实例对象instance、类对象class、元类对象meta-class，而且，三种对象中分别存储着以下内容

![对象指针.png](/Users/wangliugen/Desktop/SelfProject/OC-Swift_summary/图片资源/对象指针.png)

由此，也引申出了class对象的superclass指针的指向

例如：@interface Student ：Person            @interface Person：NSObject

那么你会发现他们的superclass指针的指向为下图所示

![对象指针.png](/Users/wangliugen/Desktop/SelfProject/OC-Swift_summary/图片资源/7429763-b7c68a41e65d3e55.png)


再由此，引申出了meta-class对象的superclass指针的指向


![对象指针.png](/Users/wangliugen/Desktop/SelfProject/OC-Swift_summary/图片资源/meta-class.png)


通过以上逐层分析，再看下图，Subclass=Student，Person=Superclass，NSObject=Rootclass，你是否会瞬间明白，唯一需要注意的就是根类的superclass指针指向的是根类的类对象


![对象指针.png](/Users/wangliugen/Desktop/SelfProject/OC-Swift_summary/图片资源/指向图.png)




###iOS程序的内存布局


![对象指针.png](/Users/wangliugen/Desktop/SelfProject/OC-Swift_summary/图片资源/内存布局.png)
