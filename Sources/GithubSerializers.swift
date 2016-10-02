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
    case array([JSON])
    case dictionary([String: JSON])
    case str(String)
    case number(NSNumber)
    case null
}

extension JSON: Equatable {
}

public func ==(lhs: JSON, rhs: JSON) -> Bool {
    switch (lhs, rhs) {
        case (.null, .null):
            return true
        case (.str(let str1), .str(let str2)):
            return str1 == str2
        case (.number(let num1), .number(let num2)):
            return num1 == num2
        case (let .array(array1), let .array(array2)):
            return array1 == array2
        case (let .dictionary(dic1), let .dictionary(dic2)):
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
func objectToJSON(_ json: AnyObject) -> JSON {
    switch json {
        case _ as NSNull:
            return .null
        case let str as String:
            return .str(str)
        case let num as NSNumber:
            return .number(num)
        case let array as [AnyObject]:
            let converted = array.map { objectToJSON($0) }
            return .array(converted)
        case let dic as [String: AnyObject]:
            var converted: [String: JSON] = [:]
            for (k, v) in dic {
                converted[k] = objectToJSON(v)
            }
            return .dictionary(converted)
        default:
            fatalError("Unknown type trying to parse JSON.")
    }
}

/**
 Convert JSON to object.
 
 - parameter json: JSON object to be converted.
 
 - returns: converted object.
 */
func prepareJSONForSerialization(_ json: JSON) -> AnyObject {
    switch json {
        case .null:
            return NSNull()
        case .str(let str):
            return str as AnyObject
        case .number(let num):
            return num
        case .array(let array):
            return array.map { prepareJSONForSerialization($0) } as AnyObject
        case .dictionary(let dic):
            var converted = [String: AnyObject]()
            for (key, json) in dic {
                // Learned, when we meet with a .Null JSON, we should not include it to result
                switch json {
                    case .null:
                        continue
                    default:
                        converted[key] = prepareJSONForSerialization(json)
                }
            }
            return converted as AnyObject
    }
}

/**
 Convert JSON to Data
 
 - parameter json: JSON object
 
 - returns: converted Data
 */
func dumpJSON(_ json: JSON) -> Data? {
    switch json {
        case .null:
            return "null".data(using: String.Encoding.utf8, allowLossyConversion: false)
        default:
            let obj : AnyObject = prepareJSONForSerialization(json)
            if JSONSerialization.isValidJSONObject(obj) {
                return try! JSONSerialization.data(withJSONObject: obj, options: JSONSerialization.WritingOptions())
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
func parseJSON(_ data: Data) -> JSON {
    let obj: AnyObject = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
    return objectToJSON(obj)
}

/**
 *  Protocol to Serialize ValueType to JSON, and deserialize JSON to ValueType.
 */
public protocol JSONSerializer {
    associatedtype ValueType
    func serialize(_: ValueType) -> JSON
    func deserialize(_: JSON) -> ValueType
}

/// VoidSerializer
open class VoidSerializer: JSONSerializer {
    /**
     nil -> .Null
     */
    open func serialize(_ value: Void) -> JSON {
        return .null
    }
    
    /**
     .Null -> nil
     */
    open func deserialize(_ json: JSON) -> Void {
        switch json {
            case .null:
                return
            default:
                fatalError("Type error deserializing")
        }
    }
}

/// StringSerializer
open class StringSerializer: JSONSerializer {
    init() { }
    
    /**
     String -> .Str
     */
    open func serialize(_ str: String) -> JSON {
        return .str(str)
    }
    
    /**
     .Str -> String
     */
    open func deserialize(_ json: JSON) -> String {
        switch json {
            case .str(let str):
                return str
            default:
                fatalError("Type error deserializing")
        }
    }
}

/// ArraySerializer
open class ArraySerializer<T: JSONSerializer>: JSONSerializer {
    /// ElementSerializer used by element stored in Array.
    var elementSerializer: T
    
    init(_ elementSerializer: T) {
        self.elementSerializer = elementSerializer
    }
    
    open func serialize(_ value: Array<T.ValueType>) -> JSON {
        return .array(value.map { self.elementSerializer.serialize($0) })
    }
    
    open func deserialize(_ json: JSON) -> Array<T.ValueType> {
        switch json {
            case .array(let array):
                return array.map {self.elementSerializer.deserialize($0)}
            default:
                fatalError("Type error deserializing")
        }
    }
}

/// BollSerializer
open class BoolSerializer: JSONSerializer {
    open func serialize(_ value: Bool) -> JSON {
        return .number(NSNumber(value: value as Bool))
    }
    
    open func deserialize(_ json: JSON) -> Bool {
        switch json {
            case .number(let num):
                return num.boolValue
            default:
                fatalError("Type error deserializing")
        }
    }
}

/// UInt64Serializer
open class UInt64Serializer : JSONSerializer {
    open func serialize(_ value : UInt64) -> JSON {
        return .number(NSNumber(value: value as UInt64))
    }
    
    open func deserialize(_ json : JSON) -> UInt64 {
        switch json {
        case .number(let n):
            return n.uint64Value
        default:
            fatalError("Type error deserializing")
        }
    }
}

/// Int64Serializer
open class Int64Serializer : JSONSerializer {
    open func serialize(_ value : Int64) -> JSON {
        return .number(NSNumber(value: value as Int64))
    }
    
    open func deserialize(_ json : JSON) -> Int64 {
        switch json {
        case .number(let n):
            return n.int64Value
        default:
            fatalError("Type error deserializing")
        }
    }
}

/// Int32Serializer
open class Int32Serializer : JSONSerializer {
    open func serialize(_ value : Int32) -> JSON {
        return .number(NSNumber(value: value as Int32))
    }
    
    open func deserialize(_ json : JSON) -> Int32 {
        switch json {
        case .number(let n):
            return n.int32Value
        default:
            fatalError("Type error deserializing")
        }
    }
}

/// UInt32Serializer
open class UInt32Serializer : JSONSerializer {
    open func serialize(_ value : UInt32) -> JSON {
        return .number(NSNumber(value: value as UInt32))
    }
    
    open func deserialize(_ json : JSON) -> UInt32 {
        switch json {
        case .number(let n):
            return n.uint32Value
        default:
            fatalError("Type error deserializing")
        }
    }
}

/// NSDataSerializer
open class NSDataSerializer : JSONSerializer {
    open func serialize(_ value : Data) -> JSON {
        return .str(value.base64EncodedString(options: []))
    }
    
    open func deserialize(_ json: JSON) -> Data {
        switch(json) {
        case .str(let s):
            return Data(base64Encoded: s, options: [])!
        default:
            fatalError("Type error deserializing")
        }
    }
}

/// DoubleSerializer
open class DoubleSerializer : JSONSerializer {
    open func serialize(_ value: Double) -> JSON {
        return .number(NSNumber(value: value as Double))
    }
    
    open func deserialize(_ json: JSON) -> Double {
        switch json {
        case .number(let n):
            return n.doubleValue
        default:
            fatalError("Type error deserializing")
        }
    }
}

/// NullableSerializer, which the object to be converted to JSON could be `nil`.
open class NullableSerializer<T: JSONSerializer> {
    /// ValueSerializer to be used by non-nil value.
    let valueSerializer: T
    init(_ valueSerializer:T) {
        self.valueSerializer = valueSerializer
    }
    
    open func serialize(_ value: T.ValueType?) -> JSON {
        if let v = value {
            return self.valueSerializer.serialize(v)
        } else {
            return .null
        }
    }
    
    open func deserialize(_ json:JSON) -> T.ValueType? {
        switch json {
            case .null:
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


