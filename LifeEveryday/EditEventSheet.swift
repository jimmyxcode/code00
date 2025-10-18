//
//  EditEventSheet.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 16/10/2025.
//

import SwiftUI
import Foundation

struct EditEventSheet: View {
    let event: LEEvent
    @Environment(\.dismiss) private var dismiss
    
    // 取得 entries（由新到舊）
    private var entries: [Date] {
        DataStore.shared.entries(for: event.id).map { $0.timestamp }
    }
    private var unit: StatsUnit {
        switch event.unit {
        case .minutes: return .minutes
        case .hours:   return .hours
        case .days:    return .days
        case .months:  return .months
        }
    }
    private var stats: EventStats {
        StatsEngine.compute(
            createdAt: event.createdAt,
            entries: entries,
            preferredUnit: unit
        )
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Event 資訊
                Section("Event") {
                    Text("Name: \(event.name)")
                    Text("Unit: \(event.unit.rawValue)")
                }
                
                // Statistics 資訊
                Section("Statistics") {
                    HStack {
                        Text("Last")
                        Spacer()
                        Text(stats.lastDate.map { $0.formatted(date: .abbreviated, time: .omitted) } ?? "—")
                    }
                    
                    HStack {
                        Text("Average")
                        Spacer()
                        if let avg = stats.avgIntervalDays {
                            Text(StatsEngine.formatInterval(avg, unit: unit))
                                .fontWeight(.semibold)
                        } else {
                            Text("—")
                        }
                    }
                    
                       HStack {
                           Text((stats.dueInDays ?? 0) >= 0 ? "Countdown" : "Overdue")
                           Spacer()
                           let due = abs(stats.dueInDays ?? 0)
                           Text(due == 0 ? "Due today" : StatsEngine.formatInterval(due, unit: unit))
                               .foregroundStyle((stats.dueInDays ?? 0) < 0 ? .red : .primary)
                               .fontWeight(.semibold)
                       }
                    
                    HStack {
                        Text("Total Entries")
                        Spacer()
                        Text("\(stats.totalCount)")
                            .fontWeight(.semibold)
                    }
                }
            }
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}