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
    let navigationController: UINavigationController
    private let factory: HomeFactory
    private let window: UIWindow
    private let selectedPerson = PassthroughSubject<PersonViewModel, Never>()
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
        self.navigationController = factory.makeNavigationController(selectedPerson: selectedPerson)
    }
    
    private func goToDetailView(person: PersonViewModel) {
        navigationController.pushViewController(
            factory.makePersonDetailView(viewModel: person),
            animated: true
        )
    }
}

final class PersonDetailView: UIViewController {
    private let viewModel: PersonViewModel

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        
        let mainLabel = UILabel()
        mainLabel.textColor = .systemPink

        view.addSubview(mainLabel)

        mainLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        mainLabel.text = viewModel.headline
    }
    
    init(viewModel: PersonViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
