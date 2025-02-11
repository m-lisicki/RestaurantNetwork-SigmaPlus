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
    @State var chosenIndex = 0
    
    @State var showErrorAlert = false
    @State var currentError: String?
    
    var body: some View {
        List(viewModel.addresses.indices, id: \.self) { index in
            VStack(alignment: .leading) {
                ForEach(viewModel.addresses[index].keys.sorted(), id: \.self) { key in
                    if let value = viewModel.addresses[index][key] {
                        Text("\(key): \(value ?? "NULL")")
                    }
                }
            }
            .swipeActions {
                Button("Delete") {
                    do {
                        try viewModel.deleteAddress(addressID: Int(viewModel.addresses[index]["AddressID"] as! Int64))
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
                    isModifierSheetOpen = true
                    chosenIndex = index
                }
                .tint(.accentColor)
            }
            .padding()
        }
        .scrollContentBackground(.hidden)
        .background(.thinMaterial)
        .cornerRadius(7)
        .toolbar {
            ToolbarItem {
                Button(action: {
                    isAddSheetOpen = true
                }) {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .databaseErrorAlert(isPresented: $showErrorAlert, error: currentError)
        .onAppear() {
            viewModel.fetchAddresses()
        }
        .sheet(isPresented: $isModifierSheetOpen) {
            if let addressID = viewModel.addresses[chosenIndex]["AddressID"] as? Int64 {
                ModifyAddressView(activeSQLRow: SQLData(rowToLoad: viewModel.addresses[chosenIndex]), openSheet: $isModifierSheetOpen, isUpdating: true, originalIndex: Int(addressID))
                    .presentationBackground(.thinMaterial)
                    .presentationDetents([.medium])
            }
        }
        .sheet(isPresented: $isAddSheetOpen) {
            ModifyAddressView(openSheet: $isAddSheetOpen)
                .presentationBackground(.thinMaterial)
                .presentationDetents([.medium])
        }
    }
}
