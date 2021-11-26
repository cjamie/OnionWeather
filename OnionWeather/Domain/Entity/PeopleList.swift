//
//  PeopleList.swift
//  OnionWeather
//
//  Created by Jamie Chu on 11/29/21.
//

import Foundation

struct PeopleList {
    let next: URL?
    let previous: URL?
    var results: Set<Person>
    
    mutating func removePeopleWithPurpleHair() {
        results = results.filter { $0.hairColor != "purple" }
    }
}

extension PeopleList {
    init(from dto: PeopleListDTO) {
        self.next = dto.next
        self.previous = dto.previous
        self.results = Set(dto.results.map(Person.init))
    }
}
