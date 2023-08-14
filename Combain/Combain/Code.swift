//
//  Code.swift
//  Combain
//
//  Created by Mateusz Chojnacki on 09/08/2023.
//

import Foundation
import Combine

var cancellables = Set<AnyCancellable>()

func test() {
    Just(42)
        .delay(for: 1, scheduler: DispatchQueue.main)
        .sink { value in
            print(value)
        }
        .store(in: &cancellables)
}
