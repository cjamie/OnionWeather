//
//  AppCoordinator.swift
//  OnionWeather
//
//  Created by Jamie Chu on 11/23/21.
//

import UIKit
import Combine

final class AppCoordinator: Coordinator {
    var children: [Coordinator]

    private(set) lazy var navigationController: UINavigationController = factory.makeNavigationController(
        selectedPerson: selectedPerson,
        onRedViewTapped: navigateToSearchOptionView(),
        currentOption: selectedOption,
        personDetailViewDismissal: personDetailViewDismissal
    )

    private let factory: HomeFactory
    private let window: UIWindow
    private let selectedPerson = PassthroughSubject<PersonViewModelInputs, Never>()
    private let selectedOption = CurrentValueSubject<String, Never>("people")
    private let personDetailViewDismissal = PassthroughSubject<Void, Never>()
    private var cancelables: Set<AnyCancellable> = []
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
     
        selectedPerson
            .sink { [weak self] in self?.goToDetailView(person: $0) }
            .store(in: &cancelables)
    }

    // MARK: - Init
    
    init(factory: HomeFactory, window: UIWindow) {
        self.factory = factory
        self.children = []
        self.window = window
    }
    
    private func goToDetailView(person: PersonViewModelInputs) {
        navigationController.present(
            factory.makePersonDetailView(viewModel: .init(
                inputs: person,
                outputs: .init(personDetailViewDismissal: personDetailViewDismissal)
            )),
            animated: true
        )
    }
    
    private func navigateToSearchOptionView() -> () -> Void {
        {
            [weak self] in
            guard let self = self else { return }
            self.navigationController.present(
                self.factory.makeSearchOptionView(selectedOption: self.selectedOption),
                animated: true
            )
        }
    }
}
