
搜索了很多资料，看了很多相关博客，终于还是踏过一个个大坑（相关方法都试过），实现相关功能。本文章亲试可行，转载请注明出处：
Protocol Buffer是google 的一种数据交换的格式，已经在Github开源，目前最新版本是3.1.0。它独立于语言，独立于平台。google 提供了多种语言的实现：Java、C#、C++、Go 和 Python,Objective-C，每一种实现都包含了相应语言的编译器以及库文件。由于它是一种二进制的格式，比使用 XML 进行数据交换快许多。可以把它用于分布式应用之间的数据通信或者异构环境下的数据交换。作为一种效率和兼容性都很优秀的二进制数据传输格式，可以用于诸如网络传输、配置文件、数据存储等诸多领域。

#mac相关配置
生成protoc，一步步跟随操作即可

 * 首先确保你已经安装brew
 * brew install automake
 * brew install libtool
 * brew install autoconf
 * 下载面向Objective-C的protobuf库，地址为(https://github.com/google/protobuf/releases),要下载对应Objective-C的版本比如 protobuf-objectivec-3.5.1.zip，解压
/Users/wangliugen/Desktop/FFB72176-1D4A-440C-8652-46B8CEA7AEB5.png

下面准备生成protoc

* cd到该文件夹下面，例如：cd /Users/***/Desktop/protobuf-3.5.1 
* ./autogen.sh
* ./configure
* make
* make check
* sudo make install

然后通过protoc --version查看，如果现实如下，则表示成功

查看安装好的查看安装好的protoc可以通过 open /usr/local/bin 看到protoc以及open /usr/local/include 看到google文件夹



#XCode相关配置

网上介绍大多是通过cocoaPods导入第三方库的形式将protobuf加入项目，但实测Podfile 里面pod 'ProtocolBuffers’（这个不行）。最终还是采用了手动导入的方式；

 * 进入mac相关配置中下载解压的包中
 * 找到如图文件夹，
 * 将其中googl文件夹和除开（GPBProtocolBuffers.m）的所有.h 和.m文件拷贝到项目第三方库的文件夹下面：如图
 * 开始编译（一堆错误，但是很容易解决），一是非ARC在ARC下编译错误（在build phase 相关文件后面添加-fno-objc-arc，基本导入的文件全部添加），二是google文件夹下相关头文件寻址错误，添加路径即可；此外还需添加头文件搜索路径如图：
 


#使用说明

 使用主要有三点
  
  * 一是建造model对应的创建的proto文件，
    ```
  syntax = "proto3";
  message YLmessage
 { 
    int32 text = 1;
    string receiveName = 2;
    string phone = 3;
  }
    ```
  * 二是将proto文件转换成OC能用的文件
  
    ```
    生成proto的oc文件
 protoc --proto_path=/Users/*****/Desktop/protoTest --objc_out=/Users/****/Desktop/OCProtobuf  /Users/******/Desktop/protoTest/message.proto
    其中--proto_path=/Users/wangliugen/Desktop/protoTest 为proto文件存放的文件夹
--objc_out=/Users/wangliugen/Desktop/OCProtobuf为生成OC文件存放的文件夹
/Users/wangliugen/Desktop/protoTest/message.proto为要转换的proto文件

    ```
    
  * 三是使用,将生成的.h和.m文件加入项目
  
	```
	    YLmessage * pmessage = [YLmessage new];
    pmessage.text = message;
    // 序列化为Data
    NSData *data = [pmessage data];
    NSLog(@"%@",data);
    [_webSocket send: data];
    
	```
	
	```
	
	- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
	
    if (_delegate && [_delegate respondsToSelector:@selector(receiveMessage:)])            
    {
        NSError *error;
         YLmessage * pmessage  = [[YLmessage alloc] initWithData:message error:&error];
        NSLog(@"%@",pmessage.description); 
        [_delegate receiveMessage: pmessage.text];
    }

  }

	```
  

  
  

















