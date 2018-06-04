//
//  PostError.swift
//  coding-challenge-chemowave
//
//  Created by Michael Duong on 6/1/18.
//  Copyright © 2018 Turnt Labs. All rights reserved.
//

import Foundation

enum PostError: Error {
    case invalidUrl
    case requestFailed
    case jsonConversionFailure
    case imageDataFailure
}
