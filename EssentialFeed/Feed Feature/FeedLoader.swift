//
//  FeedLoader.swift
//  EssentialFeedApp
//
//  Created by Arifin Firdaus on 27/10/20.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
    case success(_ items: [FeedItem])
    case failure(_ error: Error)
}

protocol FeedLoader {
    associatedtype Error: Swift.Error
    
    func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
