#基础类
##Date相关
包括：DateFormatterTransform, DateTransform, ISO8601DateTransform,CustomDateFormatTransform，TransformType


```
//这是最基础的协议//后面是协议的扩展和实现 
public protocol TransformType {
	//使用associatedtype关键字进行类型关联
	associatedtype Object
	associatedtype JSON

	func transformFromJSON(_ value: Any?) -> Object?
	func transformToJSON(_ value: Object?) -> JSON?
}

```

###DateTransform

```
open class DateTransform: TransformType {
	//遵守TransformType协议，实现协议时才指定类型
	public typealias Object = Date
	public typealias JSON = Double

	public init() {}
    //字符串和doule转化为date，否则nil
	open func transformFromJSON(_ value: Any?) -> Date? {
		if let timeInt = value as? Double {
			return Date(timeIntervalSince1970: TimeInterval(timeInt))
		}
		
		if let timeStr = value as? String {
			return Date(timeIntervalSince1970: TimeInterval(atof(timeStr)))
		}
		
		return nil
	}
    //转化为double
	open func transformToJSON(_ value: Date?) -> Double? {
		if let date = value {
			return Double(date.timeIntervalSince1970)
		}
		return nil
	}
}

```

###DateFormatterTransform

```
//遵守TransformType协议。不过这里的JSON是字符串类型
open class DateFormatterTransform: TransformType {
	public typealias Object = Date
	public typealias JSON = String
	
	public let dateFormatter: DateFormatter
	
	public init(dateFormatter: DateFormatter) {
		self.dateFormatter = dateFormatter
	}
	//String和date的相互转换
	open func transformFromJSON(_ value: Any?) -> Date? {
		if let dateString = value as? String {
			return dateFormatter.date(from: dateString)
		}
		return nil
	}
	
	open func transformToJSON(_ value: Date?) -> String? {
		if let date = value {
			return dateFormatter.string(from: date)
		}
		return nil
	}
}
```

###ISO8601DateTransform(继承DateFormatterTransform)

```
//国际标准化组织的国际标准ISO 8601是日期和时间的表示方法
open class ISO8601DateTransform: DateFormatterTransform {
	//继承的DateFormatterTransform，复写init方法
    //String和date的相互转换
	public init() {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
		
		super.init(dateFormatter: formatter)
	}
	
}
```

###CustomDateFormatTransform(继承DateFormatterTransform)

```
open class CustomDateFormatTransform: DateFormatterTransform {
	//自定义时间格式
    public init(formatString: String) {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.dateFormat = formatString
		
		super.init(dateFormatter: formatter)
    }
}
```

### TransformOf

```
open class TransformOf<ObjectType, JSONType>: TransformType {
	public typealias Object = ObjectType
	public typealias JSON = JSONType

	private let fromJSON: (JSONType?) -> ObjectType?
	private let toJSON: (ObjectType?) -> JSONType?
    //初始化定义Object和JSON类型
	public init(fromJSON: @escaping(JSONType?) -> ObjectType?, toJSON: @escaping(ObjectType?) -> JSONType?) {
		self.fromJSON = fromJSON
		self.toJSON = toJSON
	}
  //由block实现具体转换
	open func transformFromJSON(_ value: Any?) -> ObjectType? {
		return fromJSON(value as? JSONType)
	}

	open func transformToJSON(_ value: ObjectType?) -> JSONType? {
		return toJSON(value)
	}
}
```

###URL相关

```
//字符串和URL的转换
open class URLTransform: TransformType {
	public typealias Object = URL
	public typealias JSON = String
	private let shouldEncodeURLString: Bool
	private let allowedCharacterSet: CharacterSet

	/**
	Initializes the URLTransform with an option to encode URL strings before converting them to an NSURL
	- parameter shouldEncodeUrlString: when true (the default) the string is encoded before passing
	to `NSURL(string:)`
	- returns: an initialized transformer
	*/
	/**
	URLFragmentAllowedCharacterSet  "#%<>[\]^`{|}
	
	URLHostAllowedCharacterSet      "#%/<>?@\^`{|}
	
	URLPasswordAllowedCharacterSet  "#%/:<>?@[\]^`{|}
	
	URLPathAllowedCharacterSet      "#%;<>?[\]^`{|}
	
	URLQueryAllowedCharacterSet    "#%<>[\]^`{|}
	
	URLUserAllowedCharacterSet      "#%/:<>?@[\]^`
	*/
	public init(shouldEncodeURLString: Bool = true, allowedCharacterSet: CharacterSet = .urlQueryAllowed) {
		self.shouldEncodeURLString = shouldEncodeURLString
		self.allowedCharacterSet = allowedCharacterSet
	}

	open func transformFromJSON(_ value: Any?) -> URL? {
		guard let URLString = value as? String else { return nil }
		
		if !shouldEncodeURLString {
			return URL(string: URLString)
		}
		//特殊字符处理
		guard let escapedURLString = URLString.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) else {
			return nil
		}
		return URL(string: escapedURLString)
	}

	open func transformToJSON(_ value: URL?) -> String? {
		if let URL = value {
			return URL.absoluteString
		}
		return nil
	}
}
```

###EnumTransform

```
//枚举与枚举值的相互转换
open class EnumTransform<T: RawRepresentable>: TransformType {
	public typealias Object = T
	public typealias JSON = T.RawValue
	
	public init() {}
	
	open func transformFromJSON(_ value: Any?) -> T? {
		if let raw = value as? T.RawValue {
			return T(rawValue: raw)
		}
		return nil
	}
	
	open func transformToJSON(_ value: T?) -> T.RawValue? {
		if let obj = value {
			return obj.rawValue
		}
		return nil
	}
}
```

###NSDecimalNumberTransform

```
//精确小数计算与字符串转换
open class NSDecimalNumberTransform: TransformType {
    public typealias Object = NSDecimalNumber
    public typealias JSON = String

    public init() {}

    open func transformFromJSON(_ value: Any?) -> NSDecimalNumber? {
        if let string = value as? String {
            return NSDecimalNumber(string: string)
        } else if let number = value as? NSNumber {
            return NSDecimalNumber(decimal: number.decimalValue)
        } else if let double = value as? Double {
            return NSDecimalNumber(floatLiteral: double)
        }
        return nil
    }

    open func transformToJSON(_ value: NSDecimalNumber?) -> String? {
        guard let value = value else { return nil }
        return value.description
    }
}

```

###DataTransform

```

open class DataTransform: TransformType {
	public typealias Object = Data
	public typealias JSON = String
	
	public init() {}
	
	open func transformFromJSON(_ value: Any?) -> Data? {
		guard let string = value as? String else{
			return nil
		}
		return Data(base64Encoded: string)
	}
	
	open func transformToJSON(_ value: Data?) -> String? {
		guard let data = value else{
			return nil
		}
		return data.base64EncodedString()
	}
}
```

###DictionaryTransform

```
///Transforms [String: AnyObject] <-> [Key: Value] where Key is RawRepresentable as String, Value is Mappable
public struct DictionaryTransform<Key, Value>: TransformType where Key: Hashable, Key: RawRepresentable, Key.RawValue == String, Value: Mappable {
	
	public init() {
		
	}
	
	public func transformFromJSON(_ value: Any?) -> [Key: Value]? {
		
		guard let json = value as? [String: Any] else {
			
			return nil
		}
		
		let result = json.reduce([:]) { (result, element) -> [Key: Value] in
			
			guard
			let key = Key(rawValue: element.0),
			let valueJSON = element.1 as? [String: Any],
			let value = Value(JSON: valueJSON)
			else {
				
				return result
			}
			
			var result = result
			result[key] = value
			return result
		}
		
		return result
	}
	
	public func transformToJSON(_ value: [Key: Value]?) -> Any? {
		
		let result = value?.reduce([:]) { (result, element) -> [String: Any] in
			
			let key = element.0.rawValue
			let value = element.1.toJSON()
			
			var result = result
			result[key] = value
			return result
		}
		
		return result
	}
}
```
