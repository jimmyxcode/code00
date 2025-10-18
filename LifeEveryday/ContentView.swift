//
//  ContentView.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 16/10/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataStore: DataStore
    @StateObject private var syncManager = SyncManager.shared
    @State private var showingAddEvent = false
    @State private var newEventName = ""
    @State private var selectedUnit: TimeUnit = .days
    
    var body: some View {
        NavigationView {
            VStack {
                // 同步按鈕
                HStack {
                    Button("LifeEveryday") { 
                        Task { await syncManager.syncNow() } 
                    }
                    .disabled(syncManager.isSyncing)
                    
                    Spacer()
                    
                    if syncManager.isSyncing {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                .padding()
                
                // 事件列表
                List {
                    ForEach(dataStore.events) { event in
                        EventRowView(event: event, dataStore: dataStore)
                    }
                    .onDelete(perform: deleteEvents)
                }
            }
            .navigationTitle("LifeEveryday")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("新增") {
                        showingAddEvent = true
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventSheet(
                    newEventName: $newEventName,
                    selectedUnit: $selectedUnit,
                    dataStore: dataStore
                )
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .dataStoreDidChange)) { _ in
            // 資料變更時自動刷新
        }
    }
    
    private func deleteEvents(offsets: IndexSet) {
        for index in offsets {
            let event = dataStore.events[index]
            dataStore.deleteEvent(id: event.id)
        }
    }
}

struct EventRowView: View {
    let event: LEEvent
    let dataStore: DataStore
    @State private var showingEntries = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(event.name)
                    .font(.headline)
                
                Spacer()
                
                Text(event.unit.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
            
            HStack {
                Button("記錄") {
                    dataStore.quickRecord(eventId: event.id)
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
                
                Button("查看記錄") {
                    showingEntries = true
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingEntries) {
            EntriesView(event: event, dataStore: dataStore)
        }
    }
}

struct AddEventSheet: View {
    @Binding var newEventName: String
    @Binding var selectedUnit: TimeUnit
    let dataStore: DataStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("事件資訊") {
                    TextField("事件名稱", text: $newEventName)
                    
                    Picker("時間單位", selection: $selectedUnit) {
                        ForEach(TimeUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                }
            }
            .navigationTitle("新增事件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("儲存") {
                        if !newEventName.isEmpty {
                            dataStore.addEvent(name: newEventName, unit: selectedUnit)
                            dismiss()
                        }
                    }
                    .disabled(newEventName.isEmpty)
                }
            }
        }
    }
}

struct EntriesView: View {
    let event: LEEvent
    let dataStore: DataStore
    @Environment(\.dismiss) private var dismiss
    
    var entries: [LEEntry] {
        dataStore.entries(for: event.id)
    }
    
    var body: some View {
        NavigationView {
            List(entries) { entry in
                VStack(alignment: .leading) {
                    Text(entry.timestamp, style: .date)
                        .font(.headline)
                    Text(entry.timestamp, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let note = entry.note, !note.isEmpty {
                        Text(note)
                            .font(.body)
                            .padding(.top, 4)
                    }
                }
                .padding(.vertical, 2)
            }
            .navigationTitle(event.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataStore.shared)
}
