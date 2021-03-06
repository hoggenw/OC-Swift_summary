#pre
一般来说我们使用delegate,notification,KVO，都是为了实现程序的不过分耦合或者优化相关demo设计；所以一般APP中我们都会使用到：

```

1.委托delegation；
 
2.通知中心Notification Center； 

3.键值观察key value observing，KVO 

```

本质上说，我认为三种设计模式都是事件的传递，且可以有效避免对象之间的耦合（这是复用独立组件的基础）；
###delegate

我喜欢称为代理和协议；代理即一个对象代理另一个对象实现代理方法；协议为遵守该协议的对象实现该协议的方法（或者说实现协议默认方法）；

1. delegate有清晰的事件传递链，可以很好的帮助理解程序的实现逻辑及流程
2. delegate的定义的语法严格（如定义方法可选和必须实现），避免遗忘和出错
3. delegate可以遵守多个协议，模拟了多继承的关系
4. delegate的方法直接定义到对象的结构体中，查找快速，效率高，消耗资源少
5. delegate除了传值意外也可以接受返回值
6. delegate方便于代码调试

补充：

1. 定义和实现整个delegate必须包含（1.定义协议 2.遵守协议 3. 实现协议）
2. 使用delegate要避免循环引用
3. 一对一而非一对多


###notification

在IOS应用开发中有一个”Notification Center“的概念。它是一个单例对象，允许当事件发生时通知一些对象。它允许我们在低程度耦合的情况下，满足控制器与一个任意的对象进行通信的目的。

优势

1. 系统自带的，实现简单
2. 能实现1对多的事件通知
3. 可以携带通知信息

缺点：

1. 没有清晰的事件链，过多使用的情况下可能导致APP难以理解和维护
2. 调试时过程难以跟踪
3. 需要第三方单例来管理，使用key来辨识通知事件，（猜测接收通知的对象会被注册到Notification Center中，便于通知事件的查找；通知过多的情况下可能导致资源浪费）
4. 无法获取返回信息
5. 需要使用完毕后移除观察者，否则极易造成crash


###KVO

KVO是一个对象能够观察另外一个对象的属性的值，并且能够发现值的变化。这是一个对象与另外一个对象保持同步的一种方法，即当另外一种对象的状态发生改变时，观察对象马上作出反应。它只能用来对属性作出反应，而不会用来对方法或者动作作出反应。

优点：

  1. 能够提供一种简单的方法实现两个对象间的同步。例如：model和view之间同步；

  2. 能够对非我们创建的对象，即内部对象的状态改变作出响应，而且不需要改变内部对象（SKD对象）的实现；

  3. 能够提供观察的属性的最新值以及先前值；

  4. 用key paths来观察属性，因此也可以观察嵌套对象；

  5. 完成了对观察对象的抽象，因为不需要额外的代码来允许观察值能够被观察

缺点：

  1. 我们观察的属性必须使用strings来定义。因此在编译器不会出现警告以及检查；

  2. 对属性重构将导致我们的观察代码不再可用；

  3. 复杂的“IF”语句要求对象正在观察多个值。这是因为所有的观察代码通过一个方法来指向；

  4. 当释放观察者时不需要移除观察者。
  
  
  
  综上所述，我认为KVO的使用时明确的，而对于delegate和notification，我更偏向使用delegate
  而少用或者不用notification，从代码便于维护和结构清晰的角度考虑。
  
  
  ###KVO实现探究
  
  四要素：观察者，被观察对象，被观察对象属性，响应方法
  
  1. 为NSObject+YLKVO.h自定义扩展，添加方法
     - -(void)YLAddObserver:(NSObject *)observer
                forKey:(NSString *)key
             withBlock:(YLKVOBlock)block;//添加观察者

     - -(void)YLRemoveObserver:(NSObject *)observer forKey:(NSString *)key;//移除观察者
     - typedef void (^YLKVOBlock)(id observedObject, NSString *observedKey, id oldValue, id newValue);//使用block做响应事件
     
   2. 添加观察者
     - 判断被观察对象属性是否实现setter方法
     - 动态创建被观察对象的子类（如果没有被创建：继承被观察对象，分配空间，添加class方法，注册类）
     - 为子类添加属性的setter方法:
    
    ``` 
        1. 获取getter方法
        2. 获取oldvalue
        3. 构建receiver的结构体，将新值直接赋值给父类的setter方
        
        4. 获取动态关联（观察者）数组 （遍历key与setter相同的，异步执行block块）
    ```  
     
     - 初始化观察者信息动态添加到观察者数组中去
   
   3. 移除观察者

    动态获取观察者数组并且比对移除
    
    
    具体demo在yltestcode中的YLAudioFrequecy中
   
     
         
  
  
  
  
  
  
  
  
  
  
  
