//
//  RemoteFeedLoader.swift
//  EssentialFeedApp
//
//  Created by Arifin Firdaus on 27/10/20.
//

import Foundation


public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(
        from url: URL,
        completion: @escaping (HTTPClientResult) -> Void
    )
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping ((Result) -> Void)) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                if response.statusCode == 200 {
                    do {
                        let feedItems = try FeedItemsMapper.map(from: data, response: response)
                        completion(.success(feedItems))
                    } catch {
                        completion(.failure(.invalidData))
                    }
                }
                completion(.failure(.invalidData))
                
            case .failure(_):
                completion(.failure(.connectivity))
            }
        }
    }
}

private class FeedItemsMapper {
    
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
    
    static var OK_200 = 200
    
    static func map(from data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
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
