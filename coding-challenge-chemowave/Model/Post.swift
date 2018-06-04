//
//  Post.swift
//  coding-challenge-chemowave
//
//  Created by Michael Duong on 6/1/18.
//  Copyright © 2018 Turnt Labs. All rights reserved.
//

import Foundation

struct JsonDictionary: Decodable {
    
    let data: DataDictionary
}

struct DataDictionary: Decodable {
    
    let children: [PostDictionary]
    let after: String?
    
    struct PostDictionary: Decodable {
        let data: Post
    }
}

struct Post: Decodable {
    
    let title: String?
    let thumbnail: String?
    let permalink: String?
}
