//
//  Coordinator.swift
//  OnionWeather
//
//  Created by Jamie Chu on 11/23/21.
//

import UIKit

protocol Coordinator: AnyObject {
    var children: [Coordinator] { get set }
    var navigationController: UINavigationController { get }
    func start()
}
