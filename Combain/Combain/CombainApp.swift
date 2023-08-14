//
//  CombainApp.swift
//  Combain
//
//  Created by Mateusz Chojnacki on 09/08/2023.
//

import SwiftUI

@main
struct CombainApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    test()
                }
        }
    }
}
