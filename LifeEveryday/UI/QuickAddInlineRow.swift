//
//  QuickAddInlineRow.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 18/10/2025.
//

import SwiftUI

/// 一行輸入 + Add 按鈕（風格參考你提供的「文字 + 下劃線」）
struct QuickAddInlineRow: View {
    let placeholder: String
    let buttonTitle: String
    let onAdd: (String) -> Void

    @State private var text: String = ""
    @FocusState private var focused: Bool
    @State private var justAddedName: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("New Event")
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .focused($focused)
                    .submitLabel(.done)
                    .onSubmit { addNow() }

                Button(action: addNow) {
                    Text(buttonTitle)
                        .font(.subheadline.weight(.semibold))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(.thinMaterial, in: Capsule())
                }
                .disabled(trimmed.isEmpty)
            }

            // 下劃線（模擬你圈住的樣式）
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.primary.opacity(0.12))

            if let name = justAddedName {
                Text("Added \"\(name)\"")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(8)
        .animation(.easeOut(duration: 0.25), value: justAddedName)
    }

    private var trimmed: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func addNow() {
        let name = trimmed
        guard !name.isEmpty else { return }
        onAdd(name)
        justAddedName = name
        text = ""
        focused = true

        // 輕觸感（不影響編譯）
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif

        // 自動消失提示
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { justAddedName = nil }
        }
    }
}
