//
//  FeedLoader.swift
//  EssentialFeedApp
//
//  Created by Arifin Firdaus on 27/10/20.
//

import Foundation

enum LoadFeedResult {
    case success(_ items: [FeedItem])
    case failure(_ error: Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
