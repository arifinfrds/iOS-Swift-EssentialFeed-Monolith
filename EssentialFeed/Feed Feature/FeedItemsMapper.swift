//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Arifin Firdaus on 06/11/20.
//

import Foundation

internal final class FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [Item]
        var feeds: [FeedItem] {
            return items.map { $0.feedItem }
        }
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var feedItem: FeedItem {
            return FeedItem(
                id: id,
                description: description,
                location: location,
                url: image
            )
        }
    }
    
    private static var OK_200 = 200

    internal static func map(_ data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(.invalidData)
        }
        return .success(root.feeds)
    }
    
}

