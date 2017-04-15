# KingfisherManager

```
    /// Shared manager used by the extensions across Kingfisher.
    public static let shared = KingfisherManager()
    
    /// Cache used by this manager
    //图片缓存配置
    public var cache: ImageCache
    
    /// Downloader used by this manager
    //图片下载配置
    public var downloader: ImageDownloader
```
对外接口

```
    @discardableResult
    //获取缓存图片
    public func retrieveImage(with resource: Resource,
        options: KingfisherOptionsInfo?,
        progressBlock: DownloadProgressBlock?,
        completionHandler: CompletionHandler?) -> RetrieveImageTask
    {
        let task = RetrieveImageTask()
        //强制刷新 从网络获取图片
        if let options = options, options.forceRefresh {
            _ = downloadAndCacheImage(
                with: resource.downloadURL,
                forKey: resource.cacheKey,
                retrieveImageTask: task,
                progressBlock: progressBlock,
                completionHandler: completionHandler,
                options: options)
        } else {
            //从本地取图片
            tryToRetrieveImageFromCache(
                forKey: resource.cacheKey,
                with: resource.downloadURL,
                retrieveImageTask: task,
                progressBlock: progressBlock,
                completionHandler: completionHandler,
                options: options)
        }
        
        return task
    }

```

下载并缓存

```
  @discardableResult
    //下载并且缓存图片
    func downloadAndCacheImage(with url: URL,
                             forKey key: String,
                      retrieveImageTask: RetrieveImageTask,
                          progressBlock: DownloadProgressBlock?,
                      completionHandler: CompletionHandler?,
                                options: KingfisherOptionsInfo?) -> RetrieveImageDownloadTask?
    {
        //获取下载器 并开启下载
        let options = options ?? KingfisherEmptyOptionsInfo
        let downloader = options.downloader
        return downloader.downloadImage(with: url, retrieveImageTask: retrieveImageTask, options: options,
            progressBlock: { receivedSize, totalSize in
                progressBlock?(receivedSize, totalSize)
            },
            completionHandler: { image, error, imageURL, originalData in

                let targetCache = options.targetCache
                if let error = error, error.code == KingfisherError.notModified.rawValue {
                    // Not modified. Try to find the image from cache.
                    // (The image should be in cache. It should be guaranteed by the framework users.)
                    //如果有错误并且没有修改过URL 返回缓存图片
                    targetCache.retrieveImage(forKey: key, options: options, completionHandler: { (cacheImage, cacheType) -> () in
                        completionHandler?(cacheImage, nil, cacheType, url)
                    })
                    return
                }
                //图片存入本地
                if let image = image, let originalData = originalData {
                    targetCache.store(image,
                                      original: originalData,
                                      forKey: key,
                                      processorIdentifier:options.processor.identifier,
                                      cacheSerializer: options.cacheSerializer,
                                      toDisk: !options.cacheMemoryOnly,
                                      completionHandler: nil)
                }

                completionHandler?(image, error, .none, url)

            })
    }
```

从本地取，失败后下载

```
 func tryToRetrieveImageFromCache(forKey key: String,
                                       with url: URL,
                              retrieveImageTask: RetrieveImageTask,
                                  progressBlock: DownloadProgressBlock?,
                              completionHandler: CompletionHandler?,
                                        options: KingfisherOptionsInfo?)
    {
        let diskTaskCompletionHandler: CompletionHandler = { (image, error, cacheType, imageURL) -> () in
            completionHandler?(image, error, cacheType, imageURL)
        }
        
        let targetCache = options?.targetCache ?? cache
        targetCache.retrieveImage(forKey: key, options: options,
            completionHandler: { image, cacheType in
                if image != nil {
                    //成功
                    diskTaskCompletionHandler(image, nil, cacheType, url)
                } else if let options = options, options.onlyFromCache {
                    //失败，但设定只从本地取
                    let error = NSError(domain: KingfisherErrorDomain, code: KingfisherError.notCached.rawValue, userInfo: nil)
                    diskTaskCompletionHandler(nil, error, .none, url)
                } else {
                    //失败，从网络获取
                    self.downloadAndCacheImage(
                        with: url,
                        forKey: key,
                        retrieveImageTask: retrieveImageTask,
                        progressBlock: progressBlock,
                        completionHandler: diskTaskCompletionHandler,
                        options: options)
                }
            }
        )
    }
```

#ImageView+Kingfisher

加载图片

```
    @discardableResult
    public func setImage(with resource: Resource?,
                         placeholder: Image? = nil,
                         options: KingfisherOptionsInfo? = nil,
                         progressBlock: DownloadProgressBlock? = nil,
                         completionHandler: CompletionHandler? = nil) -> RetrieveImageTask
    {
        guard let resource = resource else {
            base.image = placeholder
            setWebURL(nil)
            completionHandler?(nil, nil, .none, nil)
            return .empty
        }
        
        var options = options ?? KingfisherEmptyOptionsInfo
        //图片加载过程中是否显示placeholder
        if !options.keepCurrentImageWhileLoading {
            base.image = placeholder
        }
        //加载动画存在即开启
        let maybeIndicator = indicator
        maybeIndicator?.startAnimatingView()
        //关联下载链接
        setWebURL(resource.downloadURL)

        // 默认开启加载所有GIF图片数据，显示GIF 动态图片
        if base.shouldPreloadAllGIF() {
            options.append(.preloadAllGIFData)
        }
        //调用KingfisherManager来获取图片
        let task = KingfisherManager.shared.retrieveImage(
            with: resource,
            options: options,
            progressBlock: { receivedSize, totalSize in
                guard resource.downloadURL == self.webURL else {
                    return
                }
                if let progressBlock = progressBlock {
                    //下载进度
                    progressBlock(receivedSize, totalSize)
                }
            },
            completionHandler: {[weak base] image, error, cacheType, imageURL in
                DispatchQueue.main.safeAsync {
                    guard let strongBase = base, imageURL == self.webURL else {
                        return
                    }
                    self.setImageTask(nil)
                    guard let image = image else {
                        maybeIndicator?.stopAnimatingView()
                        completionHandler?(nil, error, cacheType, imageURL)
                        return
                    }
                    //动画条件判断
                    guard let transitionItem = options.firstMatchIgnoringAssociatedValue(.transition(.none)),
                        case .transition(let transition) = transitionItem, ( options.forceTransition || cacheType == .none) else
                    {
                        maybeIndicator?.stopAnimatingView()
                        strongBase.image = image
                        completionHandler?(image, error, cacheType, imageURL)
                        return
                    }
                    //过渡动画
                    #if !os(macOS)
                        UIView.transition(with: strongBase, duration: 0.0, options: [],
                                          animations: { maybeIndicator?.stopAnimatingView() },
                                          completion: { _ in
                                            UIView.transition(with: strongBase, duration: transition.duration,
                                                              options: [transition.animationOptions, .allowUserInteraction],
                                                              animations: {
                                                                // Set image property in the animation.
                                                                transition.animations?(strongBase, image)
                                                              },
                                                              completion: { finished in
                                                                transition.completion?(finished)
                                                                completionHandler?(image, error, cacheType, imageURL)
                                                              })
                                          })
                    #endif
                }
            })
        
        setImageTask(task)
        
        return task
    }
```


加载动画实现

```
// MARK: - Associated Object
private var lastURLKey: Void?
private var indicatorKey: Void?
private var indicatorTypeKey: Void?
private var imageTaskKey: Void?
//加载动画视图实现
extension Kingfisher where Base: ImageView {
    /// Get the image URL binded to this image view.
    public var webURL: URL? {
        return objc_getAssociatedObject(base, &lastURLKey) as? URL
    }
    
    fileprivate func setWebURL(_ url: URL?) {
        objc_setAssociatedObject(base, &lastURLKey, url, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// Holds which indicator type is going to be used.
    /// Default is .none, means no indicator will be shown.
    public var indicatorType: IndicatorType {
        get {
            let indicator = (objc_getAssociatedObject(base, &indicatorTypeKey) as? Box<IndicatorType?>)?.value
            return indicator ?? .none
        }
        
        set {
            switch newValue {
            case .none:
                indicator = nil
            case .activity:
                indicator = ActivityIndicator()
            case .image(let data):
                indicator = ImageIndicator(imageData: data)
            case .custom(let anIndicator):
                indicator = anIndicator
            }
            
            objc_setAssociatedObject(base, &indicatorTypeKey, Box(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public fileprivate(set) var indicator: Indicator? {
        get {
            return (objc_getAssociatedObject(base, &indicatorKey) as? Box<Indicator?>)?.value
        }
        
        set {
            // Remove previous
            if let previousIndicator = indicator {
                previousIndicator.view.removeFromSuperview()
            }
            
            // Add new
            if var newIndicator = newValue {
                newIndicator.view.frame = base.frame
                newIndicator.viewCenter = CGPoint(x: base.bounds.midX, y: base.bounds.midY)
                newIndicator.view.isHidden = true
                base.addSubview(newIndicator.view)
            }
            
            // Save in associated object
            objc_setAssociatedObject(base, &indicatorKey, Box(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var imageTask: RetrieveImageTask? {
        return objc_getAssociatedObject(base, &imageTaskKey) as? RetrieveImageTask
    }
    
    fileprivate func setImageTask(_ task: RetrieveImageTask?) {
        objc_setAssociatedObject(base, &imageTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

```


