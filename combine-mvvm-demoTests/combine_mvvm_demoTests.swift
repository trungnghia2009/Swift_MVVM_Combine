//
//  combine_mvvm_demoTests.swift
//  combine-mvvm-demo
//
//  Created by trungnghia on 19/07/2022.
//

import XCTest
import Combine
@testable import combine_mvvm_demo

class combine_mvvm_demoTests: XCTestCase {
    
    var sut: QuoteViewModel!
    var quoteService: QuoteServiceType!
    private var cancellables = Set<AnyCancellable>()
    private let input: PassthroughSubject<QuoteViewModel.Input, Never> = .init()
    
    func test_getAPI_pass() {
        quoteService = MockQuoteServiceTypeFail()
        sut = QuoteViewModel(quoteServiceType: quoteService)
        let expectCalled = expectation(description: "getting data")
        
        let output = sut.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { event in
                switch event {
                case .fetchQuoteDidFail(let error):
                    print("fetchQuoteDidFail: \(error)")
                    XCTAssertEqual(error.localizedDescription, ServiceError.urlError.localizedDescription)
                    expectCalled.fulfill()
                case .toggleButton(_):
                    print("toggleButton")
                default:
                    break
                
                }
            }.store(in: &cancellables)
        
        input.send(.viewDidAppear)
        wait(for: [expectCalled], timeout: 1)
    }
    
    func test_getAPI_fail() {
        quoteService = MockQuoteServiceTypeSucceed()
        sut = QuoteViewModel(quoteServiceType: quoteService)
        let expectCalled = expectation(description: "getting data")
        
        let output = sut.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { event in
                switch event {
                case .fetchQuoteDidSucceed(let quote):
                    print("fetchQuoteDidSucceed: \(quote)")
                    XCTAssertEqual(quote.author, "Nghia")
                    XCTAssertEqual(quote.content, "abc")
                    expectCalled.fulfill()
                case .toggleButton(_):
                    print("toggleButton")
                default:
                    break
                
                }
            }.store(in: &cancellables)
        
        input.send(.refreshButtonDidTap)
        wait(for: [expectCalled], timeout: 1)
    }
}


// MARK: Mock Data
class MockQuoteServiceTypeFail: QuoteServiceType {
    func getRandomQuote() -> AnyPublisher<Quote, Error> {
        return Fail(error: ServiceError.urlError).eraseToAnyPublisher()
    }
}

class MockQuoteServiceTypeSucceed: QuoteServiceType {
    func getRandomQuote() -> AnyPublisher<Quote, Error> {
        return CurrentValueSubject(Quote(content: "abc", author: "Nghia")).eraseToAnyPublisher()
    }
}
