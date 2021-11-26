//
//  PersonDTO.swift
//  OnionWeather
//
//  Created by Jamie Chu on 11/23/21.
//

import Foundation

struct PersonDTO: Decodable {
    let name: String
    let height: String
    let mass: String
    let hair_color: String
    let skin_color: String
    let eye_color: String
    let birth_year: String
    let gender: String
    let homeworld: String
    let films: [String]
    let species: [String]
    let vehicles: [String]
    let starships: [String]
    let created: String
    let edited: String
    let url: URL
}

struct PeopleListDTO: Decodable {
    let count: Int
    let next: URL?
    let previous: URL?
    let results: [PersonDTO]
}
