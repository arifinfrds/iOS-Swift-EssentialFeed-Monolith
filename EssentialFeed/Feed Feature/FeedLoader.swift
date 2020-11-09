//
//  FeedLoader.swift
//  EssentialFeedApp
//
//  Created by Arifin Firdaus on 27/10/20.
//

import Foundation

public enum LoadFeedResult {
    case success(_ items: [FeedItem])
    case failure(_ error: Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
