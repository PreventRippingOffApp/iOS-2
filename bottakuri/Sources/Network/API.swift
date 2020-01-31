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
    case failure(Error)
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
        return "sendLocation"
    }
    
    public var parameters: Any? {
        return ["lat": lat, "lng": lng, "maxdistance": distance]
    }
    
    let lat: Double
    let lng: Double
    let distance: Double
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> LocationGetResponse {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(LocationGetResponse.self, from: data)
    }
}
public struct LocationGetResponse: Decodable {
    let errorStr: String?
    let isSave: Int
    let locationData: [Location]
}
public struct PostLocation: locationRequest {
    public var dataParser: DataParser {
        return DecodableDataParser()
    }
    
    public typealias Response = LocationPostResponse
    public var location: Location
    public let method: HTTPMethod = .post
    public var path: String {
        return "saveLocation"
    }
    public var bodyParameters: BodyParameters? {
        return JSONBodyParameters(JSONObject: [
            "location": location.location
        ])
    }
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> LocationPostResponse {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(LocationPostResponse.self, from: data)
    }
}
public struct LocationPostResponse: Decodable {
    let errorStr: String?
    let isSave: Int
}

public struct GetRisk: locationRequest {
    public var dataParser: DataParser {
        return DecodableDataParser()
    }
    
    public typealias Response = GetRiskResponse
    public var path: String {
        return "risk"
    }
    
    public var method: HTTPMethod {
        return .get
    }
    
    public var parameters: Any? {
        return ["lat": lat, "lng": lng]
    }
    
    let lat: Double
    let lng: Double
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Response.self, from: data)
    }
}

public struct GetRiskResponse: Decodable {
    let risk: Int
}

public struct SendAudioFile: locationRequest {
    public var dataParser: DataParser {
        return DecodableDataParser()
    }
    
    public typealias Response = LocationPostResponse
    public var path: String {
        return "saveAudio"
    }
    public var method: HTTPMethod {
        return .post
    }
    public var bodyParameters: BodyParameters? {
        let param = [
            try! MultipartFormDataBodyParameters.Part(value: "hoge", name: "token"),
            try! MultipartFormDataBodyParameters.Part(value: lat, name: "lat"),
            try! MultipartFormDataBodyParameters.Part(value: lng, name: "lng"),
            try! MultipartFormDataBodyParameters.Part(fileURL: audioFileUrl, name: "audioFile")
        ]
        return MultipartFormDataBodyParameters(parts: param)
    }
    
    let lat: Double
    let lng: Double
    let audioFileUrl: URL
    
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        let decoder = JSONDecoder()
        return try decoder.decode(Response.self, from: data)
    }
}
