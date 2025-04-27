import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("selectedColorsJson") private var selectedColorsJson: String = "[\"red\",\"blue\",\"yellow\",\"purple\",\"green\"]"

    private var selectedColors: [String] {
        get {
            if let data = selectedColorsJson.data(using: .utf8),
               let colors = try? JSONDecoder().decode([String].self, from: data) {
                return colors
            }
            return ["red", "blue", "yellow", "purple", "green"]
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let json = String(data: data, encoding: .utf8) {
                selectedColorsJson = json
            }
        }
    }

    let availableColors: [(Color, String, String)] = [
        (.red, "あか", "red"),
        (.blue, "あお", "blue"),
        (.yellow, "きいろ", "yellow"),
        (.purple, "むらさき", "purple"),
        (.green, "みどり", "green"),
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(availableColors, id: \.2) { color, name, identifier in
                    HStack {
                        Circle()
                            .fill(color)
                            .frame(width: 30, height: 30)
                        Text(name)
                        Spacer()
                        Image(systemName: selectedColors.contains(identifier) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedColors.contains(identifier) ? .blue : .gray)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleColor(identifier)
                    }
                }
            }
            .navigationTitle("色の設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func toggleColor(_ identifier: String) {
        var colors = selectedColors
        if colors.contains(identifier) {
            if colors.count > 1 {
                colors.removeAll { $0 == identifier }
                selectedColors = colors
            }
        } else {
            colors.append(identifier)
            selectedColors = colors
        }
    }
}