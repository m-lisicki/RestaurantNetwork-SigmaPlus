//
//  SigmaPlusApp.swift
//  SigmaPlus
//
//  Created by Michał Lisicki on 11/02/2025.
//

import SwiftUI

@main
struct SigmaPlusApp: App {
    @StateObject var viewModel = ViewModel()
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .environmentObject(viewModel)
        }
    }
}
