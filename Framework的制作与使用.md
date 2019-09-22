##一、新建所需的资源bundle

###1.新建一个工程macOS的Bundle项目
![新建图片](/Users/wangliugen/Desktop/SelfProject/OC-Swift_summary/图片资源/新建bunlde1.png)

![新建图片](/Users/wangliugen/Desktop/SelfProject/OC-Swift_summary/图片资源/新建bunldle2.png)

###2.在bundle资源包中添加图片
使用Asset管理图片

```
直接拖入图片即可

因为Xcode的Assets,可以自动识别图片的二倍图还是三倍图,所以,就在bundle工程里面创建一个Assets,到时候就调用图片名称,会自动对应加载;

反正,只要把后缀为@2x,@3x的图片拖到Assets就会自动放到对应的位置;

下面就创建一个Assets文件

```


![新建图片](/Users/wangliugen/Desktop/SelfProject/OC-Swift_summary/图片资源/bunldeAsset.png)


###3.编译生成Bundle包


![新建图片](/Users/wangliugen/Desktop/SelfProject/OC-Swift_summary/图片资源/生成bundle.png)


```
找到bundle路劲即可
```

##二、新建Frame

###1.新建工程选择iOS —> Cocoa Touch Framework

![新建图片](/Users/wangliugen/Desktop/SelfProject/OC-Swift_summary/图片资源/新建frame.jpg)


###2.进入创建好的工程删除掉自带的工程同名头文件


###3.添加所需文件,包括制作好的bundle

![](/Users/wangliugen/Desktop/SelfProject/OC-Swift_summary/图片资源/frame添加资源文件.png)

###4.4.TARGETS —> Build Settings 中设置相关项

####（1).Build Active Architecture Only 设置为NO的意思是当前打包的.framework支持所有的设备.否则打包时只能用当前版本的模拟器或真机运行.
![](/Users/wangliugen/Desktop/SelfProject/OC-Swift_summary/图片资源/bundle设置1.jpg)

####（2).Build Setting 搜索linking 设置Dead Code Stripping 为NO是编译选项优化,包瘦身,(可不改) Mach-O Type 选中StaticLibrary (静态库) Xcode默认是动态库.
![](/Users/wangliugen/Desktop/SelfProject/OC-Swift_summary/图片资源/bundle设置12.jpg)

####（3). 设置framework最低支持的版本

![](/Users/wangliugen/Desktop/SelfProject/OC-Swift_summary/图片资源/bundle设置3.jpg)

####(4).TARGETS —> Build Phases
将需要呈现给来的头文件,直接从Project拖到Public中. 不想呈现出来的.h文件不建议拖到Private中. 放在project中即可

![](/Users/wangliugen/Desktop/SelfProject/OC-Swift_summary/图片资源/bundle设置4.png)

####(5) 在进行编译之前应该设置为release模式
![](/Users/wangliugen/Desktop/SelfProject/OC-Swift_summary/图片资源/bundle设置5.jpg)


内部分为Debug版本和Release版本，同时两者有分为真机版本和模拟器版本framework（iphoneos后缀代表真机版本，iphonesimulator后缀代表模拟器）
![](/Users/wangliugen/Desktop/SelfProject/OC-Swift_summary/图片资源/bundle设置6.png)

###5.真机版本和模拟器版本framework合并
#####(1).查看架构信息
打开终端使用命令行 lipo -info 查看framework架构信息
真机版本

（2）.合并真机模拟器版本
因为以上获取的framework只能在对应的版本上运行（即真机只能在设备上运行模拟器版本只能在模拟器上面运行使用）所以需要合并为通用版本（也可以单独提供，不合并，合并了会导致包很大，各有优缺点吧，如果framework包不太大建议合并，否则还是提供两个）


```
lipo -create /Users/*****/Library/Developer/Xcode/DerivedData/YLOCScan-fdsqdvvhpewfpbesnxgudqalcxov/Build/Products/Release-iphoneos/YLOCScan.framework/YLOCScan /Users/*****/Library/Developer/Xcode/DerivedData/YLOCScan-fdsqdvvhpewfpbesnxgudqalcxov/Build/Products/Release-iphonesimulator/YLOCScan.framework/YLOCScan -output /Users/*****/Desktop/SelfProject/YLTestCode/create_Resource/YLOCScan


```

然后把这个新生成的YLOCScan文件拷贝到相应的framework中进行AppVest文件替换



###6.制作好的framework集成使用
把制作好的framework拖入到工程中，引用相关头文件，然后初始化进行暴露方法调用



##三、相关问题


###1.调用该framework的app需要在 Build Settings ->Other Linker Flags 设置为-Objc(当framework中有使用了分类文件,就必须设置，否则无法加载；未使用可以不设置)

在开发中，导入一些静态库的时候经常会要求我们在Build Settings->Other Linker Flags设置-ObjC。


```
主要是因为OC语言中类别（分类），Unix的标准静态库实现和Objective-C的动态特性之间有一些冲突：
OC没有为每个函数（或者方法）定义链接符号，它只为每个类创建链接符号。这样当在一个静态库中使用类别
来扩展已有类的时候，链接器不知道如何把类原有的方法和类别中的方法整合起来，就会导致你调用类别中的
方法时，出现错误。为了解决这个问题，引入了-ObjC标志，它的作用就是将静态库中所有的和对象相关的文
件都加载进来。

另外还有两个方法，分别是用来全部导入和部分导入。使用-all_load 或者-force_load标志，它们的作
用都是加载静态库中所有文件，不过all_load作用于所有的库，而-force_load后面必须要指定具体的文
件。


```



###2. framework中文件引用要周全


###3.注意使用的时候不要模拟器使用真机的framework或者真机使用模拟器的framework，这些都会导致报错

###4. framework合并的是framework下frame名字的文件，而不是整个framework