//
//  Service.swift
//  combine-mvvm-demo
//
//  Created by trungnghia on 19/07/2022.
//

import Foundation
import Combine

protocol QuoteServiceType: AnyObject {
    func getRandomQuote() -> AnyPublisher<Quote, Error>
}

class QuoteService: QuoteServiceType {
    
    func getRandomQuote() -> AnyPublisher<Quote, Error> {
        guard let url = URL(string: "https://api.quotable.io/random") else {
            return Fail(error: ServiceError.urlError).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .catch { error in
                return Fail(error: error).eraseToAnyPublisher()
            }.map({ $0.data })
            .decode(type: Quote.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

struct Quote: Decodable {
    let content: String
    let author: String
}

enum ServiceError: Error {
    case urlError
}
