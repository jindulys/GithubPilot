//
//  File.swift
//  GitPocket
//
//  Created by yansong li on 2016-02-15.
//  Copyright © 2016 yansong li. All rights reserved.
//

import Foundation

/**
 JSON Enum
 
 - Array:      array JSON
 - Dictionary: dictionary JSON
 - Str:        string JSON
 - Number:     number JSON
 - Null:       null JSON
 */
public enum JSON {
    case Array([JSON])
    case Dictionary([String: JSON])
    case Str(String)
    case Number(NSNumber)
    case Null
}

extension JSON: Equatable {
}

public func ==(lhs: JSON, rhs: JSON) -> Bool {
    switch (lhs, rhs) {
        case (.Null, .Null):
            return true
        case (.Str(let str1), .Str(let str2)):
            return str1 == str2
        case (.Number(let num1), .Number(let num2)):
            return num1 == num2
        case (let .Array(array1), let .Array(array2)):
            return array1 == array2
        case (let .Dictionary(dic1), let .Dictionary(dic2)):
            if dic1.count != dic2.count { return false }
            for (k, v) in dic1 {
                if let v2 = dic2[k] {
                    if v2 != v {
                        return false
                    }
                } else {
                    return false
                }
            }
            return true
        default:
            return false
    }
}

/**
 Convert an object to JSON
 
 - parameter json: an arbitrary object
 
 - returns: corresponding JSON object.
 */
func objectToJSON(json: AnyObject) -> JSON {
    switch json {
        case _ as NSNull:
            return .Null
        case let str as String:
            return .Str(str)
        case let num as NSNumber:
            return .Number(num)
        case let array as [AnyObject]:
            let converted = array.map { objectToJSON($0) }
            return .Array(converted)
        case let dic as [String: AnyObject]:
            var converted: [String: JSON] = [:]
            for (k, v) in dic {
                converted[k] = objectToJSON(v)
            }
            return .Dictionary(converted)
        default:
            fatalError("Unknown type trying to parse JSON.")
    }
}

/**
 Convert JSON to object.
 
 - parameter json: JSON object to be converted.
 
 - returns: converted object.
 */
func prepareJSONForSerialization(json: JSON) -> AnyObject {
    switch json {
        case .Null:
            return NSNull()
        case .Str(let str):
            return str
        case .Number(let num):
            return num
        case .Array(let array):
            return array.map {prepareJSONForSerialization($0)}
        case .Dictionary(let dic):
            var converted = [String: AnyObject]()
            for (key, json) in dic {
                // Learned, when we meet with a .Null JSON, we should not include it to result
                switch json {
                    case .Null:
                        continue
                    default:
                        converted[key] = prepareJSONForSerialization(json)
                }
            }
            return converted
    }
}

/**
 Convert JSON to Data
 
 - parameter json: JSON object
 
 - returns: converted Data
 */
func dumpJSON(json: JSON) -> NSData? {
    switch json {
        case .Null:
            return "null".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        default:
            let obj : AnyObject = prepareJSONForSerialization(json)
            if NSJSONSerialization.isValidJSONObject(obj) {
                return try! NSJSONSerialization.dataWithJSONObject(obj, options: NSJSONWritingOptions())
            } else {
                fatalError("Invalid JSON toplevel type")
            }
    }
}


/**
 Convert NSData to JSON
 
 - parameter data: NSData object
 
 - returns: JSON object
 */
func parseJSON(data: NSData) -> JSON {
    let obj: AnyObject = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
    return objectToJSON(obj)
}

/**
 *  Protocol to Serialize ValueType to JSON, and deserialize JSON to ValueType.
 */
public protocol JSONSerializer {
    typealias ValueType
    func serialize(_: ValueType) -> JSON
    func deserialize(_: JSON) -> ValueType
}

/// VoidSerializer
public class VoidSerializer: JSONSerializer {
    /**
     nil -> .Null
     */
    public func serialize(value: Void) -> JSON {
        return .Null
    }
    
    /**
     .Null -> nil
     */
    public func deserialize(json: JSON) -> Void {
        switch json {
            case .Null:
                return
            default:
                fatalError("Type error deserializing")
        }
    }
}

/// StringSerializer
public class StringSerializer: JSONSerializer {
    init() { }
    
    /**
     String -> .Str
     */
    public func serialize(str: String) -> JSON {
        return .Str(str)
    }
    
    /**
     .Str -> String
     */
    public func deserialize(json: JSON) -> String {
        switch json {
            case .Str(let str):
                return str
            default:
                fatalError("Type error deserializing")
        }
    }
}

/// ArraySerializer
public class ArraySerializer<T: JSONSerializer>: JSONSerializer {
    /// ElementSerializer used by element stored in Array.
    var elementSerializer: T
    
    init(_ elementSerializer: T) {
        self.elementSerializer = elementSerializer
    }
    
    public func serialize(value: Array<T.ValueType>) -> JSON {
        return .Array(value.map { self.elementSerializer.serialize($0) })
    }
    
    public func deserialize(json: JSON) -> Array<T.ValueType> {
        switch json {
            case .Array(let array):
                return array.map {self.elementSerializer.deserialize($0)}
            default:
                fatalError("Type error deserializing")
        }
    }
}

/// BollSerializer
public class BoolSerializer: JSONSerializer {
    public func serialize(value: Bool) -> JSON {
        return .Number(NSNumber(bool: value))
    }
    
    public func deserialize(json: JSON) -> Bool {
        switch json {
            case .Number(let num):
                return num.boolValue
            default:
                fatalError("Type error deserializing")
        }
    }
}

/// UInt64Serializer
public class UInt64Serializer : JSONSerializer {
    public func serialize(value : UInt64) -> JSON {
        return .Number(NSNumber(unsignedLongLong: value))
    }
    
    public func deserialize(json : JSON) -> UInt64 {
        switch json {
        case .Number(let n):
            return n.unsignedLongLongValue
        default:
            fatalError("Type error deserializing")
        }
    }
}

/// Int64Serializer
public class Int64Serializer : JSONSerializer {
    public func serialize(value : Int64) -> JSON {
        return .Number(NSNumber(longLong: value))
    }
    
    public func deserialize(json : JSON) -> Int64 {
        switch json {
        case .Number(let n):
            return n.longLongValue
        default:
            fatalError("Type error deserializing")
        }
    }
}

/// Int32Serializer
public class Int32Serializer : JSONSerializer {
    public func serialize(value : Int32) -> JSON {
        return .Number(NSNumber(int: value))
    }
    
    public func deserialize(json : JSON) -> Int32 {
        switch json {
        case .Number(let n):
            return n.intValue
        default:
            fatalError("Type error deserializing")
        }
    }
}

/// UInt32Serializer
public class UInt32Serializer : JSONSerializer {
    public func serialize(value : UInt32) -> JSON {
        return .Number(NSNumber(unsignedInt: value))
    }
    
    public func deserialize(json : JSON) -> UInt32 {
        switch json {
        case .Number(let n):
            return n.unsignedIntValue
        default:
            fatalError("Type error deserializing")
        }
    }
}

/// NSDataSerializer
public class NSDataSerializer : JSONSerializer {
    public func serialize(value : NSData) -> JSON {
        return .Str(value.base64EncodedStringWithOptions([]))
    }
    
    public func deserialize(json: JSON) -> NSData {
        switch(json) {
        case .Str(let s):
            return NSData(base64EncodedString: s, options: [])!
        default:
            fatalError("Type error deserializing")
        }
    }
}

/// DoubleSerializer
public class DoubleSerializer : JSONSerializer {
    public func serialize(value: Double) -> JSON {
        return .Number(NSNumber(double: value))
    }
    
    public func deserialize(json: JSON) -> Double {
        switch json {
        case .Number(let n):
            return n.doubleValue
        default:
            fatalError("Type error deserializing")
        }
    }
}

/// NullableSerializer, which the object to be converted to JSON could be `nil`.
public class NullableSerializer<T: JSONSerializer> {
    /// ValueSerializer to be used by non-nil value.
    let valueSerializer: T
    init(_ valueSerializer:T) {
        self.valueSerializer = valueSerializer
    }
    
    public func serialize(value: T.ValueType?) -> JSON {
        if let v = value {
            return self.valueSerializer.serialize(v)
        } else {
            return .Null
        }
    }
    
    public func deserialize(json:JSON) -> T.ValueType? {
        switch json {
            case .Null:
                return nil
            default:
                return self.valueSerializer.deserialize(json)
        }
    }
}

/**
 *  Struct to hold common used Serializers.
 */
struct Serialization {
    static var _StringSerializer = StringSerializer()
    static var _BoolSerializer = BoolSerializer()
    static var _UInt64Serializer = UInt64Serializer()
    static var _UInt32Serializer = UInt32Serializer()
    static var _Int64Serializer = Int64Serializer()
    static var _Int32Serializer = Int32Serializer()
    
    static var _VoidSerializer = VoidSerializer()
    static var _NSDataSerializer = NSDataSerializer()
    static var _DoubleSerializer = DoubleSerializer()
}


