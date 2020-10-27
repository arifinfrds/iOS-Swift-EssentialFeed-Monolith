//
//  FeedLoader.swift
//  EssentialFeedApp
//
//  Created by Arifin Firdaus on 27/10/20.
//

import Foundation

enum LoadFeedResult {
    case success(items: [FeedItem])
    case error(error: Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
