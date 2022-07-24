//
//  QuoteViewController.swift
//  combine-mvvm-demo
//
//  Created by trungnghia on 19/07/2022.
//

import UIKit
import Combine

class QuoteViewController: UIViewController {
    
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    
    private let vm = QuoteViewModel()
    private let input = PassthroughSubject<QuoteViewModel.Input, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshButton.isEnabled = false
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input.send(.viewDidAppear)
    }
    
    private func bind() {
        let output = vm.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .fetchQuoteDidSucceed(let quote):
                    self?.quoteLabel.text = quote.content + "\n" + "- " + quote.author + " -"
                case .fetchQuoteDidFail(let error):
                    self?.quoteLabel.text = error.localizedDescription
                case .toggleButton(let isEnabled):
                    self?.refreshButton.isEnabled = isEnabled
                }
            }.store(in: &cancellables)
        
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        input.send(.refreshButtonDidTap)
    }
}
