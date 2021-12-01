//
//  HomeFactory.swift
//  OnionWeather
//
//  Created by Jamie Chu on 11/24/21.
//

import UIKit
import Combine

final class HomeFactory {
    private var cancellables: Set<AnyCancellable> = []

    func makeNavigationController(
        selectedPerson: PassthroughSubject<PersonViewModelInputs, Never>,
        onRedViewTapped: @escaping () -> Void = {},
        currentOption: CurrentValueSubject<String, Never>,
        personDetailViewDismissal: PassthroughSubject<Void, Never>
    ) -> UINavigationController {
        let refresh = UIRefreshControl()

        let peopleTableView = UITableView().then {
            $0.register(SubtitleTableViewCell.self, forCellReuseIdentifier: SubtitleTableViewCell.reuseId)
            $0.refreshControl = refresh
        }
            
        let didScrollToBottom = PassthroughSubject<Void, Never>()
        let currentCursor = CurrentValueSubject<URL?, Never>(nil)
        let peopleSnapRepo: PeopleRepository = InMemoryPeopleRepository()
        
        let source = UITableViewDiffableDataSource<
            PeopleListHomeController.Section,
            PeopleListHomeController.Cell
        >(tableView: peopleTableView) { tv, _, item in
            switch item {
            case .person(let model):
                return (tv.dequeueReusableCell(withIdentifier: SubtitleTableViewCell.reuseId) as! SubtitleTableViewCell)
                    .then {
                        $0.textLabel?.text = model.headline
                        $0.detailTextLabel?.text = model.detail
                    }
            }
        }
        
        peopleSnapRepo
            .people
            .map(toSnapshot)
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { source.apply($0) }
            .store(in: &cancellables)

        let redView = UIView().then {
            $0.backgroundColor = .red
            $0.gesture(.tap())
                .sink { _ in onRedViewTapped() }
                .store(in: &cancellables)
        }
        
        let selectedIndexPath = PassthroughSubject<IndexPath, Never>()
        
        selectedIndexPath
            .compactMap(source.itemIdentifier)
            .sink { [weak selectedPerson] in
                switch $0 {
                case .person(let person):
                    selectedPerson?.send(person)
                }
            }.store(in: &cancellables)
                
        return UINavigationController(
            rootViewController: PeopleListHomeController(
                viewModel: PeopleListHomeViewModelImpl(
                    inputs: PeopleListHomeInputsImpl(navTitle: "Home screen"),
                    outputs: PeopleListHomeOutputsImpl(
                        selectedIndexPath: selectedIndexPath,
                        viewDidLoad: .init(),
                        didScrollToBottom: didScrollToBottom,
                        personDetailViewDismissal: personDetailViewDismissal,
                        beginRefreshing: refresh.beginRefreshingPublisher
                    ),
                    fetchUseCase: FetchPeopleListUseCase(
                        peopleSnapshotRepository: peopleSnapRepo,
                        handleEvents: {
                            currentCursor.send($0.next)
                            refresh.endRefreshing()
                        }, peopleListRepo: RemotePeopleListRepository(currentOption: { currentOption.value })
                    ),
                    paginationUseCase: PaginatePeopleUseCase(
                        peopleSnapshotRepository: peopleSnapRepo,
                        paginationCursor: currentCursor,
                        toPeopleListPublisher: { url in
                            URLSession
                                .shared
                                .dataTaskPublisher(for: url)
                                .map(\.data)
                                .decode(type: PeopleListDTO.self, decoder: JSONDecoder())
                                .map(PeopleList.init)
                                .eraseToAnyPublisher()
                        }
                    ),
                    resetListUseCase: ResetListUseCase(peopleSnapshotRepository: peopleSnapRepo)
                ).then { $0.start() },
                peopleTableView: peopleTableView,
                redView: redView
            ).then { peopleTableView.delegate = $0 }
        )
    }
    
    func makePersonDetailView(viewModel: PersonViewModel) -> UIViewController {
        PersonDetailView(viewModel: viewModel)
    }

    func makeSearchOptionView(selectedOption: CurrentValueSubject<String, Never>) -> UIViewController {
        SearchOptionView(viewModel: .init(
            outputs: SearchOptionOutputsImpl(selectedOption: selectedOption),
            inputs: SearchOptionInputsImpl(options: ["people", "planet", "starships"])
        ))
    }
    
    // MARK: - Helpers
    
    private func toSnapshot(from list: Set<Person>) -> NSDiffableDataSourceSnapshot<
        PeopleListHomeController.Section,
        PeopleListHomeController.Cell
    > {
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
