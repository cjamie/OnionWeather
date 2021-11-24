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
        selectedPerson: PassthroughSubject<PersonViewModel, Never>,
        onRedViewTapped: @escaping () -> Void = {}
    ) -> UINavigationController {
        let peopleTableView = UITableView().then {
            $0.register(SubtitleTableViewCell.self, forCellReuseIdentifier: SubtitleTableViewCell.reuseId)
        }
            
        let didScrollToBottom = PassthroughSubject<Void, Never>()
        let currentCursor = CurrentValueSubject<URL?, Never>(nil)
        let peopleSnapRepo = PeopleSnapshotRepositoryImpl()
        
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
            .snapshot
            .dropFirst()
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
                        didScrollToBottom: didScrollToBottom
                    ),
                    fetchUseCase: FetchPeopleListUseCase(
                        peopleSnapshotRepository: peopleSnapRepo,
                        currentCursor: currentCursor
                    ),
                    paginationUseCase: PaginatedPeopleUseCase(
                        peopleSnapshotRepository: peopleSnapRepo,
                        paginationCursor: currentCursor
                    )
                ).then { $0.start() },
                peopleTableView: peopleTableView,
                redView: redView
            ).then { peopleTableView.delegate = $0 }
        )
    }
    
    func makePersonDetailView(viewModel: PersonViewModel) -> UIViewController {
        PersonDetailView(viewModel: viewModel)
    }
}
