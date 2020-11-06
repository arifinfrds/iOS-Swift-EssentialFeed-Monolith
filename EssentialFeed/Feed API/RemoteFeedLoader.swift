//
//  RemoteFeedLoader.swift
//  EssentialFeedApp
//
//  Created by Arifin Firdaus on 27/10/20.
//

import Foundation


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
                completion(self.map(data, response: response))
            case .failure(_):
                completion(.failure(.connectivity))
            }
        }
    }
    
    private func map(_ data: Data, response: HTTPURLResponse) -> Result {
        do {
            let feedItems = try FeedItemsMapper.map(from: data, response: response)
            return .success(feedItems)
        } catch {
            return .failure(.invalidData)
        }
    }
}
