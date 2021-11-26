//
//  ResetListUseCase.swift
//  OnionWeather
//
//  Created by Jamie Chu on 11/26/21.
//

import Foundation

final class ResetListUseCase: UseCase {
    private let peopleSnapshotRepository: PeopleRepository

    init(peopleSnapshotRepository: PeopleRepository) {
        self.peopleSnapshotRepository = peopleSnapshotRepository
    }
    
    func start() {
        peopleSnapshotRepository.clearAll()
    }
}
