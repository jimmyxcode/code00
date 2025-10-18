// MARK: - 1) GlassCard (rounded, material, gentle shadow)
import SwiftUI

public struct GlassCard<Content: View>: View {
    let corner: CGFloat
    let content: Content

    public init(corner: CGFloat = 28, @ViewBuilder content: () -> Content) {
        self.corner = corner
        self.content = content()
    }

    public var body: some View {
        content
            .padding(16)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: corner, style: .continuous)
            )
            .overlay(
                // Very subtle inner highlight for depth
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 10)
            .shadow(color: .black.opacity(0.08), radius: 4,  x: 0, y: 2)
    }
}
