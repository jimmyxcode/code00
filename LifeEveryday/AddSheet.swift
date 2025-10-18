//
//  AddSheet.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 16/10/2025.
//

import SwiftUI

struct AddSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: DataStore = .shared
    
    @State private var eventName = ""
    @State private var selectedUnit: TimeUnit = .days
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Event Details") {
                    TextField("Event Name", text: $eventName)
                        .textInputAutocapitalization(.words)
                    
                    Picker("Time Unit", selection: $selectedUnit) {
                        ForEach(TimeUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                }
            }
            .navigationTitle("Add Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.addEvent(name: eventName, unit: selectedUnit)
                        dismiss()
                    }
                    .disabled(eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
