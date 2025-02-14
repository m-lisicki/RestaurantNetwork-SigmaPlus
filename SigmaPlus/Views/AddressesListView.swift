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
    
    var body: some View {
        List(viewModel.addresses.indices, id: \.self) { index in
            VStack(alignment: .leading, spacing: 4) {
                let address = viewModel.addresses[index]
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
                        .font(.body)
                }
                if !address.buildingNumber.isEmpty {
                    Text("Building: \(address.buildingNumber)")
                        .font(.body)
                }
            }
            .padding()
            .swipeActions {
                Button("Delete") {
                    do {
                        try viewModel.deleteAddress(addressID: viewModel.addresses[index].addressID)
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
        .scrollContentBackground(.hidden)
        .background(.thinMaterial)
        .cornerRadius(7)
        .toolbar {
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
            ModifyAddressView(activeSQLRow: viewModel.addresses[viewModel.chosenIndex], openSheet: $isModifierSheetOpen, isUpdating: true, originalIndex: viewModel.addresses[viewModel.chosenIndex].addressID)
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
