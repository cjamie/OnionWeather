//
//  PaginatedPeopleUseCase.swift
//  OnionWeather
//
//  Created by Jamie Chu on 11/23/21.
//

import Combine
import Foundation

final class PaginatedPeopleUseCase: UseCase {
    private var cancelable: AnyCancellable?
    private let peopleSnapshotRepository: PeopleSnapshotRepository
    private let paginationCursor: CurrentValueSubject<URL?, Never>

    init(
        peopleSnapshotRepository: PeopleSnapshotRepository,
        paginationCursor: CurrentValueSubject<URL?, Never>
    ) {
        self.paginationCursor = paginationCursor
        self.peopleSnapshotRepository = peopleSnapshotRepository
    }
    
    func start() {
        cancelable = paginationCursor
            .value
            .publisher
            .flatMap(URLSession.shared.dataTaskPublisher)
            .map(\.data)
            .decode(type: PeopleListDTO.self, decoder: JSONDecoder())
            .handleEvents(receiveOutput: { [weak self] in self?.paginationCursor.send($0.next) })
            .map(toSetOfPeople)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in
                    self?.peopleSnapshotRepository.addPeople($0)
                }
            )
    }
    
    private func toSetOfPeople(from: PeopleListDTO) -> Set<Person> {
        from.results.reduce(into: []) { $0.insert(.init(from: $1)) }
    }
}
