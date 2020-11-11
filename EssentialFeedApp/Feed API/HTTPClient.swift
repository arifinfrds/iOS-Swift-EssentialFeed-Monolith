//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Arifin Firdaus on 06/11/20.
//

import Foundation


enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

