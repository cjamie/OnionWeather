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
    private let currentCursor:  CurrentValueSubject<URL?, Never>
    private let peopleSnapshotRepository: PeopleSnapshotRepository

    init(
        peopleSnapshotRepository: PeopleSnapshotRepository,
        currentCursor: CurrentValueSubject<URL?, Never>
    ) {
        self.peopleSnapshotRepository = peopleSnapshotRepository
        self.currentCursor = currentCursor
    }
    
    func start() {
        cancelable = URLSession
            .shared
            .dataTaskPublisher(for: URLRequest(
                url: URL(string: "https://swapi.dev/api/people")!,
                cachePolicy: .returnCacheDataElseLoad,
                timeoutInterval: 10
            ))
            .map(\.data)
            .decode(type: PeopleListDTO.self, decoder: JSONDecoder())
            .handleEvents(receiveOutput: { [weak self] in self?.currentCursor.send($0.next) })
            .map(toSetOfPeople)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.peopleSnapshotRepository.setPeople($0) }
            )
    }
    
    private func toSetOfPeople(from: PeopleListDTO) -> Set<Person> {
        from.results.reduce(into: []) { $0.insert(.init(from: $1)) }
    }
}
