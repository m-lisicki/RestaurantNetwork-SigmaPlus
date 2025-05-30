//
//  AddressesListView.swift
//  SigmaPlus
//
//  Created by Michał Lisicki on 12/02/2025.
//

import SwiftUI

struct AddressesListView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State var isAddSheetOpen = false
    @State var isModifierSheetOpen = false
    
    @State var showErrorAlert = false
    @State var currentError: String?
    
    @State private var searchText = ""
    
    var searchResults: [SQLData] {
        if searchText.isEmpty {
            return viewModel.addresses
        } else {
            return viewModel.addresses.filter { $0.contains(searchText) }
        }
    }

    
    var body: some View {
        List(searchResults.indices, id: \.self) { index in
            VStack(alignment: .leading, spacing: 4) {
                let address = searchResults[index]
                Text("ID: \(address.addressID)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Country: \(address.country)")
                    .font(.headline)
                Text("Zip Code: \(address.zipCode)")
                    .font(.subheadline)
                Text("City: \(address.city)")
                    .font(.subheadline)
                if !address.streetAddress.isEmpty {
                    Text("Street: \(address.streetAddress)")
                        .font(.subheadline)
                }
                if !address.buildingNumber.isEmpty {
                    Text("Building: \(address.buildingNumber)")
                        .font(.subheadline)
                }
            }
            .padding()
            .swipeActions {
                Button("Delete") {
                    do {
                        try viewModel.deleteAddress(addressID: searchResults[index].addressID)
                    } catch {
                        currentError = "\(error)"
                        showErrorAlert = true
                        return
                    }
                    viewModel.fetchAddresses()
                }
                .tint(.red)
            }
            .swipeActions {
                Button("Modify") {
                    viewModel.chosenIndex = index
                    isModifierSheetOpen = true
                }
                .tint(.accentColor)
            }
            .padding()
        }
        .searchable(text: $searchText)
        .scrollContentBackground(.hidden)
        .background(.thinMaterial)
        .cornerRadius(7)
        .toolbar {
            Button(action: {
                viewModel.sort.toggle()
                viewModel.fetchAddresses()
            }) {
                Label("Sort", systemImage: viewModel.sort ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
            }
            Button(action: {
                isAddSheetOpen = true
            }) {
                Label("Add", systemImage: "plus.circle.fill")
            }
        }
        .databaseErrorAlert(isPresented: $showErrorAlert, error: currentError)
        .onAppear() {
            viewModel.fetchAddresses()
        }
        .sheet(isPresented: $isModifierSheetOpen) {
            ModifyAddressView(activeSQLRow: searchResults[viewModel.chosenIndex], openSheet: $isModifierSheetOpen, isUpdating: true, originalIndex: searchResults[viewModel.chosenIndex].addressID)
                .presentationBackground(.thinMaterial)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $isAddSheetOpen) {
            ModifyAddressView(openSheet: $isAddSheetOpen)
                .presentationBackground(.thinMaterial)
                .presentationDetents([.medium])
        }
    }
}
