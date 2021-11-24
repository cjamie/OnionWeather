//
//  Endpoint.swift
//  OnionWeather
//
//  Created by Jamie Chu on 11/23/21.
//

import Foundation

protocol ResponseDecodable {
    associatedtype Response
    var responseDecoder: (Data) -> Response { get }
}

struct Endpoint<T>: ResponseDecodable {
    typealias Response = T
    let host: String
    let scheme: String
    let path: String    
    let responseDecoder: (Data) -> Response
}
