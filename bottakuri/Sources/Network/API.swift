//
//  API.swift
//  bottakuri
//
//  Created by ymgn on 2019/10/04.
//  Copyright © 2019 ymgn. All rights reserved.
//

import Foundation
import APIKit

final class DecodableDataParser: DataParser {
    var contentType: String? {
        return "applicaiton/json"
    }
    
    func parse(data: Data) throws -> Any {
        return data
    }
}

enum Result<T> {
    case success(T)
    case faulure(Error)
}

protocol locationRequest: Request { }

extension locationRequest {
    public var baseURL: URL {
        return URL(string: BASE_URL)!
    }
}

public struct GetLocations: locationRequest {
    public var dataParser: DataParser {
        return DecodableDataParser()
    }
    
    public typealias Response = LocationGetResponse
    public let method: HTTPMethod = .get
    public var path: String {
        return "/sendLocation"
    }
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> LocationGetResponse {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(LocationGetResponse.self, from: data)
    }
}
public struct LocationGetResponse: Decodable {
    let errorStr: String?
    let isSave: Int
    let locaitonData: [Location]
}
public struct PostLocation: locationRequest {
    public var dataParser: DataParser {
        return DecodableDataParser()
    }
    
    public typealias Response = LocationPostResponse
    public var location: Location
    public let method: HTTPMethod = .post
    public var path: String {
        return "/saveLocation"
    }
    public var bodyParameters: BodyParameters? {
        return JSONBodyParameters(JSONObject: try! JSONEncoder().encode(location))
    }
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> LocationPostResponse {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(LocationPostResponse.self, from: data)
    }
}
public struct LocationPostResponse: Decodable {
    let errorStr: String?
    let isSave: Int
}
