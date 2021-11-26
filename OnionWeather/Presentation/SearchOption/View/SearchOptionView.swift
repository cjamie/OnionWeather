//
//  SearchOptionView.swift
//  OnionWeather
//
//  Created by Jamie Chu on 11/26/21.
//

import UIKit

final class SearchOptionView: UITableViewController {
    private let viewModel: SearchOptionViewModel

    init(viewModel: SearchOptionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        .init().then {
            $0.textLabel?.text = models[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.outputs.selectedOption.send(
            models[indexPath.row]
        )
    }
    
    // MARK: - Helpers
    
    private var models: [String] {
        viewModel.inputs.options
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
