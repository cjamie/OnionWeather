//
//  ViewController.swift
//  OnionWeather
//
//  Created by Jamie Chu on 11/23/21.
//

import UIKit
import SnapKit
import Combine

class PeopleListHomeController: UIViewController {
    private let viewModel: PeopleListHomeViewModel
    private let peopleTableView: UITableView
    private let redView: UIView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        viewModel.outputs.viewDidLoad.send()
        title = viewModel.inputs.navTitle
        setupView()
    }
    
    init(
        viewModel: PeopleListHomeViewModel,
        peopleTableView: UITableView,
        redView: UIView
    ) {
        self.viewModel = viewModel
        self.peopleTableView = peopleTableView
        self.redView = redView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupView() {
        view.addSubview(peopleTableView)
        peopleTableView.snp.makeConstraints { $0.left.right.top.equalToSuperview() }
        redView.backgroundColor = .red
        view.addSubview(redView)
        redView.snp.makeConstraints { make in
            make.top.equalTo(peopleTableView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(30)
        }
    }
}

extension PeopleListHomeController {
    enum Section: Hashable {
        case main
    }
    
    enum Cell: Hashable {
        case person(PersonViewModelInputs)
    }
}

extension PeopleListHomeController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.outputs.selectedIndexPath.send(indexPath)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if maximumOffset - currentOffset <= 10 {
            viewModel.outputs.didScrollToBottom.send()
        }
    }
}
