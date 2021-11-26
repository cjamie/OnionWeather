//
//  SearchOptionViewModel.swift
//  OnionWeather
//
//  Created by Jamie Chu on 11/26/21.
//

import Foundation
import Combine

protocol SearchOptionOutputs {
    var selectedOption: CurrentValueSubject<String, Never> { get }
}

protocol SearchOptionInputs {
    var options: [String] { get }
}

struct SearchOptionOutputsImpl: SearchOptionOutputs {
    let selectedOption: CurrentValueSubject<String, Never>
}

struct SearchOptionInputsImpl: SearchOptionInputs {
    let options: [String]
}

struct SearchOptionViewModel {
    let outputs: SearchOptionOutputs
    let inputs: SearchOptionInputs
}
