import SwiftUI
import AVFoundation

struct ContentView: View {
    let colorTextPairs: [(Color, String, String)] = [
        (.red, "あか", "red"),
        (.blue, "あお", "blue"),
        (.yellow, "きいろ", "yellow"),
        (.purple, "むらさき", "purple"),
        (.green, "みどり", "green"),
    ]
    @State private var backgroundColor: Color = .white
    @State private var textColor: Color = .black
    @State private var isRotating = false
    @State private var currentIndex = -1
    
    var startSound: AVAudioPlayer?
    var stopSound: AVAudioPlayer?
    var colorSounds: [String:AVAudioPlayer] = [:]
    
    init() {
        do {
            startSound = try AVAudioPlayer(data: NSDataAsset(name: "start")!.data)
            stopSound = try AVAudioPlayer(data: NSDataAsset(name: "stop")!.data)
            for (_, _, color) in colorTextPairs {
                if let data = NSDataAsset(name: color)?.data {
                    colorSounds[color] = try AVAudioPlayer(data: data)
                }
            }
        } catch {
            print("Error loading sound file")
        }
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(backgroundColor.opacity(0.1))
                .overlay {
                    Text(currentIndex >= 0 ? colorTextPairs[currentIndex].1 : "スタート")
                        .font(.system(size: 80))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                }
                .onTapGesture {
                    self.startStopRotation()
                }
        }
        .onAppear {
            self.backgroundColor = .white
            self.textColor = .black
            self.currentIndex = -1
        }
    }
    
    func startStopRotation() {
        self.isRotating.toggle()
        if isRotating {
            startSound?.play()
            rotateColors()
        } else {
            let stopColor = colorTextPairs[currentIndex].2
            if let colorSound = colorSounds[stopColor] {
                stopSound?.play()
                // 指定秒後に色の音声を再生
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    colorSound.play()
                }
            }
        }
    }
    
    func rotateColors() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.isRotating {
                var randomIndex: Int
                repeat {
                    randomIndex = Int.random(in: 0..<self.colorTextPairs.count)
                } while randomIndex == self.currentIndex // 現在の色と同じ場合、別のランダムインデックスを選択
                self.backgroundColor = self.colorTextPairs[randomIndex].0
                self.textColor = self.backgroundColor
                self.currentIndex = randomIndex
                self.rotateColors()
            }
        }
    }
}
