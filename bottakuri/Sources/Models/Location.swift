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
    let location: [Float]
    let title: String?
}
