//
//  ContentView.swift
//  ColorRoulette
//
//  Created by Masafumi Ito on 2024/05/04.
//

import SwiftUI

struct ContentView: View {
    let colorTextPairs: [(Color, String)] = [
        (.red, "あか"),
        (.blue, "あお"),
        (.green, "みどり"),
        (.yellow, "きいろ"),
        (.pink, "ぴんく"),
        (.purple, "むらさき"),
        (.brown, "ちゃいろ"),
    ]
    @State private var backgroundColor: Color = .white
    @State private var textColor: Color = .black
    @State private var isRotating = false
    @State private var currentIndex = -1
    @State private var isMuted = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(backgroundColor.opacity(0.1))
                .overlay {
                    Text(currentIndex >= 0 ? colorTextPairs[currentIndex].1 : "タップしてスタート")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                }
                .onTapGesture {
                    self.startStopRotation()
                }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        self.isMuted.toggle()
                    }) {
                        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.fill")
                            .foregroundColor(.black)
                            .padding()
                    }
                }
                Spacer()
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
            rotateColors()
        }
    }
    
    func rotateColors() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let randomIndex = Int.random(in: 0..<self.colorTextPairs.count)
            self.backgroundColor = self.colorTextPairs[randomIndex].0
            self.textColor = self.backgroundColor
            self.currentIndex = randomIndex
            if self.isRotating {
                self.rotateColors()
            }
        }
    }
}
