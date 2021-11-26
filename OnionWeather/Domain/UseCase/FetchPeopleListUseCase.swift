//
//  FetchPeopleListUseCase.swift
//  OnionWeather
//
//  Created by Jamie Chu on 11/23/21.
//

import Combine
import Foundation

final class FetchPeopleListUseCase: UseCase {
    private var cancelable: AnyCancellable?
    private let peopleSnapshotRepository: PeopleRepository
    private let handleEvents: (PeopleList) -> Void
    private let peopleListRepo: PeopleListRepository

    init(
        peopleSnapshotRepository: PeopleRepository,
        handleEvents: @escaping (PeopleList) -> Void,
        peopleListRepo: PeopleListRepository
    ) {
        self.peopleSnapshotRepository = peopleSnapshotRepository
        self.handleEvents = handleEvents
        self.peopleListRepo = peopleListRepo
    }
    
    func start() {
        cancelable = peopleListRepo
            .getPeopleList
            .handleEvents(receiveOutput: { [weak self] in self?.handleEvents($0) })
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.peopleSnapshotRepository.setPeople(Set($0.results)) }
            )
    }
}
