#一、Resource
```
//是一个URL遵守的Protocol
public protocol Resource {
    var cacheKey: String { get }
    var downloadURL: URL { get }
}
//如果未有传入key，那么key的值就是downloadURL.absoluteString，一般URL不为nil
public struct ImageResource: Resource {

    public let cacheKey: String

    public let downloadURL: URL

    public init(downloadURL: URL, cacheKey: String? = nil) {
        self.downloadURL = downloadURL
        self.cacheKey = cacheKey ?? downloadURL.absoluteString
    }
}
//遵守Resource
extension URL: Resource {
    public var cacheKey: String { return absoluteString }
    public var downloadURL: URL { return self }
}
```

#二、Kingfisher
```
//申明一个名为Kingfisher的泛型类，及初始化方法
public final class Kingfisher<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}
//定义协议 KingfisherCompatible，声明属性 kf，类型是范型 CompatibleType 。
//并要求遵守协议的一方，实现该属性的 get 方法。
public protocol KingfisherCompatible {
    associatedtype CompatibleType
    var kf: CompatibleType { get }
}
//在协议扩展中，协议自身实现了属性。这样就不必在每个遵守该协议的类里实现该属性了
public extension KingfisherCompatible {
    public var kf: Kingfisher<Self> {
        get { return Kingfisher(self) }
    }
}
//Image Imageview Button 遵循 KingfisherCompatible协议，并且在不需要实现的
//情况下拥有kf属性，
extension Image: KingfisherCompatible { }
#if !os(watchOS)
extension ImageView: KingfisherCompatible { }
extension Button: KingfisherCompatible { }
```

#三、KingfisherOptionsInfoItem
```
//别名[KingfisherOptionsInfoItem]并定义一个空KingfisherOptionsInfo
public typealias KingfisherOptionsInfo = [KingfisherOptionsInfoItem]
let KingfisherEmptyOptionsInfo = [KingfisherOptionsInfoItem]()
//KingfisherOptionsInfoItem 是一个枚举 配置 Kingfisher所有功能行为
public enum KingfisherOptionsInfoItem {

    这个成员的关联值是一个ImageCache对象。 Kingfisher使用指定的缓存对象处理 相关业务,包括试图检索缓存图像和存储下载的图片。
    case targetCache(ImageCache)

    这个成员的关联值应该是一个ImageDownloader对象。Kingfisher将使用这个下载器下载的图片。
    case downloader(ImageDownloader)

    如果从网络下载的图片 Kingfisher将使用“ImageTransition这个枚举动画。从内存或磁盘缓存时默认过渡不会发生。如果需要,设置ForceTransition
    case transition(ImageTransition)

    有关“浮动”值将被设置为图像下载任务的优先级。值在0.0 ~ 1.0之间。如果没有设置这个选项,默认值(“NSURLSessionTaskPriorityDefault”)将被使用。
    case downloadPriority(Float)

    如果设置,将忽略缓存,开启一个下载任务的资源
    case forceRefresh

    如果设置 即使缓存的图片也将开启过渡动画
    case forceTransition

    如果设置，Kingfisher只会在内存中缓存值而不是磁盘
    case cacheMemoryOnly

    如果设置 Kingfisher只会从缓存中加载图片
    case onlyFromCache

    在使用之前在后台线程解码图像
    case backgroundDecode

    当从缓存检索图像时 这个成员的关联值将被用作目标队列的调度时回调。如果没 有设置, Kingfisher将使用主要quese回调
    case callbackDispatchQueue(DispatchQueue?)

    将检索到的图片数据转换成一个图时 这个成员变量将被用作图片缩放因子。图像分辨率,而不是屏幕尺寸。你可能处理时需要指定正确的缩放因子@2x或@3x Retina图像。
    case scaleFactor(CGFloat)

    是否所有的GIF应该加载数据。默认false，只显示GIF中第一张图片。如果true,所有的GIF数据将被加载到内存中进行解码。这个选项主要是用于内部的兼容性。你不应该把直接设置它。“AnimatedImageView”不会预加载所有数据,而一个正常的图像视图(“UIImageView”或“NSImageView”)将加载所有数据。选择使用相应的图像视图类型而不是设置这个选项。
    case preloadAllGIFData

    发送请求之前用于改变请求。这是最后的机会你可以修改请求。您可以修改请求一些定制的目的,如添加身份验证令牌头,进行基本的HTTP身份验证或类似的url映射。原始请求默认情况下将没有任何修改
    case requestModifier(ImageDownloadRequestModifier)

    下载完成时,处理器会将下载的数据转换为一个图像。如果缓存连接到下载器(当你正在使用KingfisherManager或图像扩展方法),转换后的图像也将被缓存
    case processor(ImageProcessor)

    提供一个CacheSerializer 可用于图像对象序列化成图像数据存储到磁盘缓存和从磁盘缓存将图片数据反序列化成图像对象
    case cacheSerializer(CacheSerializer)

    保持现有的图像同时设置另一个图像图像视图。通过设置这个选项,imageview的placeholder参数将被忽略和当前图像保持同时加载新图片
    case keepCurrentImageWhileLoading
}


//自定义<== 运算符 比较两个KingfisherOptionsInfoItem 是否相等
precedencegroup ItemComparisonPrecedence {
    associativity: none
    higherThan: LogicalConjunctionPrecedence
}

infix operator <== : ItemComparisonPrecedence
// <== 具体实现，相等返回true 否则返回false
func <== (lhs: KingfisherOptionsInfoItem, rhs: KingfisherOptionsInfoItem) -> Bool {
    switch (lhs, rhs) {
    case (.targetCache(_), .targetCache(_)): return true
    case (.downloader(_), .downloader(_)): return true
    case (.transition(_), .transition(_)): return true
    case (.downloadPriority(_), .downloadPriority(_)): return true
    case (.forceRefresh, .forceRefresh): return true
    case (.forceTransition, .forceTransition): return true
    case (.cacheMemoryOnly, .cacheMemoryOnly): return true
    case (.onlyFromCache, .onlyFromCache): return true
    case (.backgroundDecode, .backgroundDecode): return true
    case (.callbackDispatchQueue(_), .callbackDispatchQueue(_)): return true
    case (.scaleFactor(_), .scaleFactor(_)): return true
    case (.preloadAllGIFData, .preloadAllGIFData): return true
    case (.requestModifier(_), .requestModifier(_)): return true
    case (.processor(_), .processor(_)): return true
    case (.cacheSerializer(_), .cacheSerializer(_)): return true
    case (.keepCurrentImageWhileLoading, .keepCurrentImageWhileLoading): return true
    default: return false
    }
}


public extension Collection where Iterator.Element == KingfisherOptionsInfoItem {
//返回匹配的第一个相同枚举值
    func firstMatchIgnoringAssociatedValue(_ target: Iterator.Element) -> Iterator.Element? {
        return index { $0 <== target }.flatMap { self[$0] }
    }
   //移除相同的元素
    func removeAllMatchesIgnoringAssociatedValue(_ target: Iterator.Element) -> [Iterator.Element] {
        return self.filter { !($0 <== target) }
    }
}
//接下来public extension Collection where Iterator.Element == KingfisherOptionsInfoItem就是参数相关配置
//

```

#CacheSerializer

```
//Image 序列化 Data。通过Data获取图片format,返回不同格式下图片。能实现PNG，
//JPEG，GIF图片格式，其他图片格式默认返回PNG格式
 public func data(with image: Image, original: Data?) -> Data? {
        let imageFormat = original?.kf.imageFormat ?? .unknown
        
        let data: Data?
        switch imageFormat {
        case .PNG: data = image.kf.pngRepresentation()
        case .JPEG: data = image.kf.jpegRepresentation(compressionQuality: 1.0)
        case .GIF: data = image.kf.gifRepresentation()
        case .unknown: data = original ?? image.kf.normalized.kf.pngRepresentation()
        }
        
        return data
    }
  //Data 序列化成Image。 如果是GIF图片，preloadAllGIFData 用于判断图片显示方
  //式。 false： 不会加载所有GIF图片数据，只显示GIF中的第一张图片，true：将所有
  //图片数据加载到内存，显示GIF动态图片  
    public func image(with data: Data, options: KingfisherOptionsInfo?) -> Image? {
        let scale = (options ?? KingfisherEmptyOptionsInfo).scaleFactor
        let preloadAllGIFData = (options ?? KingfisherEmptyOptionsInfo).preloadAllGIFData
        
        return Kingfisher<Image>.image(data: data, scale: scale, preloadAllGIFData: preloadAllGIFData)
    }
```

#ImagePrefetcher

初始化

```
  /// The maximum concurrent downloads to use when prefetching images. Default is 5.
    public var maxConcurrentDownloads = 5
    //总的任务量
    private let prefetchResources: [Resource]
    private let optionsInfo: KingfisherOptionsInfo
    private var progressBlock: PrefetcherProgressBlock?
    private var completionHandler: PrefetcherCompletionHandler?
    
    private var tasks = [URL: RetrieveImageDownloadTask]()
    //待办的
    private var pendingResources: ArraySlice<Resource>
    //跳过的
    private var skippedResources = [Resource]()
    //完成的
    private var completedResources = [Resource]()
    //失败的
    private var failedResources = [Resource]()
    
    private var stopped = false
    
    // The created manager used for prefetch. We will use the helper method in manager.
    private let manager: KingfisherManager
    
    private var finished: Bool {
        return failedResources.count + skippedResources.count + completedResources.count == prefetchResources.count && self.tasks.isEmpty
    }
    
    /**
     Init an image prefetcher with an array of URLs.
     
     The prefetcher should be initiated with a list of prefetching targets. The URLs list is immutable. 
     After you get a valid `ImagePrefetcher` object, you could call `start()` on it to begin the prefetching process.
     The images already cached will be skipped without downloading again.
     
     - parameter urls:              The URLs which should be prefetched.
     - parameter options:           A dictionary could control some behaviors. See `KingfisherOptionsInfo` for more.
     - parameter progressBlock:     Called every time an resource is downloaded, skipped or cancelled.
     - parameter completionHandler: Called when the whole prefetching process finished.
     
     - returns: An `ImagePrefetcher` object.
     
     - Note: By default, the `ImageDownloader.defaultDownloader` and `ImageCache.defaultCache` will be used as 
     the downloader and cache target respectively. You can specify another downloader or cache by using a customized `KingfisherOptionsInfo`.
     Both the progress and completion block will be invoked in main thread. The `CallbackDispatchQueue` in `optionsInfo` will be ignored in this method.
     */
    //URL数组初始化ImagePrefetcher
    public convenience init(urls: [URL],
                         options: KingfisherOptionsInfo? = nil,
                   progressBlock: PrefetcherProgressBlock? = nil,
               completionHandler: PrefetcherCompletionHandler? = nil)
    {
        let resources: [Resource] = urls.map { $0 }
        self.init(resources: resources, options: options, progressBlock: progressBlock, completionHandler: completionHandler)
    }
    
    /**
     Init an image prefetcher with an array of resources.
     
     The prefetcher should be initiated with a list of prefetching targets. The resources list is immutable.
     After you get a valid `ImagePrefetcher` object, you could call `start()` on it to begin the prefetching process.
     The images already cached will be skipped without downloading again.
     
     - parameter resources:         The resources which should be prefetched. See `Resource` type for more.
     - parameter options:           A dictionary could control some behaviors. See `KingfisherOptionsInfo` for more.
     - parameter progressBlock:     Called every time an resource is downloaded, skipped or cancelled.
     - parameter completionHandler: Called when the whole prefetching process finished.
     
     - returns: An `ImagePrefetcher` object.
     
     - Note: By default, the `ImageDownloader.defaultDownloader` and `ImageCache.defaultCache` will be used as
     the downloader and cache target respectively. You can specify another downloader or cache by using a customized `KingfisherOptionsInfo`.
     Both the progress and completion block will be invoked in main thread. The `CallbackDispatchQueue` in `optionsInfo` will be ignored in this method.
     */
    public init(resources: [Resource],
                  options: KingfisherOptionsInfo? = nil,
            progressBlock: PrefetcherProgressBlock? = nil,
        completionHandler: PrefetcherCompletionHandler? = nil)
    {
        prefetchResources = resources
        pendingResources = ArraySlice(resources)
        
        // We want all callbacks from main queue, so we ignore the call back queue in options
        let optionsInfoWithoutQueue = options?.removeAllMatchesIgnoringAssociatedValue(.callbackDispatchQueue(nil))
        self.optionsInfo = optionsInfoWithoutQueue ?? KingfisherEmptyOptionsInfo
        
        let cache = self.optionsInfo.targetCache
        let downloader = self.optionsInfo.downloader
        manager = KingfisherManager(downloader: downloader, cache: cache)
        
        self.progressBlock = progressBlock
        self.completionHandler = completionHandler
    }
```

开始下载和停止

```
    /**
     Start to download the resources and cache them. This can be useful for background downloading
     of assets that are required for later use in an app. This code will not try and update any UI
     with the results of the process.
     */
    public func start()
    {
        // Since we want to handle the resources cancellation in main thread only.
        DispatchQueue.main.safeAsync {
            
            guard !self.stopped else {
                assertionFailure("You can not restart the same prefetcher. Try to create a new prefetcher.")
                self.handleComplete()
                return
            }
            
            guard self.maxConcurrentDownloads > 0 else {
                assertionFailure("There should be concurrent downloads value should be at least 1.")
                self.handleComplete()
                return
            }
            
            guard self.prefetchResources.count > 0 else {
                self.handleComplete()
                return
            }
            //最大不超过maxConcurrentDownloads（默认5）
            let initialConcurentDownloads = min(self.prefetchResources.count, self.maxConcurrentDownloads)
            for _ in 0 ..< initialConcurentDownloads {
                if let resource = self.pendingResources.popFirst() {
                    self.startPrefetching(resource)
                }
            }
        }
    }

   
    /**
     Stop current downloading progress, and cancel any future prefetching activity that might be occuring.
     */
    public func stop() {
        DispatchQueue.main.safeAsync {
            
            if self.finished { return }
            
            self.stopped = true
            self.tasks.forEach { (_, task) -> () in
                task.cancel()
            }
        }
    }
    //下载并缓存
    func downloadAndCache(_ resource: Resource) {

        let downloadTaskCompletionHandler: CompletionHandler = { (image, error, _, _) -> () in
            //完成后移除
            self.tasks.removeValue(forKey: resource.downloadURL)
            if let _ = error {
                self.failedResources.append(resource)
            } else {
                self.completedResources.append(resource)
            }
            //总量下载进度
            self.reportProgress()
            if self.stopped {
                if self.tasks.isEmpty {
                    self.failedResources.append(contentsOf: self.pendingResources)
                    self.handleComplete()
                }
            } else {
                self.reportCompletionOrStartNext()
            }
        }
        //交给manager。manager再交给ImageDownloader完成下载，iamgeCache完成缓存
        let downloadTask = manager.downloadAndCacheImage(
            with: resource.downloadURL,
            forKey: resource.cacheKey,
            retrieveImageTask: RetrieveImageTask(),
            progressBlock: nil,
            completionHandler: downloadTaskCompletionHandler,
            options: optionsInfo)
        
        if let downloadTask = downloadTask {
           // 构建下载任务字典
            tasks[resource.downloadURL] = downloadTask
        }
    }
    
    func append(cached resource: Resource) {
        //内存已存在的直接添加的跳过的URL里
        skippedResources.append(resource)
 
        reportProgress()
        reportCompletionOrStartNext()
    }
    //开始下载
    func startPrefetching(_ resource: Resource)
    {
        //always downloaded again
        if optionsInfo.forceRefresh {
            downloadAndCache(resource)
        } else {//如果不是要求必须重新下载
            //检查内存是否已存在
            let alreadyInCache = manager.cache.isImageCached(forKey: resource.cacheKey,
                                                             processorIdentifier: optionsInfo.processor.identifier).cached

            if alreadyInCache {
                append(cached: resource)
            } else {
                downloadAndCache(resource)
            }
        }
    }
    //下载进度
    func reportProgress() {
        progressBlock?(skippedResources, failedResources, completedResources)
    }
    //完成或者进行下一个
    func reportCompletionOrStartNext() {
        if let resource = pendingResources.popFirst() {
            startPrefetching(resource)
        } else {
            guard tasks.isEmpty else { return }
            handleComplete()
        }
    }
    
    func handleComplete() {
        completionHandler?(skippedResources, failedResources, completedResources)
        completionHandler = nil
        progressBlock = nil
    }
```