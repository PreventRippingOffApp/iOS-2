//
//  Location.swift
//  bottakuri
//
//  Created by ymgn on 2019/10/04.
//  Copyright © 2019 ymgn. All rights reserved.
//

import Foundation

public struct Location: Encodable, Decodable {
    let description: String?
    let location: [Float]?
    let title: String?
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(description, forKey: .description)
        try container.encode(location, forKey: .location)
        try container.encode(title, forKey: .title)
    }
}
