#Date相关
包括：DateFormatterTransform, DateTransform, ISO8601DateTransform,CustomDateFormatTransform，TransformType


```
//这是最基础的协议//后面是协议的扩展和实现 
public protocol TransformType {
	
	associatedtype Object
	associatedtype JSON

	func transformFromJSON(_ value: Any?) -> Object?
	func transformToJSON(_ value: Object?) -> JSON?
}

```

###DateTransform

```
open class DateTransform: TransformType {
	//遵守TransformType协议
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