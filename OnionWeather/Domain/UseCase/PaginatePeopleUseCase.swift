//
//  PaginatedPeopleUseCase.swift
//  OnionWeather
//
//  Created by Jamie Chu on 11/23/21.
//

import Combine
import Foundation

final class PaginatePeopleUseCase: UseCase {
    private var cancelable: AnyCancellable?
    private let peopleSnapshotRepository: PeopleRepository
    private let paginationCursor: CurrentValueSubject<URL?, Never>
    private let toPeopleListPublisher: (URL) -> AnyPublisher<PeopleList, Error>
    
    init(
        peopleSnapshotRepository: PeopleRepository,
        paginationCursor: CurrentValueSubject<URL?, Never>,
        toPeopleListPublisher: @escaping (URL) -> AnyPublisher<PeopleList, Error>
    ) {
        self.paginationCursor = paginationCursor
        self.peopleSnapshotRepository = peopleSnapshotRepository
        self.toPeopleListPublisher = toPeopleListPublisher
    }
    
    func start() {
        cancelable = paginationCursor
            .value
            .publisher
            .flatMap(toPeopleListPublisher)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in
                    self?.paginationCursor.send($0.next)
                    self?.peopleSnapshotRepository.addPeople(Set($0.results))
                }
            )
    }
}
