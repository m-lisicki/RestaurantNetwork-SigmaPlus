//
//  ContentView.swift
//  SigmaPlus
//
//  Created by Michał Lisicki on 11/02/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: [Color(red: 72/255, green: 75/255, blue: 7/255), Color(red: 47/255, green: 33/255, blue: 4/255)]), center: .center, startRadius: 2, endRadius: 400)
                .ignoresSafeArea(.all)
            
            VStack {
                AddressesListView()
            }
            .navigationTitle("Σ⁺ Client Data Manager")
            .toolbarBackground(.thinMaterial)
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .padding()
        }
    }
}
