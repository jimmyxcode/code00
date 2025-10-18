//
//  QuickRecordForEventSheet.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 16/10/2025.
//

import SwiftUI

struct QuickRecordForEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: DataStore = .shared
    
    let event: LEEvent
    @State private var note = ""
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Event") {
                    Text(event.name)
                        .font(.headline)
                }
                
                Section("Record Details") {
                    DatePicker("Date & Time", selection: $selectedDate)
                    
                    TextField("Note (Optional)", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Record Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Record") {
                        print("🟦 QuickRecordForEventSheet: Record button tapped for event:", event.id.uuidString, event.name)
                        store.quickRecord(eventId: event.id, at: selectedDate, note: note.isEmpty ? nil : note)
                        print("🟦 QuickRecordForEventSheet: After quickRecord call")
                        dismiss()
                    }
                }
            }
        }
    }
}
