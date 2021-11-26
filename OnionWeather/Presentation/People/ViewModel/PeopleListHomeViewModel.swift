//
//  PeopleListHomeViewModel.swift
//  OnionWeather
//
//  Created by Jamie Chu on 11/23/21.
//

import Combine
import UIKit

protocol PeopleListHomeInputs {
    var navTitle: String { get }
}

protocol PeopleListHomeOutputs {
    var selectedIndexPath: PassthroughSubject<IndexPath, Never> { get }
    var viewDidLoad: PassthroughSubject<Void, Never> { get }
    var didScrollToBottom: PassthroughSubject<Void, Never> { get }
    var personDetailViewDismissal: PassthroughSubject<Void, Never> { get }
    var beginRefreshing: AnyPublisher<Void, Never> { get }
}

struct PeopleListHomeInputsImpl: PeopleListHomeInputs {
    let navTitle: String
}

struct PeopleListHomeOutputsImpl: PeopleListHomeOutputs {
    let selectedIndexPath: PassthroughSubject<IndexPath, Never>
    let viewDidLoad: PassthroughSubject<Void, Never>
    let didScrollToBottom: PassthroughSubject<Void, Never>
    let personDetailViewDismissal: PassthroughSubject<Void, Never>
    let beginRefreshing: AnyPublisher<Void, Never>
}

protocol PeopleListHomeViewModel {
    var inputs: PeopleListHomeInputs { get }
    var outputs: PeopleListHomeOutputs { get }
}

final class PeopleListHomeViewModelImpl: PeopleListHomeViewModel {
    let inputs: PeopleListHomeInputs
    let outputs: PeopleListHomeOutputs
    private let fetchUseCase: UseCase
    private let paginationUseCase: UseCase
    private let resetListUseCase: UseCase

    private var cancellables: Set<AnyCancellable> = []
    
    init(
        inputs: PeopleListHomeInputs,
        outputs: PeopleListHomeOutputs,
        fetchUseCase: UseCase,
        paginationUseCase: UseCase,
        resetListUseCase: UseCase
    ) {
        self.inputs = inputs
        self.outputs = outputs
        self.fetchUseCase = fetchUseCase
        self.paginationUseCase = paginationUseCase
        self.resetListUseCase = resetListUseCase
    }

    func start() {
        Publishers
            .Merge(
                outputs.viewDidLoad.eraseToAnyPublisher(),
                outputs.beginRefreshing
            )
            .sink(receiveValue: fetchUseCase.start)
            .store(in: &cancellables)
        
        outputs
            .didScrollToBottom
            .sink(receiveValue: paginationUseCase.start)
            .store(in: &cancellables)
        
        outputs
            .personDetailViewDismissal
            .sink { [weak self] in
                self?.resetListUseCase.start()
                self?.fetchUseCase.start()
            }.store(in: &cancellables)
    }
}
