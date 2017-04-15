#ImageProcessor

//图片处理器，定义

```
public enum ImageProcessItem {
    case image(Image)
    case data(Data)
}

/// An `ImageProcessor` would be used to convert some downloaded data to an image.
public protocol ImageProcessor {

    var identifier: String { get }
    
     func process(item: ImageProcessItem, options: KingfisherOptionsInfo) -> Image?
}

typealias ProcessorImp = ((ImageProcessItem, KingfisherOptionsInfo) -> Image?)

public extension ImageProcessor {
    
    /// Append an `ImageProcessor` to another. The identifier of the new `ImageProcessor` 
    /// will be "\(self.identifier)|>\(another.identifier)".
    ///
    /// - parameter another: An `ImageProcessor` you want to append to `self`.
    ///
    /// - returns: The new `ImageProcessor`. It will process the image in the order
    ///            of the two processors concatenated.
    public func append(another: ImageProcessor) -> ImageProcessor {
        let newIdentifier = identifier.appending("|>\(another.identifier)")
        return GeneralProcessor(identifier: newIdentifier) {
            item, options in
            //先由ImageProcessor转换成图片，再交给another完成another的操作
            if let image = self.process(item: item, options: options) {
                return another.process(item: .image(image), options: options)
            } else {
                return nil
            }
        }
    }
}

fileprivate struct GeneralProcessor: ImageProcessor {
    let identifier: String
    let p: ProcessorImp
    func process(item: ImageProcessItem, options: KingfisherOptionsInfo) -> Image? {
        return p(item, options)
    }
}

/// The default processor. It convert the input data to a valid image.
/// Images of .PNG, .JPEG and .GIF format are supported.
/// If an image is given, `DefaultImageProcessor` will do nothing on it and just return that image.
public struct DefaultImageProcessor: ImageProcessor {
    
    /// A default `DefaultImageProcessor` could be used across.
    public static let `default` = DefaultImageProcessor()
    
    public let identifier = ""
    
    /// Initialize a `DefaultImageProcessor`
    ///
    /// - returns: An initialized `DefaultImageProcessor`.
    public init() {}
    //图片处理器
    public func process(item: ImageProcessItem, options: KingfisherOptionsInfo) -> Image? {
        switch item {
        case .image(let image):
            return image
        case .data(let data):
            return Kingfisher<Image>.image(
                data: data,
                scale: options.scaleFactor,
                preloadAllGIFData: options.preloadAllGIFData,
                onlyFirstFrame: options.onlyLoadFirstFrame)
        }
    }
}

```

图片处理器中的具体功能都在Image类中实现，他们都遵守并实现了ImageProcessor

```
//圆角
public struct RoundCornerImageProcessor: ImageProcessor {
    public let identifier: String

    //输出图片的尺寸
    public let targetSize: CGSize?

    public init(cornerRadius: CGFloat, targetSize: CGSize? = nil) {
        self.cornerRadius = cornerRadius
        self.targetSize = targetSize
        if let size = targetSize {
            self.identifier = "com.onevcat.Kingfisher.RoundCornerImageProcessor(\(cornerRadius)_\(size))"
        } else {
            self.identifier = "com.onevcat.Kingfisher.RoundCornerImageProcessor(\(cornerRadius))"
        }
    }
    
    public func process(item: ImageProcessItem, options: KingfisherOptionsInfo) -> Image? {
        switch item {
        case .image(let image):
            let size = targetSize ?? image.kf.size
            return image.kf.image(withRoundRadius: cornerRadius, fit: size)
        case .data(_):
            //先转换为image，再做圆角处理
            return (DefaultImageProcessor.default >> self).process(item: item, options: options)
        }
    }
}
//resize
ResizingImageProcessor
 //模糊图片
 BlurImageProcessor
 //颜色覆盖
 OverlayImageProcessor
 //tint
 TintImageProcessor
 //图片亮度、对比度等设置
 ColorControlsProcessor
 
```

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

#Indicator

```
//协议和枚举，默认的就是none。可以看到能支持系统的UIActivityIndicatorView，
//还能支持gif，当然要传入一个imageData的参数，还能支持自定义的Indicator。从代码
//中可以看的出来Indicator是一个协议，如果要实现自定义只需要继承这个协议就可以了
public enum IndicatorType {
    /// No indicator.
    case none
    /// Use system activity indicator.
    case activity
    /// Use an image as indicator. GIF is supported.
    case image(imageData: Data)
    /// Use a custom indicator, which conforms to the `Indicator` protocol.
    case custom(indicator: Indicator)
}

// MARK: - Indicator Protocol
public protocol Indicator {
    func startAnimatingView()
    func stopAnimatingView()

    var viewCenter: CGPoint { get set }
    var view: IndicatorView { get }
}

extension Indicator {
    public var viewCenter: CGPoint {
        get {
            return view.center
        }
        set {
            view.center = newValue
        }
    }
}

```
遵守Indicator Protocol的具体实现

```
// MARK: - ActivityIndicator
// Displays a NSProgressIndicator / UIActivityIndicatorView
struct ActivityIndicator: Indicator {

    private let activityIndicatorView: UIActivityIndicatorView

    var view: IndicatorView {
        return activityIndicatorView
    }

    func startAnimatingView() {
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = false
    }

    func stopAnimatingView() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
    }

    init() {
            let indicatorStyle = UIActivityIndicatorViewStyle.gray
            activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle:indicatorStyle)
            activityIndicatorView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleTopMargin]
    }
}

// MARK: - ImageIndicator
// Displays an ImageView. Supports gif
struct ImageIndicator: Indicator {
    private let animatedImageIndicatorView: ImageView

    var view: IndicatorView {
        return animatedImageIndicatorView
    }

    init?(imageData data: Data, processor: ImageProcessor = DefaultImageProcessor.default, options: KingfisherOptionsInfo = KingfisherEmptyOptionsInfo) {

        var options = options
        // Use normal image view to show gif, so we need to preload all gif data.
        if !options.preloadAllGIFData {
            options.append(.preloadAllGIFData)
        }
        
        guard let image = processor.process(item: .data(data), options: options) else {
            return nil
        }

        animatedImageIndicatorView = ImageView()
        animatedImageIndicatorView.image = image
        
         animatedImageIndicatorView.contentMode = .center
            
        animatedImageIndicatorView.autoresizingMask = [.flexibleLeftMargin,
                                                           .flexibleRightMargin,
                                                           .flexibleBottomMargin,
                                                           .flexibleTopMargin]
    }

    func startAnimatingView() {
           animatedImageIndicatorView.startAnimating()

        animatedImageIndicatorView.isHidden = false
    }

    func stopAnimatingView() {

        animatedImageIndicatorView.stopAnimating()
        animatedImageIndicatorView.isHidden = true
    }
}
```

