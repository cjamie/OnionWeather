//
//  PersonDetailView.swift
//  OnionWeather
//
//  Created by Jamie Chu on 11/25/21.
//

import UIKit

final class PersonDetailView: UIViewController {
    private let viewModel: PersonViewModel

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        
        let mainLabel = UILabel().then {
            $0.textColor = .systemPink
            $0.numberOfLines = 0
            $0.text = viewModel.inputs.headline
        }

        view.addSubview(mainLabel)

        mainLabel.snp.makeConstraints {
            $0.width.equalTo(view.snp.width).multipliedBy(0.8)
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    init(viewModel: PersonViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        viewModel.outputs.personDetailViewDismissal.send()
    }
}
