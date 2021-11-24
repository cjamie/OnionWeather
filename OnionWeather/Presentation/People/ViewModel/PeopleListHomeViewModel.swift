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
}

struct PeopleListHomeInputsImpl: PeopleListHomeInputs {
    let navTitle: String
}

struct PeopleListHomeOutputsImpl: PeopleListHomeOutputs {
    let selectedIndexPath: PassthroughSubject<IndexPath, Never>
    let viewDidLoad: PassthroughSubject<Void, Never>
    let didScrollToBottom: PassthroughSubject<Void, Never>
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

    private var cancellables: Set<AnyCancellable> = []
    
    init(
        inputs: PeopleListHomeInputs,
        outputs: PeopleListHomeOutputs,
        fetchUseCase: UseCase,
        paginationUseCase: UseCase
    ) {
        self.inputs = inputs
        self.outputs = outputs
        self.fetchUseCase = fetchUseCase
        self.paginationUseCase = paginationUseCase
    }

    func start() {
        outputs
            .viewDidLoad
            .sink(receiveValue: fetchUseCase.start)
            .store(in: &cancellables)

        outputs
            .didScrollToBottom
            .sink(receiveValue: paginationUseCase.start)
            .store(in: &cancellables)
    }
}

protocol PeopleSnapshotRepository {
    typealias Snapshot = NSDiffableDataSourceSnapshot<
        PeopleListHomeController.Section,
        PeopleListHomeController.Cell
    >

    var snapshot: AnyPublisher<Snapshot, Never> { get }

    func setPeople(_ people: Set<Person>)
    func addPeople(_ morePeople: Set<Person>)
}

final class PeopleSnapshotRepositoryImpl: PeopleSnapshotRepository {
    @Published private var people: Set<Person> = []

    var snapshot: AnyPublisher<Snapshot, Never> {
        $people
            .map(toSnapshot)
            .eraseToAnyPublisher()
    }
    
    func setPeople(_ people: Set<Person>) {
        print("-=- setting \(people.count) \(people.map(\.name))")
        self.people = people
    }
    
    func addPeople(_ morePeople: Set<Person>) {
        print("-=- adding \(people.count) \(people.map(\.name))")

        self.people = self.people.union(morePeople)
    }

    private func toSnapshot(from list: Set<Person>) -> Snapshot {
        .init().with {
            $0.appendSections([.main])
            $0.appendItems(
                list
                    .sorted(by: {$0.name < $1.name})
                    .map { .person(.init(
                        headline: [
                            $0.name,
                            $0.height,
                            $0.hairColor,
                            $0.skinColor,
                            $0.eyeColor
                        ].joined(separator: ", "),
                        detail: [
                            "Mass: \($0.mass)",
                            "Date of birth: \($0.birthYear)",
                        ].joined(separator: ", ")
                    )) }
                ,
                toSection: .main
            )
        }
    }
}
