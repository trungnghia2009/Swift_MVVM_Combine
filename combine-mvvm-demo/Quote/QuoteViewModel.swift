//
//  QuoteViewModel.swift
//  combine-mvvm-demo
//
//  Created by trungnghia on 19/07/2022.
//

import Combine
import Foundation

class QuoteViewModel {
    
    enum Input {
        case viewDidAppear
        case refreshButtonDidTap
    }
    
    enum Output {
        case fetchQuoteDidFail(error: Error)
        case fetchQuoteDidSucceed(quote: Quote)
        case toggleButton(isEnabled: Bool)
    }
    
    private let quoteServiceType: QuoteServiceType
    private let output = PassthroughSubject<Output, Never>()
    //private let output1 = CurrentValueSubject<Output, Never>(.toggleButton(isEnabled: true))
    private var cancellables = Set<AnyCancellable>()
        
    init(quoteServiceType: QuoteServiceType = QuoteService()) {
        self.quoteServiceType = quoteServiceType
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidAppear:
                self?.handleGetRandomQuote()
            case .refreshButtonDidTap:
                self?.handleGetRandomQuote()
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    private func handleGetRandomQuote() {
        output.send(.toggleButton(isEnabled: false))
        quoteServiceType.getRandomQuote().sink { [weak self] completion in
            self?.output.send(.toggleButton(isEnabled: true))
            if case .failure(let error) = completion {
                self?.output.send(.fetchQuoteDidFail(error: error))
            }
        } receiveValue: { [weak self] quote in
            self?.output.send(.fetchQuoteDidSucceed(quote: quote))
        }.store(in: &cancellables)
    }
}
