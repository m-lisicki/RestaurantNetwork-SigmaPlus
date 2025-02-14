//
//  ViewModel.swift
//  SigmaPlus
//
//  Created by Michał Lisicki on 11/02/2025.
//

import Foundation
import SQLite
import OSLog

let log = Logger()

class ViewModel: ObservableObject {
    
    var db: Connection?
    @Published var addresses = [SQLData]()
    @Published var chosenIndex = 0
    
    @Published var sort = false
    
    init() {
        do {
            db = try Connection(.temporary)
            log.info("Database connected successfully")
            
            createTables()
            insertSampleData()
        } catch {
            db = nil
            log.error("Database connection error: \(error)")
        }
    }
    
    // MARK: - SQL Queries
    
    func createTables() {
        do {
            try db?.execute(
            """
            CREATE TABLE Address (
                AddressID INT PRIMARY KEY,
                Country NVARCHAR(50) NOT NULL,
                ZipCode NVARCHAR(20) NOT NULL,
                City NVARCHAR(100) NOT NULL,
                StreetAddress NVARCHAR(200),
                BuildingNumber NVARCHAR(20),
                CONSTRAINT CHK_ZipCode CHECK (LENGTH(ZipCode) >= 3)
            );
            """
            )
            log.info("Tables created successfully")
        } catch {
            log.error("Can't create tables: \(error)")
        }
    }
    
    func insertSampleData() {
        do {
            try db?.execute(
            """
            INSERT INTO Address (AddressID, Country, ZipCode, City, StreetAddress, BuildingNumber) VALUES
            (1, 'Poland', '30-059', 'Kraków', 'Rynek Główny', '1'),
            (2, 'Poland', '00-001', 'Warszawa', 'Aleje Jerozolimskie', '101'),
            (3, 'Poland', '80-800', 'Gdańsk', 'Długa', '13'),
            (4, 'Poland', '31-001', 'Kraków', 'Floriańska', '15'),
            (5, 'Poland', '30-063', 'Kraków', 'Jana Pawła II', '2'),
            (6, 'USA', '90210', 'Beverly Hills', 'Rodeo Drive', '100'),
            (7, 'UK', 'SW1A 2AA', 'London', 'Buckingham Palace', '1');
            """
            )
            log.info("Sample data inserted successfully")
        } catch {
            log.error("Inserting of sample data error: \(error)")
        }
    }
    
    func addAddress(data: SQLData) throws {
        var query = """
            INSERT INTO Address (AddressID, Country, ZipCode, City, StreetAddress, BuildingNumber) VALUES
            (?, ?, ?, ?, 
            """
        if data.streetAddress.isEmpty {
            query.append("NULL, ")
        } else {
            query.append(" '\(data.streetAddress)', ")
        }
        if data.buildingNumber.isEmpty {
            query.append("NULL);")
        } else {
            query.append(" '\(data.buildingNumber)');")
        }
        try db?.run(query, data.addressID, data.country, data.zipCode, data.city)
        log.info("Address added successfully")
    }
    
    func deleteAddress(addressID: Int) throws {
        let query = "DELETE FROM Address WHERE AddressID = ?;"
        try db?.run(query, addressID)
        log.info("Address deleted successfully")
    }
    
    func updateAddress(oldAddressID: Int, data: SQLData) throws {
        var updates = [String]()
        
        updates.append("AddressID = '\(data.addressID)'")
        updates.append("Country = '\(data.country)'")
        updates.append("ZipCode = '\(data.zipCode)'")
        updates.append("City = '\(data.city)'")
        
        if data.streetAddress.isEmpty {
            updates.append("StreetAddress = NULL")
        } else {
            updates.append("StreetAddress = '\(data.streetAddress)'")
        }
        
        if data.buildingNumber.isEmpty {
            updates.append("BuildingNumber = NULL")
        } else {
            updates.append("BuildingNumber = '\(data.buildingNumber)'")
        }
        
        let updateQuery = updates.joined(separator: ", ")
        let query = "UPDATE Address SET \(updateQuery) WHERE AddressID = \(oldAddressID);"
        log.info("\(query)")
        try db?.execute(query)
        log.info("Address updated successfully")
    }
    
    func fetchAddresses() {
        addresses = [SQLData]()

        do {
            let query = "SELECT * FROM Address;"
            let stmt = try db?.prepare(query)
            for row in stmt! {
                var addressDetails = [String: Any?]()
                for (index, columnName) in stmt!.columnNames.enumerated() {
                    addressDetails[columnName] = row[index]
                }
                let address = SQLData(rowToLoad: addressDetails)
                addresses.append(address)
            }
            if sort {
                sortAddresses()
            }
        } catch {
            log.error("Fetching addresses error: \(error)")
        }
    }
    
    func sortAddresses() {
        addresses = addresses.sorted()
    }
}
