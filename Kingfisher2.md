#image
关联或者别名新属性

```
// MARK: - Image Properties
extension Kingfisher where Base: Image {
    //动态添加一个animatedImageData属性
    fileprivate(set) var animatedImageData: Data? {
        get {
            return objc_getAssociatedObject(base, &animatedImageDataKey) as? Data
        }
        set {
            //OBJC_ASSOCIATION_RETAIN_NONATOMIC,强引用关联且非原子操作
            objc_setAssociatedObject(base, &animatedImageDataKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var cgImage: CGImage? {
        return base.cgImage
    }
    
    var scale: CGFloat {
        return base.scale
    }
    
    var images: [Image]? {
        return base.images
    }
    
    var duration: TimeInterval {
        return base.duration
    }
    
    fileprivate(set) var imageSource: ImageSource? {
        get {
            return objc_getAssociatedObject(base, &imageSourceKey) as? ImageSource
        }
        set {
            objc_setAssociatedObject(base, &imageSourceKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var size: CGSize {
        return base.size
    }
   
}
```
重新绘制Kingfisher中定义的unknow的image

```  
public var normalized: Image {
        // prevent animated image (GIF) lose it's images
        guard images == nil else { return base }
        // No need to do anything if already up
        guard base.imageOrientation != .up else { return base }
    
        return draw(cgImage: nil, to: size) {
            base.draw(in: CGRect(origin: CGPoint.zero, size: size))
        }
    }
    
```
image中data与image的相互转化

```
// MARK: - Image Representation
extension Kingfisher where Base: Image {
    // MARK: - PNG
    public func pngRepresentation() -> Data? {
            //转换PNG格式image为data
            return UIImagePNGRepresentation(base)
    }
    
    // MARK: - JPEG
    public func jpegRepresentation(compressionQuality: CGFloat) -> Data? {
            //转换JPEG格式image为data,compressionQuality为压缩比例
            return UIImageJPEGRepresentation(base, compressionQuality)
    }
    
    // MARK: - GIF
    public func gifRepresentation() -> Data? {
        return animatedImageData
    }
}

    static func image(data: Data, scale: CGFloat, preloadAllGIFData: Bool, onlyFirstFrame: Bool) -> Image? {
        var image: Image?
            switch data.kf.imageFormat {
            case .JPEG:
                image = Image(data: data, scale: scale)
            case .PNG:
                image = Image(data: data, scale: scale)
            case .GIF:
                image = Kingfisher<Image>.animated(
                    with: data,
                    scale: scale,
                    duration: 0.0,
                    preloadAll: preloadAllGIFData,
                    onlyFirstFrame: onlyFirstFrame)
            case .unknown:
                image = Image(data: data, scale: scale)
            }
        return image
    }
```

图片处理

```
//圆角
public func image(withRoundRadius radius: CGFloat, fit size: CGSize) -> Image 
//resize
 public func resize(to size: CGSize) -> Image 
 public func resize(to size: CGSize, for contentMode: ContentMode) -> Image
 
 //模糊图片
 public func blurred(withRadius radius: CGFloat) -> Image
 //颜色覆盖
 public func overlaying(with color: Color, fraction: CGFloat) -> Image
 //tint
 public func tinted(with color: Color) -> Image
 //图片亮度、对比度等设置
 public func adjusted(brightness: CGFloat, contrast: CGFloat, saturation: CGFloat, inputEV: CGFloat) -> Image
 
```

解码

```
    var decoded: Image? {
        return decoded(scale: scale)
    }
    
    func decoded(scale: CGFloat) -> Image {
            if images != nil { return base }
        
        guard let imageRef = self.cgImage else {
            assertionFailure("[Kingfisher] Decoding only works for CG-based image.")
            return base
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = beginContext() else {
            assertionFailure("[Kingfisher] Decoding fails to create a valid context.")
            return base
        }
        
        defer { endContext() }
        
        let rect = CGRect(x: 0, y: 0, width: imageRef.width, height: imageRef.height)
        context.draw(imageRef, in: rect)
        let decompressedImageRef = context.makeImage()
        return Kingfisher<Image>.image(cgImage: decompressedImageRef!, scale: scale, refImage: base)
    }
```
图片格式和size

```
/// Reference the source image reference
class ImageSource {
    var imageRef: CGImageSource?
    init(ref: CGImageSource) {
        self.imageRef = ref
    }
}

// MARK: - Image format
private struct ImageHeaderData {
    static var PNG: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
    static var JPEG_SOI: [UInt8] = [0xFF, 0xD8]
    static var JPEG_IF: [UInt8] = [0xFF]
    static var GIF: [UInt8] = [0x47, 0x49, 0x46]
}

enum ImageFormat {
    case unknown, PNG, JPEG, GIF
}


// MARK: - Misc Helpers
public struct DataProxy {
    fileprivate let base: Data
    init(proxy: Data) {
        base = proxy
    }
}

extension Data: KingfisherCompatible {
    public typealias CompatibleType = DataProxy
    public var kf: DataProxy {
        return DataProxy(proxy: self)
    }
}

extension DataProxy {
    //返回image格式
    var imageFormat: ImageFormat {
        var buffer = [UInt8](repeating: 0, count: 8)
        (base as NSData).getBytes(&buffer, length: 8)
        if buffer == ImageHeaderData.PNG {
            return .PNG
        } else if buffer[0] == ImageHeaderData.JPEG_SOI[0] &&
            buffer[1] == ImageHeaderData.JPEG_SOI[1] &&
            buffer[2] == ImageHeaderData.JPEG_IF[0]
        {
            return .JPEG
        } else if buffer[0] == ImageHeaderData.GIF[0] &&
            buffer[1] == ImageHeaderData.GIF[1] &&
            buffer[2] == ImageHeaderData.GIF[2]
        {
            return .GIF
        }

        return .unknown
    }
}

public struct CGSizeProxy {
    fileprivate let base: CGSize
    init(proxy: CGSize) {
        base = proxy
    }
}

extension CGSize: KingfisherCompatible {
    public typealias CompatibleType = CGSizeProxy
    public var kf: CGSizeProxy {
        return CGSizeProxy(proxy: self)
    }
}

extension CGSizeProxy {
    func constrained(_ size: CGSize) -> CGSize {
        let aspectWidth = round(aspectRatio * size.height)
        let aspectHeight = round(size.width / aspectRatio)

        return aspectWidth > size.width ? CGSize(width: size.width, height: aspectHeight) : CGSize(width: aspectWidth, height: size.height)
    }

    func filling(_ size: CGSize) -> CGSize {
        let aspectWidth = round(aspectRatio * size.height)
        let aspectHeight = round(size.width / aspectRatio)

        return aspectWidth < size.width ? CGSize(width: size.width, height: aspectHeight) : CGSize(width: aspectWidth, height: size.height)
    }

    private var aspectRatio: CGFloat {
        return base.height == 0.0 ? 1.0 : base.width / base.height
    }
}
```

