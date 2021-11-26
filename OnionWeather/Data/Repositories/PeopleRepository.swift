//
//  PeopleSnapshotRepository.swift
//  OnionWeather
//
//  Created by Jamie Chu on 11/26/21.
//

import Foundation
import Combine

protocol PeopleRepository {
    var people: Published<Set<Person>>.Publisher  { get }

    func setPeople(_ people: Set<Person>)
    func addPeople(_ morePeople: Set<Person>)
}

extension PeopleRepository {
    func clearAll() {
        setPeople([])
    }
}

final class InMemoryPeopleRepository: PeopleRepository {
    @Published private var _people: Set<Person> = []
    
    var people: Published<Set<Person>>.Publisher  { $_people }
    
    func setPeople(_ people: Set<Person>) {
        self._people = people
    }
    
    func addPeople(_ morePeople: Set<Person>) {
        self._people = self._people.union(morePeople)
    }
}

