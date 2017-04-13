#核心实现

###Map

```
/// MapContext is available for developers who wish to pass information around during the mapping process.
public protocol MapContext {
	
}

/// A class used for holding mapping data
public final class Map {
	//枚举
	public let mappingType: MappingType
	//表示set方法只有在内部模块才能访问
	public internal(set) var JSON: [String: Any] = [:]
	public internal(set) var isKeyPresent = false
	public internal(set) var currentValue: Any?
	public internal(set) var currentKey: String?
	//嵌套的
	var keyIsNested = false
	//嵌套key的分解符
	public internal(set) var nestedKeyDelimiter: String = "."
	//
	public var context: MapContext?
	//是否包含nil值
	public var shouldIncludeNilValues = false  /// If this is set to true, toJSON output will include null values for any variables that are not set.
	
	let toObject: Bool // indicates whether the mapping is being applied to an existing object
	
	public init(mappingType: MappingType, JSON: [String: Any], toObject: Bool = false, context: MapContext? = nil, shouldIncludeNilValues: Bool = false) {
		
		self.mappingType = mappingType
		self.JSON = JSON
		self.toObject = toObject
		self.context = context
		self.shouldIncludeNilValues = shouldIncludeNilValues
	}
	
	//根据key 寻值
	/// Sets the current mapper value and key.
	/// The Key paramater can be a period separated string (ex. "distance.value") to access sub objects.
	public subscript(key: String) -> Map {
		// save key and value associated to it
		return self[key, delimiter: ".", ignoreNil: false]
	}
	
	public subscript(key: String, delimiter delimiter: String) -> Map {
		let nested = key.contains(delimiter)
		return self[key, nested: nested, delimiter: delimiter, ignoreNil: false]
	}
	
	public subscript(key: String, nested nested: Bool) -> Map {
		return self[key, nested: nested, delimiter: ".", ignoreNil: false]
	}
	
	public subscript(key: String, nested nested: Bool, delimiter delimiter: String) -> Map {
		return self[key, nested: nested, delimiter: delimiter, ignoreNil: false]
	}
	
	public subscript(key: String, ignoreNil ignoreNil: Bool) -> Map {
		return self[key, delimiter: ".", ignoreNil: ignoreNil]
	}
	
	public subscript(key: String, delimiter delimiter: String, ignoreNil ignoreNil: Bool) -> Map {
		let nested = key.contains(delimiter)
		return self[key, nested: nested, delimiter: delimiter, ignoreNil: ignoreNil]
	}
	
	public subscript(key: String, nested nested: Bool, ignoreNil ignoreNil: Bool) -> Map {
		return self[key, nested: nested, delimiter: ".", ignoreNil: ignoreNil]
	}
	
	public subscript(key: String, nested nested: Bool, delimiter delimiter: String, ignoreNil ignoreNil: Bool) -> Map {
		// save key and value associated to it
		currentKey = key
		keyIsNested = nested
		nestedKeyDelimiter = delimiter
		
		if mappingType == .fromJSON {
			// check if a value exists for the current key
			// do this pre-check for performance reasons
			if nested == false {
				let object = JSON[key]
				let isNSNull = object is NSNull
				isKeyPresent = isNSNull ? true : object != nil
				currentValue = isNSNull ? nil : object
			} else {
				// break down the components of the key that are separated by .
				//为key找到正确的值，自定义的寻值方式，需要标记是否有嵌套
				(isKeyPresent, currentValue) = valueFor(ArraySlice(key.components(separatedBy: delimiter)), dictionary: JSON)
			}
			
			// update isKeyPresent if ignoreNil is true
			if ignoreNil && currentValue == nil {
				isKeyPresent = false
			}
		}
		
		return self
	}
	
	public func value<T>() -> T? {
		return currentValue as? T
	}
	
}

/// Fetch value from JSON dictionary, loop through keyPathComponents until we reach the desired object
private func valueFor(_ keyPathComponents: ArraySlice<String>, dictionary: [String: Any]) -> (Bool, Any?) {
	// Implement it as a tail recursive function.
	if keyPathComponents.isEmpty {
		return (false, nil)
	}
	
	if let keyPath = keyPathComponents.first {
		let object = dictionary[keyPath]
		if object is NSNull {
			return (true, nil)
		} else if keyPathComponents.count > 1, let dict = object as? [String: Any] {
			let tail = keyPathComponents.dropFirst()
			return valueFor(tail, dictionary: dict)
		} else if keyPathComponents.count > 1, let array = object as? [Any] {
			let tail = keyPathComponents.dropFirst()
			return valueFor(tail, array: array)
		} else {
			return (object != nil, object)
		}
	}
	
	return (false, nil)
}

/// Fetch value from JSON Array, loop through keyPathComponents them until we reach the desired object
private func valueFor(_ keyPathComponents: ArraySlice<String>, array: [Any]) -> (Bool, Any?) {
	// Implement it as a tail recursive function.
	
	if keyPathComponents.isEmpty {
		return (false, nil)
	}
	
	//Try to convert keypath to Int as index
	if let keyPath = keyPathComponents.first,
		let index = Int(keyPath) , index >= 0 && index < array.count {
		
		let object = array[index]
		
		if object is NSNull {
			return (true, nil)
		} else if keyPathComponents.count > 1, let array = object as? [Any]  {
			let tail = keyPathComponents.dropFirst()
			return valueFor(tail, array: array)
		} else if  keyPathComponents.count > 1, let dict = object as? [String: Any] {
			let tail = keyPathComponents.dropFirst()
			return valueFor(tail, dictionary: dict)
		} else {
			return (true, object)
		}
	}
	
	return (false, nil)
}
```

###MapError
错误输出的格式和内容


###Mapper

```
public enum MappingType {
	case fromJSON
	case toJSON
}

/// The Mapper class provides methods for converting Model objects to JSON and methods for converting JSON to Model objects
public final class Mapper<N: BaseMappable> {
	
	public var context: MapContext?
	public var shouldIncludeNilValues = false /// If this is set to true, toJSON output will include null values for any variables that are not set.
	
	public init(context: MapContext? = nil, shouldIncludeNilValues: Bool = false){
		self.context = context
		self.shouldIncludeNilValues = shouldIncludeNilValues
	}
	
	// MARK: Mapping functions that map to an existing object toObject
	//json对象像已存在的object赋值
	/// Maps a JSON object to an existing Mappable object if it is a JSON dictionary, or returns the passed object as is
	public func map(JSONObject: Any?, toObject object: N) -> N {
		if let JSON = JSONObject as? [String: Any] {
			return map(JSON: JSON, toObject: object)
		}
		
		return object
	}
	
	/// Map a JSON string onto an existing object
	//json字符串像已存在的object赋值
	public func map(JSONString: String, toObject object: N) -> N {
		if let JSON = Mapper.parseJSONStringIntoDictionary(JSONString: JSONString) {
			return map(JSON: JSON, toObject: object)
		}
		return object
	}
	
	/// Maps a JSON dictionary to an existing object that conforms to Mappable.
	/// Usefull for those pesky objects that have crappy designated initializers like NSManagedObject
	public func map(JSON: [String: Any], toObject object: N) -> N {
		var mutableObject = object
		//map初始化
		let map = Map(mappingType: .fromJSON, JSON: JSON, toObject: true, context: context, shouldIncludeNilValues: shouldIncludeNilValues)
		//通过协议在model中实现
		mutableObject.mapping(map: map)
		return mutableObject
	}

	//MARK: Mapping functions that create an object
	
	/// Map a JSON string to an object that conforms to Mappable
	//
	public func map(JSONString: String) -> N? {
		//转字典
		if let JSON = Mapper.parseJSONStringIntoDictionary(JSONString: JSONString) {
			return map(JSON: JSON)
		}
		
		return nil
	}
	
	/// Maps a JSON object to a Mappable object if it is a JSON dictionary or NSString, or returns nil.
	public func map(JSONObject: Any?) -> N? {
		if let JSON = JSONObject as? [String: Any] {
			return map(JSON: JSON)
		}

		return nil
	}

	/// Maps a JSON dictionary to an object that conforms to Mappable
	public func map(JSON: [String: Any]) -> N? {
		//map初始化
		let map = Map(mappingType: .fromJSON, JSON: JSON, context: context, shouldIncludeNilValues: shouldIncludeNilValues)
		
		if let klass = N.self as? StaticMappable.Type { // Check if object is StaticMappable
			if var object = klass.objectForMapping(map: map) as? N {
				object.mapping(map: map)
				return object
			}
		} else if let klass = N.self as? Mappable.Type { // Check if object is Mappable
			if var object = klass.init(map: map) as? N {
				object.mapping(map: map)
				return object
			}
		} else if let klass = N.self as? ImmutableMappable.Type { // Check if object is ImmutableMappable
			do {
				return try klass.init(map: map) as? N
			} catch let error {
				#if DEBUG
				let exception: NSException
				if let mapError = error as? MapError {
					exception = NSException(name: .init(rawValue: "MapError"), reason: mapError.description, userInfo: nil)
				} else {
					exception = NSException(name: .init(rawValue: "ImmutableMappableError"), reason: error.localizedDescription, userInfo: nil)
				}
				exception.raise()
				#else
				NSLog("\(error)")
				#endif
			}
		} else {
			// Ensure BaseMappable is not implemented directly
			assert(false, "BaseMappable should not be implemented directly. Please implement Mappable, StaticMappable or ImmutableMappable")
		}
		
		return nil
	}
```

###Mappable

```
/// BaseMappable should not be implemented directly. Mappable or StaticMappable should be used instead
public protocol BaseMappable {
	/// This function is where all variable mappings should occur. It is executed by Mapper during the mapping (serialization and deserialization) process.
	//使用 mutating 关键字修饰方法是为了能在该方法中修改 struct 或是 enum 的变量，在设计接口的时候，也要考虑到使用者程序的扩展性。
	mutating func mapping(map: Map)
}

public protocol Mappable: BaseMappable {
    /// This function can be used to validate JSON prior to mapping. Return nil to cancel mapping at this point
    init?(map: Map)
}

public protocol StaticMappable: BaseMappable {
	/// This is function that can be used to:
	///		1) provide an existing cached object to be used for mapping
	///		2) return an object of another class (which conforms to BaseMappable) to be used for mapping. For instance, you may inspect the JSON to infer the type of object that should be used for any given mapping
	static func objectForMapping(map: Map) -> BaseMappable?
}

public extension BaseMappable {
	
	/// Initializes object from a JSON String
	public init?(JSONString: String, context: MapContext? = nil) {
		if let obj: Self = Mapper(context: context).map(JSONString: JSONString) {
			self = obj
		} else {
			return nil
		}
	}
	
	/// Initializes object from a JSON Dictionary
	public init?(JSON: [String: Any], context: MapContext? = nil) {
		if let obj: Self = Mapper(context: context).map(JSON: JSON) {
			self = obj
		} else {
			return nil
		}
	}
	
	/// Returns the JSON Dictionary for the object
	public func toJSON() -> [String: Any] {
		return Mapper().toJSON(self)
	}
	
	/// Returns the JSON String for the object
	public func toJSONString(prettyPrint: Bool = false) -> String? {
		return Mapper().toJSONString(self, prettyPrint: prettyPrint)
	}
}

public extension Array where Element: BaseMappable {
	
	/// Initialize Array from a JSON String
	public init?(JSONString: String, context: MapContext? = nil) {
		if let obj: [Element] = Mapper(context: context).mapArray(JSONString: JSONString) {
			self = obj
		} else {
			return nil
		}
	}
	
	/// Initialize Array from a JSON Array
	public init?(JSONArray: [[String: Any]], context: MapContext? = nil) {
		if let obj: [Element] = Mapper(context: context).mapArray(JSONArray: JSONArray) {
			self = obj
		} else {
			return nil
		}
	}
	
	/// Returns the JSON Array
	public func toJSON() -> [[String: Any]] {
		return Mapper().toJSONArray(self)
	}
	
	/// Returns the JSON String for the object
	public func toJSONString(prettyPrint: Bool = false) -> String? {
		return Mapper().toJSONString(self, prettyPrint: prettyPrint)
	}
}

public extension Set where Element: BaseMappable {
	
	/// Initializes a set from a JSON String
	public init?(JSONString: String, context: MapContext? = nil) {
		if let obj: Set<Element> = Mapper(context: context).mapSet(JSONString: JSONString) {
			self = obj
		} else {
			return nil
		}
	}
	
	/// Initializes a set from JSON
	public init?(JSONArray: [[String: Any]], context: MapContext? = nil) {
		guard let obj = Mapper(context: context).mapSet(JSONArray: JSONArray) as Set<Element>? else {
            return nil
        }
		self = obj
	}
	
	/// Returns the JSON Set
	public func toJSON() -> [[String: Any]] {
		return Mapper().toJSONSet(self)
	}
	
	/// Returns the JSON String for the object
	public func toJSONString(prettyPrint: Bool = false) -> String? {
		return Mapper().toJSONString(self, prettyPrint: prettyPrint)
	}
}
```