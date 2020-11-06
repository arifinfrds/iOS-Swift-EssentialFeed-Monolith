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
    
    internal static func map(from data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
        if response.statusCode != OK_200 {
            throw RemoteFeedLoader.Error.invalidData
        }
        do {
            let root = try JSONDecoder().decode(Root.self, from: data)
            let feedItems = root.items.map { $0.feedItem }
            return feedItems
        } catch {
            throw RemoteFeedLoader.Error.invalidData
        }
    }
    
}

