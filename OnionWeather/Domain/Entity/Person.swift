//
//  Person.swift
//  OnionWeather
//
//  Created by Jamie Chu on 11/23/21.
//

import Foundation

struct Person: Hashable {
    let name: String
    let height: String
    let mass: String
    let hairColor: String
    let skinColor: String
    let eyeColor: String
    let birthYear: String
}

extension Person {
    init(from dto: PersonDTO) {
        self.name = dto.name
        self.height = dto.height
        self.mass = dto.mass
        self.hairColor = dto.hair_color
        self.skinColor = dto.skin_color
        self.eyeColor = dto.eye_color
        self.birthYear = dto.birth_year
    }
}
