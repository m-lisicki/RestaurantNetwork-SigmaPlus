//
//  ModifyAddressView.swift
//  SigmaPlus
//
//  Created by Michał Lisicki on 12/02/2025.
//

import SwiftUI

struct SQLData: Comparable {
    
    var addressID: Int
    var country: String
    var zipCode: String
    var city: String
    var streetAddress: String
    var buildingNumber: String
    
    init() {
        self.addressID = 0
        self.country = ""
        self.zipCode = ""
        self.city = ""
        self.streetAddress = ""
        self.buildingNumber = ""
    }
    
    init(rowToLoad: [String: Any?]) {
        self.addressID = Int(rowToLoad["AddressID"] as? Int64 ?? 0)
        self.country = rowToLoad["Country"] as? String ?? ""
        self.zipCode = rowToLoad["ZipCode"] as? String ?? ""
        self.city = rowToLoad["City"] as? String ?? ""
        self.streetAddress = rowToLoad["StreetAddress"] as? String ?? ""
        self.buildingNumber = rowToLoad["BuildingNumber"] as? String ?? ""
    }
    
    static func < (lhs: SQLData, rhs: SQLData) -> Bool {
        lhs.addressID < rhs.addressID
    }
    
    func contains(_ searchText: String) -> Bool {
        if let searchInt = Int(searchText), searchInt == addressID {
            return true
        }
        return country.localizedStandardContains(searchText) ||
        zipCode.localizedStandardContains(searchText) ||
        city.localizedStandardContains(searchText) ||
        streetAddress.localizedStandardContains(searchText)
        || buildingNumber.localizedStandardContains(searchText)
    }
}

struct ModifyAddressView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    @State var activeSQLRow = SQLData()
    
    @State var showErrorAlert = false
    @Binding var openSheet: Bool
    @State var currentError: String?
    
    @State var isUpdating = false
    var originalIndex: Int?
    
    private var isFormValid: Bool {
        !activeSQLRow.country.isEmpty &&
        !(activeSQLRow.zipCode.count < 3) &&
        !activeSQLRow.city.isEmpty
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text(isUpdating ? "Modify Address" : "Add New Address").font(.headline)) {
                    HStack {
#if os(iOS)
                        Text("ID:")
#endif
                        TextField("ID:", value: $activeSQLRow.addressID, format: .number, prompt: Text("Required"))
#if os(iOS)
                            .keyboardType(.numberPad)
#endif
                    }
                    HStack {
#if os(iOS)
                        Text("Country:")
#endif
                        TextField("Country:", text: $activeSQLRow.country, prompt: Text("Required"))
                    }
                    HStack {
#if os(iOS)
                        Text("Zip Code:")
#endif
                        TextField("Zip Code:", text: $activeSQLRow.zipCode, prompt: Text("Required (3 characters)"))
                    }
                    
                    HStack {
#if os(iOS)
                        Text("City:")
#endif
                        TextField("City:", text: $activeSQLRow.city, prompt: Text("Required"))
                    }
#if os(macOS)
                    TextField("Street Address:", text: $activeSQLRow.streetAddress)
                    TextField("Building Number:", text: $activeSQLRow.buildingNumber)
#else
                    HStack {
                        Text("Street Address:")
                        TextField("", text: $activeSQLRow.streetAddress)
                    }
                    HStack {
                        Text("Building Number:")
                        TextField("", text: $activeSQLRow.buildingNumber)
                            .keyboardType(.numberPad)
                    }
#endif
                    
                }
            }
            .scrollContentBackground(.hidden)
            HStack(spacing: 10) {
                Button("Cancel") {
                    openSheet = false
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Done") {
                    do {
                        if isUpdating {
                            try viewModel.updateAddress(oldAddressID: originalIndex!, data: activeSQLRow)
                        } else {
                            try viewModel.addAddress(data: activeSQLRow)
                        }
                    } catch {
                        currentError = "\(error)"
                        showErrorAlert = true
                        return
                    }
                    Task {
                        try await Task.sleep(for: .seconds(1))
                    }
                    viewModel.fetchAddresses()
                    openSheet = false
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isFormValid)
            }
            .databaseErrorAlert(isPresented: $showErrorAlert, error: currentError)
        }
        .padding()
    }
}

extension View {
    func databaseErrorAlert(isPresented: Binding<Bool>, error: String?) -> some View {
        self.alert("Database Error", isPresented: isPresented) {
            Button("OK") { }
                .keyboardShortcut(.defaultAction)
        } message: {
            Text(error ?? "Unexpected error.")
        }
    }
}
