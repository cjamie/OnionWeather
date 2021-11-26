//
//  PeopleListRepository.swift
//  OnionWeather
//
//  Created by Jamie Chu on 11/29/21.
//

import Foundation
import Combine

protocol PeopleListRepository {
    var getPeopleList: AnyPublisher<PeopleList, Never> { get }
}

final class RemotePeopleListRepository: PeopleListRepository {
    private let currentOption: () -> String
    private(set) lazy var getPeopleList: AnyPublisher<PeopleList, Never> = URLSession
        .shared
        .dataTaskPublisher(for: .init(
            url: URL(
                string: "https://swapi.dev/api/\(self.currentOption())")!,
            cachePolicy: .returnCacheDataElseLoad,
            timeoutInterval: 10
        ))
        .map(\.data)
        .decode(type: PeopleListDTO.self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .map(PeopleList.init)
        .catch{ _ in Empty() }
        .eraseToAnyPublisher()

    init(currentOption: @escaping () -> String) {
        self.currentOption = currentOption
    }
}
