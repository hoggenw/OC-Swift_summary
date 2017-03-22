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