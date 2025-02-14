//
//  ContentView.swift
//  SigmaPlus
//
//  Created by Michał Lisicki on 11/02/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(
                    colors: colorScheme == .dark
                    ? [Color(red: 50/255, green: 55/255, blue: 10/255), Color(red: 30/255, green: 25/255, blue: 5/255)]
                    : [Color(red: 200/255, green: 205/255, blue: 180/255), Color(red: 180/255, green: 96/255, blue: 78/255)]
                ),
                center: .center,
                startRadius: 3,
                endRadius: colorScheme == .dark ? 300 : 850
            )
            .ignoresSafeArea(.all)
            
            AddressesListView()
                .navigationTitle("Σ⁺ Client Data Manager")
                .navigationBarTitleDisplayMode(.inline)
                .environmentObject(viewModel)
                .toolbarBackground(.thinMaterial)
                .padding()
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
