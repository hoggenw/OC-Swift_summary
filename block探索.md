#####概述

代码块Block是苹果在iOS4开始引入的对C语言的扩展,用来实现匿名函数的特性,Block是一种特殊的数据类型,其可以正常定义变量、作为参数、作为返回值,特殊地,Block还可以保存一段代码,在需要的时候调用,目前Block已经广泛应用于iOS开发中,常用于GCD、动画、排序及各类回调


#####Block变量的声明

Block变量的声明格式为: 返回值类型(^Block名字)(参数列表); ^被称作"脱字符";

```
// 声明一个无返回值,参数为两个字符串对象,叫做aBlock的Block
void(^aBlock)(NSString *x, NSString *y);

// 形参变量名称可以省略,只留有变量类型即可
void(^aBlock)(NSString *, NSString *);

```

#####Block变量的赋值


Block变量的赋值格式为: Block变量 = ^(参数列表){函数体};

```
aBlock = ^(NSString *x, NSString *y){
    NSLog(@"%@ love %@", x, y);
};

```

注: Block变量的赋值格式可以是: Block变量 = ^返回值类型(参数列表){函数体};,不过通常情况下都将返回值类型省略,因为编译器可以从存储代码块的变量中确定返回值的类型



#####声明Block变量的同时进行赋值

```
int(^myBlock)(int) = ^(int num){
    return num * 7;
};

// 如果没有参数列表,在赋值时参数列表可以省略
void(^aVoidBlock)() = ^{
    NSLog(@"I am a aVoidBlock");
};

```

#####Block变量的调用

```
// 调用后控制台输出"Li Lei love Han Meimei"
aBlock(@"Li Lei",@"Han Meimei");

// 调用后控制台输出"result = 63"
NSLog(@"result = %d", myBlock(9));

// 调用后控制台输出"I am a aVoidBlock"
aVoidBlock();


```


#####使用typedef定义Block类型
在实际使用Block的过程中,我们可能需要重复地声明多个相同返回值相同参数列表的Block变量,如果总是重复地编写一长串代码来声明变量会非常繁琐,所以我们可以使用typedef来定义Block类型

```
// 定义一种无返回值无参数列表的Block类型
typedef void(^SayHello)();

// 我们可以像OC中声明变量一样使用Block类型SayHello来声明变量
SayHello hello = ^(){
    NSLog(@"hello");
};

// 调用后控制台输出"hello"
hello();

```

#####Block作为函数参数

```
// 1.定义一个形参为Block的OC函数
- (void)useBlockForOC:(int(^)(int, int))aBlock
{
    NSLog(@"result = %d", aBlock(300,200));
}

// 2.声明并赋值定义一个Block变量
int(^addBlock)(int, int) = ^(int x, int y){
    return x+y;
};

// 3.以Block作为函数参数,把Block像对象一样传递
[self useBlockForOC:addBlock];

// 将第2点和第3点合并一起,以内联定义的Block作为函数参数
[self useBlockForOC:^(int x, int y){
    return x+y;
}];

```



使用typedef简化Block


```
// 1.使用typedef定义Block类型
typedef int(^MyBlock)(int, int);

// 2.定义一个形参为Block的OC函数
- (void)useBlockForOC:(MyBlock)aBlock
{
    NSLog(@"result = %d", aBlock(300,200));
}

// 3.声明并赋值定义一个Block变量
MyBlock addBlock = ^(int x, int y){
    return x+y;
};

// 4.以Block作为函数参数,把Block像对象一样传递
[self useBlockForOC:addBlock];

// 将第3点和第4点合并一起,以内联定义的Block作为函数参数
[self useBlockForOC:^(int x, int y){
    return x+y;
}];

```
#####Block内与局部变量
在Block中可以访问局部变量([传值]())

```

// 声明局部变量global
int global = 100;

void(^myBlock)() = ^{
    NSLog(@"global = %d", global);
};
// 调用后控制台输出"global = 100"
myBlock();
```

在声明Block之后、调用Block之前对局部变量进行修改,在调用Block时局部变量值是修改之前的旧值

```
// 声明局部变量global
int global = 100;

void(^myBlock)() = ^{
    NSLog(@"global = %d", global);
};
global = 101;
// 调用后控制台输出"global = 100"
myBlock();

```
在Block中不可以直接修改局部变量

```
// 声明局部变量global
int global = 100;

void(^myBlock)() = ^{
    global ++; // 这句报错
    NSLog(@"global = %d", global);
};
// 调用后控制台输出"global = 100"
myBlock();

```


注: 原理解析,通过clang命令将OC转为C++代码来查看一下Block底层实现,clang命令使用方式为终端使用cd定位到main.m文件所在文件夹,然后利用clang -rewrite-objc main.m将OC转为C++,成功后在main.m同目录下会生成一个main.cpp文件

```
// OC代码如下
void(^myBlock)() = ^{
    NSLog(@"global = %d", global);
};

// 转为C++代码如下
void(*myBlock)() = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, global));

// 将变量类型精简之后C++代码如下,我们发现Block变量实际上就是一个指向结构体__main_block_impl_0的指针,而结构体的第三个元素是局部变量global的值
void(*myBlock)() = &__main_block_impl_0(__main_block_func_0, &__main_block_desc_0_DATA, global);

// 我们看一下结构体__main_block_impl_0的代码
struct __main_block_impl_0 {
struct __block_impl impl;
struct __main_block_desc_0* Desc;
int global;
__main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int _global, int flags=0) : global(_global) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

// 在OC中调用Block的方法转为C++代码如下,实际上是指向结构体的指针myBlock访问其FuncPtr元素,在定义Block时为FuncPtr元素传进去的__main_block_func_0方法
((void (*)(__block_impl *))((__block_impl *)myBlock)->FuncPtr)((__block_impl *)myBlock);

// __main_block_func_0方法代码如下,由此可见NSLog的global正是定义Block时为结构体传进去的局部变量global的值
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
    int global = __cself->global; // bound by copy
    NSLog((NSString *)&__NSConstantStringImpl__var_folders_6y_vkd9wnv13pz6lc_h8phss0jw0000gn_T_main_d5d9eb_mi_0, global);
}

// 由此可知,在Block定义时便是将局部变量的值传给Block变量所指向的结构体,因此在调用Block之前对局部变量进行修改并不会影响Block内部的值,同时内部的值也是不可修改的


```

#####Block内访问__block修饰的局部变量[传址]()
在局部变量前使用下划线下划线block修饰,在声明Block之后、调用Block之前对局部变量进行修改,在调用Block时局部变量值是修改之后的新值


```
// 声明局部变量global
__block int global = 100;

void(^myBlock)() = ^{
    NSLog(@"global = %d", global);
};
global = 101;
// 调用后控制台输出"global = 101"
myBlock();

```
在局部变量前使用下划线下划线block修饰,在Block中可以直接修改局部变量


```
// 声明局部变量global
__block int global = 100;

void(^myBlock)() = ^{
    global ++; // 这句正确
    NSLog(@"global = %d", global);
};
// 调用后控制台输出"global = 101"
myBlock();

```


实现

```
// OC代码如下
void(^myBlock)() = ^{
    NSLog(@"global = %d", global);
};

// 转为C++代码如下
void(*myBlock)() = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, (__Block_byref_global_0 *)&global, 570425344));

// 将变量类型精简之后C++代码如下,我们发现Block变量实际上就是一个指向结构体__main_block_impl_0的指针,而结构体的第三个元素是局部变量global的指针
void(*myBlock)() = &__main_block_impl_0(__main_block_func_0, &__main_block_desc_0_DATA, &global, 570425344);

// 由此可知,在局部变量前使用__block修饰,在Block定义时便是将局部变量的指针传给Block变量所指向的结构体,因此在调用Block之前对局部变量进行修改会影响Block内部的值,同时内部的值也是可以修改的

```


#####Block内访问全局变量

在Block中可以直接修改全局变量

```
/ OC代码如下
void(^myBlock)() = ^{
    NSLog(@"global = %d", global);
};

// 转为C++代码如下
void(*myBlock)() = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA));

// 将变量类型精简之后C++代码如下,我们发现Block变量实际上就是一个指向结构体__main_block_impl_0的指针,而结构体中并未保存全局变量global的值或者指针
void(*myBlock)() = &__main_block_impl_0(__main_block_func_0, &__main_block_desc_0_DATA);

// 我们看一下结构体__main_block_impl_0的代码
struct __main_block_impl_0 {
struct __block_impl impl;
struct __main_block_desc_0* Desc;
__main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

// 在OC中调用Block的方法转为C++代码如下,实际上是指向结构体的指针myBlock访问其FuncPtr元素,在定义Block时为FuncPtr元素传进去的__main_block_func_0方法
((void (*)(__block_impl *))((__block_impl *)myBlock)->FuncPtr)((__block_impl *)myBlock);

// __main_block_func_0方法代码如下,由此可见NSLog的global还是全局变量global的值
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
    NSLog((NSString *)&__NSConstantStringImpl__var_folders_6y_vkd9wnv13pz6lc_h8phss0jw0000gn_T_main_f35954_mi_0, global);
}

// 由此可知,全局变量所占用的内存只有一份,供所有函数共同调用,在Block定义时并未将全局变量的值或者指针传给Block变量所指向的结构体,因此在调用Block之前对局部变量进行修改会影响Block内部的值,同时内部的值也是可以修改的




```

#####Block内访问静态变量
在Block中可以访问静态变量,在Block中可以直接修改静态变量

```
// 声明静态变量global
static int global = 100;

void(^myBlock)() = ^{
    global ++;
    NSLog(@"global = %d", global);
};
// 调用后控制台输出"global = 101"
myBlock();

```

```
/ OC代码如下
void(^myBlock)() = ^{
    NSLog(@"global = %d", global);
};

// 转为C++代码如下
void(*myBlock)() = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, &global));

// 将变量类型精简之后C++代码如下,我们发现Block变量实际上就是一个指向结构体__main_block_impl_0的指针,而结构体的第三个元素是静态变量global的指针
void(*myBlock)() = &__main_block_impl_0(__main_block_func_0, &__main_block_desc_0_DATA, &global);

// 我们看一下结构体__main_block_impl_0的代码
struct __main_block_impl_0 {
struct __block_impl impl;
struct __main_block_desc_0* Desc;
int *global;
__main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int *_global, int flags=0) : global(_global) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

// 在OC中调用Block的方法转为C++代码如下,实际上是指向结构体的指针myBlock访问其FuncPtr元素,在定义Block时为FuncPtr元素传进去的__main_block_func_0方法
((void (*)(__block_impl *))((__block_impl *)myBlock)->FuncPtr)((__block_impl *)myBlock);

// __main_block_func_0方法代码如下,由此可见NSLog的global正是定义Block时为结构体传进去的静态变量global的指针
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
    int *global = __cself->global; // bound by copy
    NSLog((NSString *)&__NSConstantStringImpl__var_folders_6y_vkd9wnv13pz6lc_h8phss0jw0000gn_T_main_4d124d_mi_0, (*global));
}

// 由此可知,在Block定义时便是将静态变量的指针传给Block变量所指向的结构体,因此在调用Block之前对静态变量进行修改会影响Block内部的值,同时内部的值也是可以修改的

```

###Block在MRC及ARC下的内存管理

#####Block在MRC及ARC下的内存管理

默认情况下,Block的内存存储在栈中,不需要开发人员对其进行内存管理

在Block的内存存储在栈中时,如果在Block中引用了外面的对象,不会对所引用的对象进行任何操作

```
Person *p = [[Person alloc] init];

void(^myBlock)() = ^{
    NSLog(@"------%@", p);
};
myBlock();

[p release]; // Person对象在这里可以正常被释放

```
如果对Block进行一次copy操作,那么Block的内存会被移动到堆中,这时需要开发人员对其进行release操作来管理内存

```
void(^myBlock)() = ^{
    NSLog(@"------");
};
myBlock();

Block_copy(myBlock);

// do something ...

Block_release(myBlock);

```



如果对Block进行一次copy操作,那么Block的内存会被移动到堆中,在Block的内存存储在堆中时,如果在Block中引用了外面的对象,会对所引用的对象进行一次retain操作,即使在Block自身调用了release操作之后,Block也不会对所引用的对象进行一次release操作,这时会造成内存泄漏


```
Person *p = [[Person alloc] init];

void(^myBlock)() = ^{
    NSLog(@"------%@", p);
};
myBlock();

Block_copy(myBlock);

// do something ...

Block_release(myBlock);

[p release]; // Person对象在这里无法正常被释放,因为其在Block中被进行了一次retain操作
```

如果对Block进行一次copy操作,那么Block的内存会被移动到堆中,在Block的内存存储在堆中时,如果在Block中引用了外面的对象,会对所引用的对象进行一次retain操作,为了不对所引用的对象进行一次retain操作,可以在对象的前面使用下划线下划线block来修饰


```
__block Person *p = [[Person alloc] init];

void(^myBlock)() = ^{
    NSLog(@"------%@", p);
};
myBlock();

Block_copy(myBlock);

// do something ...

Block_release(myBlock);

[p release]; // Person对象在这里可以正常被释放
```

#####Block在ARC下的内存管理

在ARC默认情况下,Block的内存存储在堆中,ARC会自动进行内存管理,程序员只需要避免循环引用即可


```
// 当Block变量出了作用域,Block的内存会被自动释放
void(^myBlock)() = ^{
    NSLog(@"------");
};
myBlock();

```



在Block的内存存储在堆中时,如果在Block中引用了外面的对象,会对所引用的对象进行强引用,但是在Block被释放时会自动去掉对该对象的强引用,所以不会造成内存泄漏


```
Person *p = [[Person alloc] init];

void(^myBlock)() = ^{
    NSLog(@"------%@", p);
};
myBlock();

// Person对象在这里可以正常被释放

```


因为Block是通过弱引用指向了myController对象,那么有可能在调用Block之前myController对象便已经被释放了,所以我们需要在Block内部再定义一个强指针来指向myController对象.在Block内部定义的变量,会在作用域结束时自动释放,Block对其并没有强引用关系,且在ARC中只需要避免循环引用即可,如果只是Block单方面地对外部变量进行强引用,并不会造成内存泄漏


```
__block在MRC下有两个作用

1. 允许在Block中访问和修改局部变量 

2. 禁止Block对所引用的对象进行隐式retain操作

__block在ARC下只有一个作用

1. 允许在Block中访问和修改局部变量

```


#####使用Block进行排序



在开发中,我们一般使用数组的如下两个方法来进行排序

```

不可变数组的方法: - (NSArray *)sortedArrayUsingComparator:(NSComparator)cmptr

可变数组的方法 : - (void)sortUsingComparator:(NSComparator)cmptr


```

其中,NSComparator是利用typedef定义的Block类型


```
typedef NSComparisonResult (^NSComparator)(id obj1, id obj2);
```
其中,这个返回值为NSComparisonResult枚举,这个返回值用来决定Block的两个参数顺序,我们只需在Block中指明不同条件下Block的两个参数的顺序即可,方法内部会将数组中的元素分别利用Block来进行比较并排序

```
typedef NS_ENUM(NSInteger, NSComparisonResult)
{
    NSOrderedAscending = -1L, // 升序,表示左侧的字符在右侧的字符前边
    NSOrderedSame, // 相等
    NSOrderedDescending // 降序,表示左侧的字符在右侧的字符后边
};
```


事例如下


```
@interface Student : NSObject

@property (nonatomic, assign) int age;

@end


@implementation Student

@end


Student *stu1 = [[Student alloc] init];
stu1.age = 18;
Student *stu2 = [[Student alloc] init];
stu2.age = 28;
Student *stu3 = [[Student alloc] init];
stu3.age = 11;

NSArray *array = @[stu1,stu2,stu3];

array = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    Student *stu1 = obj1;
    Student *stu2 = obj2;

    if (stu1.age > stu2.age)
    {
        return NSOrderedDescending; // 在这里返回降序,说明在该种条件下,obj1排在obj2的后边
    }
    else if (stu1.age < stu2.age)
    {
        return NSOrderedAscending;
    }
    else
    {
        return NSOrderedSame;
    }
}];

```























