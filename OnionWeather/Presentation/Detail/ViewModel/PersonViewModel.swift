//
//  PersonViewModel.swift
//  OnionWeather
//
//  Created by Jamie Chu on 11/26/21.
//

import Foundation
import Combine

struct PersonViewModelInputs: Hashable {
    let headline: String
    let detail: String
}

struct PersonViewModelOutputs: Equatable {
    let personDetailViewDismissal:  PassthroughSubject<Void, Never>
    
    static func == (lhs: PersonViewModelOutputs, rhs: PersonViewModelOutputs) -> Bool {
        true
    }
}

struct PersonViewModel: Hashable {
    let inputs: PersonViewModelInputs
    let outputs: PersonViewModelOutputs
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(inputs)
    }
}


