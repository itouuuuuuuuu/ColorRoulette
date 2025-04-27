import SwiftUI
import AVFoundation

struct ColorOption: Identifiable, Codable {
    let id: String
    let name: String
    var color: Color {
        switch id {
        case "red": return .red
        case "blue": return .blue
        case "yellow": return .yellow
        case "purple": return .purple
        case "green": return .green
        case "pink": return Color(red: 1, green: 0.4, blue: 0.7)
        case "mizuiro": return Color(red: 0, green: 0.8, blue: 1)
        case "chairo": return Color(red: 0.6, green: 0.4, blue: 0.2)
        case "orange": return Color(red: 1, green: 0.6, blue: 0)
        case "kimidori": return Color(red: 0.6, green: 0.8, blue: 0.2)
        default: return .gray
        }
    }

    static let all: [ColorOption] = [
        .init(id: "red", name: "あか"),
        .init(id: "blue", name: "あお"),
        .init(id: "yellow", name: "きいろ"),
        .init(id: "purple", name: "むらさき"),
        .init(id: "green", name: "みどり"),
        .init(id: "pink", name: "ピンク"),
        .init(id: "mizuiro", name: "みずいろ"),
        .init(id: "chairo", name: "ちゃいろ"),
        .init(id: "orange", name: "オレンジ"),
        .init(id: "kimidori", name: "きみどり")
    ]
}

@propertyWrapper
struct ColorSelection: DynamicProperty {
    @AppStorage("selectedColorIds") private var json: String = ColorOption.all.map(\.id).joined(separator: ",")

    var wrappedValue: [String] {
        get { json.split(separator: ",").map(String.init) }
        nonmutating set { json = newValue.joined(separator: ",") }
    }

    var projectedValue: Binding<[String]> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ColorSelection private var selectedIds

    var body: some View {
        NavigationStack {
            List(ColorOption.all) { option in
                HStack {
                    Circle()
                        .fill(option.color)
                        .frame(width: 30, height: 30)
                    Text(option.name)
                    Spacer()
                    Image(systemName: selectedIds.contains(option.id) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(selectedIds.contains(option.id) ? .blue : .gray)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    toggleColor(option.id)
                }
            }
            .navigationTitle("色の設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") { dismiss() }
                }
            }
        }
    }

    private func toggleColor(_ id: String) {
        if selectedIds.contains(id) {
            guard selectedIds.count > 1 else { return }
            selectedIds.removeAll { $0 == id }
        } else {
            selectedIds.append(id)
        }
    }
}

struct ContentView: View {
    @ColorSelection private var selectedIds
    @State private var showSettings = false
    @State private var backgroundColor = Color.white
    @State private var textColor = Color.black
    @State private var isRotating = false
    @State private var currentOption: ColorOption?

    private var selectedOptions: [ColorOption] {
        ColorOption.all.filter { selectedIds.contains($0.id) }
    }

    private let soundPlayer = SoundPlayer()

    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .foregroundColor(backgroundColor.opacity(0.1))
                    .overlay {
                        Text(currentOption?.name ?? "スタート")
                            .font(.system(size: 80))
                            .fontWeight(.bold)
                            .foregroundColor(textColor)
                    }
                    .onTapGesture(perform: startStopRotation)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private func startStopRotation() {
        guard !selectedOptions.isEmpty else { return }

        isRotating.toggle()
        if isRotating {
            backgroundColor = .white
            textColor = .black
            currentOption = nil
            soundPlayer.playStart()
            rotateColors()
        } else {
            soundPlayer.playStop()
            if let lastOption = currentOption {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    currentOption = lastOption
                    backgroundColor = lastOption.color
                    textColor = backgroundColor
                    soundPlayer.playColor(lastOption.id)
                }
            }
        }
    }

    private func rotateColors() {
        guard isRotating else { return }

        let previousOption = currentOption
        repeat {
            currentOption = selectedOptions.randomElement()
        } while currentOption?.id == previousOption?.id && selectedOptions.count > 1

        if let option = currentOption {
            backgroundColor = option.color
            textColor = backgroundColor
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            rotateColors()
        }
    }
}

private final class SoundPlayer {
    private var sounds: [String: AVAudioPlayer] = [:]

    init() {
        loadSound("start", volume: 0.3)
        loadSound("stop", volume: 0.3)
        ColorOption.all.forEach { loadSound($0.id) }
    }

    func playStart() {
        sounds["start"]?.play()
    }

    func playStop() {
        sounds["stop"]?.play()
    }

    func playColor(_ id: String) {
        sounds[id]?.play()
    }

    private func loadSound(_ name: String, volume: Float = 1.0) {
        guard let asset = NSDataAsset(name: name) else { return }
        do {
            let player = try AVAudioPlayer(data: asset.data)
            player.volume = volume
            sounds[name] = player
        } catch {
            print("Error loading sound: \(name)")
        }
    }
}
