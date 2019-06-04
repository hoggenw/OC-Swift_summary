
tableview优化最主要：复用cell，header，footer实例；使用约束布局cell子控件时不多次添加约束；图片不过大，尽量不使用透明视图；避免阻塞主线程；计算高度方法不做大量逻辑处理

####1、cell复用
```
// 指定位置(indexPath)处的cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    // cell重用机制
    ShowInfoTableViewCell * cell = [ShowInfoTableViewCell cellInTableView:tableView];
    // cell数据展示
    ShowMessageModel *model = [self.dataArray objectAtIndex:indexPath.row];
    cell.model = model;
    return cell;
}

```

```
// 便利构造
+ (instancetype)cellInTableView:(UITableView *)tableView
{
    // 重用机制
    
    static NSString * const identifier = @"ShowInfoTableViewCell";
    ShowInfoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        // 代码创建
        cell=  [ShowInfoTableViewCell new];
        
    }
    return cell;
}


```

我们经常在注意cellForRowAtIndexPath：中为每一个cell绑定数据，实际上在调用cellForRowAtIndexPath：的时候cell还没有被显示出来，为了提高效率我们应该把数据绑定的操作放在cell显示出来后再执行，可以在tableView：willDisplayCell：forRowAtIndexPath：（以后简称willDisplayCell）方法中绑定数据。
注意willDisplayCell在cell 在tableview展示之前就会调用，此时cell实例已经生成，所以不能更改cell的结构，只能是改动cell上的UI的一些属性（例如label的内容等）

####2、cell高度的计算


这边我们分为两种cell，一种是定高的cell，另外一种是动态高度的cell。

（1）定高的cell，应该采用如下方式：

```
self.tableView.rowHeight = 88;

```

这个方法指定了所有cell高度都是88的tableview，rowHeight默认的值是44，所以一个空的TableView会显示成这个样子。对于定高cell，直接采用上面方式给定高度，不需要实现tableView:heightForRowAtIndexPath:以节省不必要的计算和开销。

（2）动态高度的cell


```
-(CGFloat)tableView:(UITableView)tableViewheightForRowAtIndexPath:(NSIndexPath)indexPath{

  return xxx

}

```

这个代理方法实现后，上面的rowHeight的设置将会变成无效。在这个方法中，我们需要提高cell高度的计算效率，来节省时间。
自从iOS8之后有了self-sizing cell的概念，cell可以自己算出高度，使用self-sizing cell需要满足以下三个条件：
（1）使用Autolayout进行UI布局约束（要求cell.contentView的四条边都与内部元素有约束关系）。
（2）指定TableView的estimatedRowHeight属性的默认值。
（3）指定TableView的rowHeight属性为UITableViewAutomaticDimension。

```
- (void)viewDidload {

  self.myTableView.estimatedRowHeight = 44.0;

  self.myTableView.rowHeight = UITableViewAutomaticDimension;

}

```
除了提高cell高度的计算效率之外，对于已经计算出的高度，我们需要进行缓存，对于已经计算过的高度，没有必要进行计算第二次。


####3、渲染

为了保证TableView的流畅，当快速滑动的时候，cell必须被快速的渲染出来。所以cell渲染的速度必须快。如何提高cell的渲染速度呢？
（1）当有图像时，预渲染图像，在bitmap context先将其画一遍，导出成UIImage对象，然后再绘制到屏幕，这会大大提高渲染速度。具体内容可以自行查找“利用预渲染加速显示iOS图像”相关资料。
（2）渲染最好时的操作之一就是混合(blending)了,所以我们不要使用透明背景，将cell的opaque值设为Yes，背景色不要使用clearColor，尽量不要使用阴影渐变等
（3）由于混合操作是使用GPU来执行，我们可以用CPU来渲染，这样混合操作就不再执行。可以在UIView的drawRect方法中自定义绘制。


####4、减少视图的数目

我们在cell上添加系统控件的时候，实际上系统都会调用底层的接口进行绘制，大量添加控件时，会消耗很大的资源并且也会影响渲染的性能。当使用默认的UITableViewCell并且在它的ContentView上面添加控件时会相当消耗性能。所以目前最佳的方法还是继承UITableViewCell，并重写drawRect方法。

#### 5、减少多余的绘制操作
在实现drawRect方法的时候，它的参数rect就是我们需要绘制的区域，在rect范围之外的区域我们不需要进行绘制，否则会消耗相当大的资源。

补充：请谨慎使用drawRect:方法，当cell中只有少量的子视图时，应当避免使用，因为重写drawRect：就是在此方法中一句代码都不写也会占用5-6M的内存。


#### 6、不要给cell动态添加subView


在初始化cell的时候就将所有需要展示的添加完毕，然后根据需要来设置hide属性显示和隐藏。


####7、异步化UI，不要阻塞主线程


我们时常会看到这样一个现象，就是加载时整个页面卡住不动，怎么点都没用，仿佛死机了一般。原因是主线程被阻塞了。所以对于网路数据的请求或者图片的加载，我们可以开启多线程，将耗时操作放到子线程中进行，异步化操作。这个或许每个iOS开发者都知道的知识，不必多讲。


####8、滑动时按需加载对应的内容


如果目标行与当前行相差超过指定行数，只在目标滚动范围的前后指定3行加载。


```
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollViewwithVelocity:(CGPoint)velocitytargetContentOffset:(inoutCGPoint *)targetContentOffset{
    
    NSIndexPath *ip=[selfindexPathForRowAtPoint:CGPointMake(0,targetContentOffset->y)];
    
    NSIndexPath *cip=[[selfindexPathsForVisibleRows]firstObject];
    
    NSIntegerskipCount=8;
    
    if(labs(cip.row-ip.row)>skipCount){
        
        NSArray *temp=[selfindexPathsForRowsInRect:CGRectMake(0,targetContentOffset->y,self.width,self.height)];
        
        NSMutableArray *arr=[NSMutableArrayarrayWithArray:temp];
        
        if(velocity.y<0){
            
            NSIndexPath**indexPath=[templastObject];
            
            if(indexPath.row+33){
                
                [arraddObject:[NSIndexPathindexPathForRow:indexPath.row-3inSection:0]];
                
                [arraddObject:[NSIndexPathindexPathForRow:indexPath.row-2inSection:0]];
                
                [arraddObject:[NSIndexPathindexPathForRow:indexPath.row-1inSection:0]];
            }
        }
        [needLoadArraddObjectsFromArray:arr];
    }
}
```


记得在tableView:cellForRowAtIndexPath:方法中加入判断：

```
if(needLoadArr.count>0&&[needLoadArrindexOfObject:indexPath]==NSNotFound){
    [cellclear];
    return;  
}

```


滑动很快时，只加载目标范围内的cell，这样按需加载（配合SDWebImage），极大提高流畅度。


####离屏渲染的问题

#####下面的情况或操作会引发离屏渲染：

为图层设置遮罩（layer.mask）
将图层的layer.masksToBounds / view.clipsToBounds属性设置为true
将图层layer.allowsGroupOpacity属性设置为YES和layer.opacity小于1.0
为图层设置阴影（layer.shadow *）。
为图层设置layer.shouldRasterize=true
具有layer.cornerRadius，layer.edgeAntialiasingMask，layer.allowsEdgeAntialiasing的图层
文本（任何种类，包括UILabel，CATextLayer，Core Text等）。
使用CGContext在drawRect :方法中绘制大部分情况下会导致离屏渲染，甚至仅仅是一个空的实现

#####优化方案


iOS 9.0 之前UIimageView跟UIButton设置圆角都会触发离屏渲染。

iOS 9.0 之后UIButton设置圆角会触发离屏渲染，而UIImageView里png图片设置圆角不会触发离屏渲染了，如果设置其他阴影效果之类的还是会触发离屏渲染的。



（1）圆角优化

在APP开发中，圆角图片还是经常出现的。如果一个界面中只有少量圆角图片或许对性能没有非常大的影响，但是当圆角图片比较多的时候就会APP性能产生明显的影响。

我们设置圆角一般通过如下方式：

```
imageView.layer.cornerRadius=CGFloat(10);
imageView.layer.masksToBounds=YES;
```

这样处理的渲染机制是GPU在当前屏幕缓冲区外新开辟一个渲染缓冲区进行工作，也就是离屏渲染，这会给我们带来额外的性能损耗，如果这样的圆角操作达到一定数量，会触发缓冲区的频繁合并和上下文的的频繁切换，性能的代价会宏观地表现在用户体验上——掉帧。

优化方案1：使用贝塞尔曲线UIBezierPath和Core Graphics框架画出一个圆角

```
UIImageView imageView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
imageView.image = [UIImage imageNamed:@"myImg"];
//开始对imageView进行画图
UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 1.0);
//使用贝塞尔曲线画出一个圆形图
[[UIBezierPath bezierPathWithRoundedRect:imageView.bounds cornerRadius:imageView.frame.size.width] addClip];
[imageView drawRect:imageView.bounds];
imageView.image = UIGraphicsGetImageFromCurrentImageContext();
//结束画图
UIGraphicsEndImageContext();
[self.view addSubview:imageView];

```



优化方案2：使用CAShapeLayer和UIBezierPath设置圆角

```
UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(100,100,100,100)];
imageView.image=[UIImage imageNamed:@"myImg"];
UIBezierPath *maskPath=[UIBezierPath bezierPathWithRoundedRect:imageView.boundsbyRoundingCorners:UIRectCornerAllCornerscornerRadii:imageView.bounds.size];
CAShapeLayer *maskLayer=[[CAShapeLayer alloc]init];
//设置大小
maskLayer.frame=imageView.bounds;
//设置图形样子
maskLayer.path=maskPath.CGPath;
imageView.layer.mask=maskLayer;
[self.view addSubview:imageView];

```


CAShapeLayer继承于CALayer,可以使用CALayer的所有属性值；
CAShapeLayer需要贝塞尔曲线配合使用才有意义（也就是说才有效果）
使用CAShapeLayer(属于CoreAnimation)与贝塞尔曲线可以实现不在view的drawRect（继承于CoreGraphics走的是CPU,消耗的性能较大）方法中画出一些想要的图形
CAShapeLayer动画渲染直接提交到手机的GPU当中，相较于view的drawRect方法使用CPU渲染而言，其效率极高，能大大优化内存使用情况。
总的来说就是用CAShapeLayer的内存消耗少，渲染速度快，建议使用优化方案2。


（2）shadow优化对于shadow，如果图层是个简单的几何图形或者圆角图形，我们可以通过设置shadowPath来优化性能，能大幅提高性能。示例如下：

```
imageView.layer.shadowColor=[UIColor grayColor].CGColor;
imageView.layer.shadowOpacity=1.0;
imageView.layer.shadowRadius=2.0;
UIBezierPath *path=[UIBezierPath bezierPathWithRect:imageView.frame];
imageView.layer.shadowPath=path.CGPath;

```


我们还可以通过设置shouldRasterize属性值为YES来强制开启离屏渲染。其实就是光栅化（Rasterization）。既然离屏渲染这么不好，为什么我们还要强制开启呢？当一个图像混合了多个图层，每次移动时，每一帧都要重新合成这些图层，十分消耗性能。当我们开启光栅化后，会在首次产生一个位图缓存，当再次使用时候就会复用这个缓存。但是如果图层发生改变的时候就会重新产生位图缓存。所以这个功能一般不能用于UITableViewCell中，cell的复用反而降低了性能。最好用于图层较多的静态内容的图形。而且产生的位图缓存的大小是有限制的，一般是2.5个屏幕尺寸。在100ms之内不使用这个缓存，缓存也会被删除。所以我们要根据使用场景而定。

（3）其他的一些优化建议
当我们需要圆角效果时，可以使用一张中间透明图片蒙上去
使用ShadowPath指定layer阴影效果路径
使用异步进行layer渲染（Facebook开源的异步绘制框架AsyncDisplayKit）
设置layer的opaque值为YES，减少复杂图层合成
尽量使用不包含透明（alpha）通道的图片资源
尽量设置layer的大小值为整形值
直接让美工把图片切成圆角进行显示，这是效率最高的一种方案
很多情况下用户上传图片进行显示，可以让服务端处理圆角
使用代码手动生成圆角Image设置到要显示的View上，利用UIBezierPath（CoreGraphics框架）画出来圆角图片























