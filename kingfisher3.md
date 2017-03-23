#ImageCache

相关属性

```
//Memory
    fileprivate let memoryCache = NSCache<NSString, AnyObject>()
    ///最大内存缓存，默认不限
    open var maxMemoryCost: UInt = 0 {
        didSet {
            self.memoryCache.totalCostLimit = Int(maxMemoryCost)
        }
    }
    
    //Disk
    //ioQueue:dispatch_queue_t 为单独的硬盘操作队列，由于硬盘存取操作极为耗时，使其与主线程并行执行以免造成阻塞。
    fileprivate let ioQueue: DispatchQueue
    //文件管理
    fileprivate var fileManager: FileManager!
    
    ///The disk cache location.
    //路径
    open let diskCachePath: String
  
    /// The default file extension appended to cached files.
    open var pathExtension: String?
    
    /// The longest time duration in second of the cache being stored in disk. 
    /// Default is 1 week (60 * 60 * 24 * 7 seconds).
    /// Setting this to a negative value will make the disk cache never expiring.
    //默认最长存储时间
    open var maxCachePeriodInSecond: TimeInterval = 60 * 60 * 24 * 7 //Cache exists for 1 week
    
    /// The largest disk size can be taken for the cache. It is the total 
    /// allocated size of cached files in bytes.
    /// Default is no limit.
    open var maxDiskCacheSize: UInt = 0
    //执行图片的 decode 操作
    fileprivate let processQueue: DispatchQueue
    
    /// The default cache.单例
    public static let `default` = ImageCache(name: "default")
```

图片的存取与移除

```
    // MARK: - Store & Remove

    /**
    Store an image to cache. It will be saved to both memory and disk. It is an async operation.
    
    - parameter image:             The image to be stored.
    - parameter original:          The original data of the image.
                                   Kingfisher will use it to check the format of the image and optimize cache size on disk.
                                   If `nil` is supplied, the image data will be saved as a normalized PNG file.
                                   It is strongly suggested to supply it whenever possible, to get a better performance and disk usage.
    - parameter key:               Key for the image.
    - parameter identifier:        The identifier of processor used. If you are using a processor for the image, pass the identifier of
                                   processor to it.
                                   This identifier will be used to generate a corresponding key for the combination of `key` and processor.
    - parameter toDisk:            Whether this image should be cached to disk or not. If false, the image will be only cached in memory.
    - parameter completionHandler: Called when store operation completes.
    */
    open func store(_ image: Image,
                      original: Data? = nil,
                      forKey key: String,
                      processorIdentifier identifier: String = "",
                      cacheSerializer serializer: CacheSerializer = DefaultCacheSerializer.default,
                      toDisk: Bool = true,
                      completionHandler: (() -> Void)? = nil)
    {
        //内存缓存
        let computedKey = key.computedKey(with: identifier)
        memoryCache.setObject(image, forKey: computedKey as NSString, cost: image.kf.imageCost)

        func callHandlerInMainQueue() {
            if let handler = completionHandler {
                DispatchQueue.main.async {
                    handler()
                }
            }
        }
        
        if toDisk {
            ioQueue.async {
                if let data = serializer.data(with: image, original: original) {
                    //不存在 self.diskCachePath文件，即创建
                    if !self.fileManager.fileExists(atPath: self.diskCachePath) {
                        do {
        
                            try self.fileManager.createDirectory(atPath: self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
                        } catch _ {}
                    }
                    
                    self.fileManager.createFile(atPath: self.cachePath(forComputedKey: computedKey), contents: data, attributes: nil)
                }
                callHandlerInMainQueue()
            }
        } else {
            callHandlerInMainQueue()
        }
    }
    
    
        open func removeImage(forKey key: String,
                          processorIdentifier identifier: String = "",
                          fromDisk: Bool = true,
                          completionHandler: (() -> Void)? = nil)
    {
        let computedKey = key.computedKey(with: identifier)
        memoryCache.removeObject(forKey: computedKey as NSString)
        
        func callHandlerInMainQueue() {
            if let handler = completionHandler {
                DispatchQueue.main.async {
                    handler()
                }
            }
        }
        
        if fromDisk {
            ioQueue.async{
                do {
                    try self.fileManager.removeItem(atPath: self.cachePath(forComputedKey: computedKey))
                } catch _ {}
                callHandlerInMainQueue()
            }
        } else {
            callHandlerInMainQueue()
        }
    }

```

从内存或磁盘中获取image

```
   open func retrieveImage(forKey key: String,
                               options: KingfisherOptionsInfo?,
                     completionHandler: ((Image?, CacheType) -> ())?) -> RetrieveImageDiskTask?
    {
        // No completion handler. Not start working and early return.
        guard let completionHandler = completionHandler else {
            return nil
        }
        //类似于dispatch_block_t
        var block: RetrieveImageDiskTask?
        let options = options ?? KingfisherEmptyOptionsInfo
        
        if let image = self.retrieveImageInMemoryCache(forKey: key, options: options) {
            options.callbackDispatchQueue.safeAsync {
                completionHandler(image, .memory)
            }
        } else {
            var sSelf: ImageCache! = self
            block = DispatchWorkItem(block: {
                // Begin to load image from disk
                if let image = sSelf.retrieveImageInDiskCache(forKey: key, options: options) {
                    //获取到image
                    if options.backgroundDecode {
                        sSelf.processQueue.async {
                            let result = image.kf.decoded(scale: options.scaleFactor)
                            
                            sSelf.store(result,
                                        forKey: key,
                                        processorIdentifier: options.processor.identifier,
                                        cacheSerializer: options.cacheSerializer,
                                        toDisk: false,
                                        completionHandler: nil)
                            
                            options.callbackDispatchQueue.safeAsync {
                                completionHandler(result, .memory)
                                sSelf = nil
                            }
                        }
                    } else {
                        sSelf.store(image,
                                    forKey: key,
                                    processorIdentifier: options.processor.identifier,
                                    cacheSerializer: options.cacheSerializer,
                                    toDisk: false,
                                    completionHandler: nil
                        )
                        options.callbackDispatchQueue.safeAsync {
                            completionHandler(image, .disk)
                            sSelf = nil
                        }
                    }
                } else {
                    // No image found from either memory or disk
                    options.callbackDispatchQueue.safeAsync {
                        completionHandler(nil, .none)
                        sSelf = nil
                    }
                }
            })
            
            sSelf.ioQueue.async(execute: block!)
        }
    
        return block
    }
```

清除磁盘缓存

```
    open func clearDiskCache(completion handler: (()->())? = nil) {
        ioQueue.async {
            do {
                try self.fileManager.removeItem(atPath: self.diskCachePath)
                try self.fileManager.createDirectory(atPath: self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
            } catch _ { }
            
            if let handler = handler {
                DispatchQueue.main.async {
                    handler()
                }
            }
        }
    }
    
```

清楚过期或者超出存储范围的缓存files

```
    /**
    Clean expired disk cache. This is an async operation.//清除过期磁盘上信息
    */
    @objc fileprivate func cleanExpiredDiskCache() {
        cleanExpiredDiskCache(completion: nil)
    }
    
    /**
    Clean expired disk cache. This is an async operation.
    
    - parameter completionHandler: Called after the operation completes.
    */
    open func cleanExpiredDiskCache(completion handler: (()->())? = nil) {
        
        // Do things in cocurrent io queue
        ioQueue.async {
            // 拿到过期需要删除的urlsToDelete数组，diskCacheSize磁盘缓存大小和cachedFiles字典
            var (URLsToDelete, diskCacheSize, cachedFiles) = self.travelCachedFiles(onlyForCacheSize: false)
            
            for fileURL in URLsToDelete {
                do {
                    try self.fileManager.removeItem(at: fileURL)
                } catch _ { }
            }
            // 磁盘缓存大小超过自定义最大缓存
            if self.maxDiskCacheSize > 0 && diskCacheSize > self.maxDiskCacheSize {
                //计划清除到最大缓存的一半
                let targetSize = self.maxDiskCacheSize / 2
                    
                // Sort files by last modify date. We want to clean from the oldest files.
                //清除最老未改变的files
                //降序
                let sortedFiles = cachedFiles.keysSortedByValue {
                    resourceValue1, resourceValue2 -> Bool in
                    
                    if let date1 = resourceValue1.contentAccessDate,
                       let date2 = resourceValue2.contentAccessDate
                    {
                        return date1.compare(date2) == .orderedAscending
                    }
                    
                    // Not valid date information. This should not happen. Just in case.
                    return true
                }
                //删除files直到小于最大缓存的一半结束
                for fileURL in sortedFiles {
                    
                    do {
                        try self.fileManager.removeItem(at: fileURL)
                    } catch { }
                        
                    URLsToDelete.append(fileURL)
                    
                    if let fileSize = cachedFiles[fileURL]?.totalFileAllocatedSize {
                        diskCacheSize -= UInt(fileSize)
                    }
                    
                    if diskCacheSize < targetSize {
                        break
                    }
                }
            }
                
            DispatchQueue.main.async {
                
                if URLsToDelete.count != 0 {
                    let cleanedHashes = URLsToDelete.map { $0.lastPathComponent }
                    NotificationCenter.default.post(name: .KingfisherDidCleanDiskCache, object: self, userInfo: [KingfisherDiskCacheCleanedHashKey: cleanedHashes])
                }
                
                handler?()
            }
        }
    }
    //获取过期的URL数组，磁盘缓存大小和缓存文件字典, 进行缓存删除操作。 通过FileManager的enumerator方法遍历出所有缓存文件，如果文件最后一次访问日期比当前时间减去一周时间还要早，将该文件fileUrl添加到urlsToDelete数组。计算缓存文件大小，以fileUrl为key，resourceValues为value,存入 cachedFiles
    fileprivate func travelCachedFiles(onlyForCacheSize: Bool) -> (urlsToDelete: [URL], diskCacheSize: UInt, cachedFiles: [URL: URLResourceValues]) {
        
        let diskCacheURL = URL(fileURLWithPath: diskCachePath)
        let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey, .contentAccessDateKey, .totalFileAllocatedSizeKey]
        //过期日期
        let expiredDate: Date? = (maxCachePeriodInSecond < 0) ? nil : Date(timeIntervalSinceNow: -maxCachePeriodInSecond)
        //// 缓存字典 URL : ResourceValue
        var cachedFiles = [URL: URLResourceValues]()
        var urlsToDelete = [URL]()
        var diskCacheSize: UInt = 0

        for fileUrl in (try? fileManager.contentsOfDirectory(at: diskCacheURL, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)) ?? [] {

            do {
                let resourceValues = try fileUrl.resourceValues(forKeys: resourceKeys)
                // If it is a Directory. Continue to next file URL.
                if resourceValues.isDirectory == true {
                    continue
                }

                // If this file is expired, add it to URLsToDelete
                if !onlyForCacheSize,
                    let expiredDate = expiredDate,
                    let lastAccessData = resourceValues.contentAccessDate,
                    (lastAccessData as NSDate).laterDate(expiredDate) == expiredDate
                {
                    ////添加过期URL到删除数组
                    urlsToDelete.append(fileUrl)
                    continue
                }

                if let fileSize = resourceValues.totalFileAllocatedSize {
                    //
                    diskCacheSize += UInt(fileSize)
                    if !onlyForCacheSize {
                        //构建字典
                        cachedFiles[fileUrl] = resourceValues
                    }
                }
            } catch _ { }
        }

        return (urlsToDelete, diskCacheSize, cachedFiles)
    }
```

#imageDownloader

```
    //作用ImageDownloader往往要处理多个URL的下载任务，它的fetchLoads属性是一个[URL: ImageFetchLoad]类型的字典，存储不同 URL 及其 ImageFetchLoad 之间的对应关系
    class ImageFetchLoad {
        //嵌套包含进度和完成回调
        var contents = [(callback: CallbackPair, options: KingfisherOptionsInfo)]()
        //数据存储
        var responseData = NSMutableData()

        var downloadTaskCount = 0
        var downloadTask: RetrieveImageDownloadTask?
    }
    
       //根据URL获取ImageFetchLoad 的方法
    func fetchLoad(for url: URL) -> ImageFetchLoad? {
        var fetchLoad: ImageFetchLoad?
        barrierQueue.sync { fetchLoad = fetchLoads[url] }
        return fetchLoad
    }
    
```
这是外部调用ImageDownloader最常用的方法 配置好请求参数：Time 、URL、 URLRequest ，确保请求的前提条件 主要是setup方法

```
    func downloadImage(with url: URL,
              retrieveImageTask: RetrieveImageTask?,
                        options: KingfisherOptionsInfo?,
                  progressBlock: ImageDownloaderProgressBlock?,
              completionHandler: ImageDownloaderCompletionHandler?) -> RetrieveImageDownloadTask?
    {
        if let retrieveImageTask = retrieveImageTask, retrieveImageTask.cancelledBeforeDownloadStarting {
            completionHandler?(nil, NSError(domain: KingfisherErrorDomain, code: KingfisherError.downloadCancelledBeforeStarting.rawValue, userInfo: nil), nil, nil)
            return nil
        }
        
        let timeout = self.downloadTimeout == 0.0 ? 15.0 : self.downloadTimeout
        
        // We need to set the URL as the load key. So before setup progress, we need to ask the `requestModifier` for a final URL.
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeout)
        request.httpShouldUsePipelining = requestsUsePipeling

        if let modifier = options?.modifier {
            guard let r = modifier.modified(for: request) else {
                completionHandler?(nil, NSError(domain: KingfisherErrorDomain, code: KingfisherError.downloadCancelledBeforeStarting.rawValue, userInfo: nil), nil, nil)
                return nil
            }
            request = r
        }
        
        // There is a possiblility that request modifier changed the url to `nil` or empty.
        guard let url = request.url, !url.absoluteString.isEmpty else {
            completionHandler?(nil, NSError(domain: KingfisherErrorDomain, code: KingfisherError.invalidURL.rawValue, userInfo: nil), nil, nil)
            return nil
        }
        
        var downloadTask: RetrieveImageDownloadTask?
        ////根据传过来的fetchLoad 是否开启下载任务。若没有根据session 生成 dataTask,在进一步包装成RetrieveImageDownloadTask，传给fetchLoad的downloadTask属性 配置好任务优先级，开启下载任务，如果已开启下载，下载次数加1，设置传给外部的retrieveImageTask的downloadTask
        setup(progressBlock: progressBlock, with: completionHandler, for: url, options: options) {(session, fetchLoad) -> Void in
            if fetchLoad.downloadTask == nil {
                let dataTask = session.dataTask(with: request)
                ////设置下载任务
                fetchLoad.downloadTask = RetrieveImageDownloadTask(internalTask: dataTask, ownerDownloader: self)
                 //设置下载任务优先级
                dataTask.priority = options?.downloadPriority ?? URLSessionTask.defaultPriority
                ////开启下载任务
                dataTask.resume()
                
                // Hold self while the task is executing.
                //下载期间确保sessionHandler 持有 ImageDownloader
                self.sessionHandler.downloadHolder = self
            }
            //下载次数加1
            fetchLoad.downloadTaskCount += 1
            downloadTask = fetchLoad.downloadTask
            
            retrieveImageTask?.downloadTask = downloadTask
        }
        return downloadTask
    }
    
        func setup(progressBlock: ImageDownloaderProgressBlock?, with completionHandler: ImageDownloaderCompletionHandler?, for url: URL, options: KingfisherOptionsInfo?, started: ((URLSession, ImageFetchLoad) -> Void)) {
        //首先barrierQueue.sync 确保ImageFetchLoad 读写安全，根据传入的URL获取对应的ImageFetchLoad 设置callbackPair并更新contents ，开启下载
        barrierQueue.sync(flags: .barrier) {
            let loadObjectForURL = fetchLoads[url] ?? ImageFetchLoad()
            let callbackPair = (progressBlock: progressBlock, completionHandler: completionHandler)
            
            loadObjectForURL.contents.append((callbackPair, options ?? KingfisherEmptyOptionsInfo))
            
            fetchLoads[url] = loadObjectForURL
            
            if let session = session {
                started(session, loadObjectForURL)
            }
        }
    }
```

取消下载

```
    func cancelDownloadingTask(_ task: RetrieveImageDownloadTask) {
        barrierQueue.sync {
            if let URL = task.internalTask.originalRequest?.url, let imageFetchLoad = self.fetchLoads[URL] {
                //更新下载次数
                imageFetchLoad.downloadTaskCount -= 1
                if imageFetchLoad.downloadTaskCount == 0 {
                    task.internalTask.cancel()
                }
            }
        }
    }
    
```

NSURLSessionDataDelegate,下载生命周期操作

```
    //下载过程中接收Response
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        ////下载过程中确保ImageDownloader 一直持有
        guard let downloader = downloadHolder else {
            completionHandler(.cancel)
            return
        }
        ////返回状态码判断
        if let statusCode = (response as? HTTPURLResponse)?.statusCode,
           let url = dataTask.originalRequest?.url,
            !(downloader.delegate ?? downloader).isValidStatusCode(statusCode, for: downloader)
        {
            let error = NSError(domain: KingfisherErrorDomain,
                                code: KingfisherError.invalidStatusCode.rawValue,
                                userInfo: [KingfisherErrorStatusCodeKey: statusCode, NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: statusCode)])
            ////返回错误 首先清除ImageFetchLoad
            callCompletionHandlerFailure(error: error, url: url)
        }
        ////继续请求数据
        completionHandler(.allow)
    }
    //下载过程中接收到数据
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {

        guard let downloader = downloadHolder else {
            return
        }
        //添加数据到指定ImageFetchLoad
        if let url = dataTask.originalRequest?.url, let fetchLoad = downloader.fetchLoad(for: url) {
            fetchLoad.responseData.append(data)
            //下载进度回调
            if let expectedLength = dataTask.response?.expectedContentLength {
                for content in fetchLoad.contents {
                    DispatchQueue.main.async {
                        content.callback.progressBlock?(Int64(fetchLoad.responseData.length), expectedLength)
                    }
                }
            }
        }
    }
    //下载结束
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        //// URL 一致性判断
        guard let url = task.originalRequest?.url else {
            return
        }
        // error 判断
        guard error == nil else {
            callCompletionHandlerFailure(error: error!, url: url)
            return
        }
        //图片处理
        processImage(for: task, url: url)
    }
    
    /**
    This method is exposed since the compiler requests. Do not call it.
    */
    //会话需要认证
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let downloader = downloadHolder else {
            return
        }
        
        downloader.authenticationChallengeResponder?.downloader(downloader, didReceive: challenge, completionHandler: completionHandler)
    }
    
    private func cleanFetchLoad(for url: URL) {
        guard let downloader = downloadHolder else {
            return
        }
        
        downloader.clean(for: url)
        
        if downloader.fetchLoads.isEmpty {
            downloadHolder = nil
        }
    }
    //返回错误信息
    private func callCompletionHandlerFailure(error: Error, url: URL) {
        guard let downloader = downloadHolder, let fetchLoad = downloader.fetchLoad(for: url) else {
            return
        }
        
        // We need to clean the fetch load first, before actually calling completion handler.
        cleanFetchLoad(for: url)
        
        for content in fetchLoad.contents {
            content.options.callbackDispatchQueue.safeAsync {
                content.callback.completionHandler?(nil, error as NSError, url, nil)
            }
        }
    }
```

图片数据处理

```
    private func processImage(for task: URLSessionTask, url: URL) {

        guard let downloader = downloadHolder else {
            return
        }
        
        // We are on main queue when receiving this.
        downloader.processQueue.async {
            
            guard let fetchLoad = downloader.fetchLoad(for: url) else {
                return
            }
            //首先清除ImageDownloader
            self.cleanFetchLoad(for: url)
            
            let data = fetchLoad.responseData as Data
            
            // Cache the processed images. So we do not need to re-process the image if using the same processor.
            // Key is the identifier of processor.
            var imageCache: [String: Image] = [:]
            for content in fetchLoad.contents {
                
                let options = content.options
                let completionHandler = content.callback.completionHandler
                let callbackQueue = options.callbackDispatchQueue
                
                let processor = options.processor
                
                var image = imageCache[processor.identifier]
                if image == nil {
                    //合成图片
                    image = processor.process(item: .data(data), options: options)
                    
                    // Add the processed image to cache. 
                    // If `image` is nil, nothing will happen (since the key is not existing before).
                    imageCache[processor.identifier] = image
                }
                
                if let image = image {
                    
                    downloader.delegate?.imageDownloader(downloader, didDownload: image, for: url, with: task.response)
                    //后台编码
                    if options.backgroundDecode {
                        let decodedImage = image.kf.decoded(scale: options.scaleFactor)
                        callbackQueue.safeAsync { completionHandler?(decodedImage, nil, url, data) }
                    } else {
                        callbackQueue.safeAsync { completionHandler?(image, nil, url, data) }
                    }
                    
                } else {
                     // 304 状态码 没有图像数据下载
                    if let res = task.response as? HTTPURLResponse , res.statusCode == 304 {
                        let notModified = NSError(domain: KingfisherErrorDomain, code: KingfisherError.notModified.rawValue, userInfo: nil)
                        completionHandler?(nil, notModified, url, nil)
                        continue
                    }
                     //返回不是图片数据 或者数据被破坏
                    let badData = NSError(domain: KingfisherErrorDomain, code: KingfisherError.badData.rawValue, userInfo: nil)
                    callbackQueue.safeAsync { completionHandler?(nil, badData, url, nil) }
                }
            }
        }
    }
}
```