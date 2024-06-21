//
//  AnimationsView.swift
//  IMAWO Nexus AI
//
//  Created by Ovidiu Muntean on 21.06.2024.
//

import SwiftUI

struct AudioRecordingAnimationView: View {
    @State private var drawingHeight = true
    
    var animation: Animation {
        return .linear(duration: 0.5).repeatForever()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                bar(low: 0.4)
                    .animation(animation.speed(1.5), value: drawingHeight)
                bar(low: 0.3)
                    .animation(animation.speed(1.2), value: drawingHeight)
                bar(low: 0.5)
                    .animation(animation.speed(1.0), value: drawingHeight)
                bar(low: 0.3)
                    .animation(animation.speed(1.7), value: drawingHeight)
                bar(low: 0.5)
                    .animation(animation.speed(1.0), value: drawingHeight)
            }
            .frame(width: 80)
            .onAppear{
                drawingHeight.toggle()
            }
        }
    }
    
    func bar(low: CGFloat = 0.0, high: CGFloat = 1.0) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(.indigo.gradient)
            .frame(height: (drawingHeight ? high : low) * 64)
            .frame(height: 64, alignment: .bottom)
    }
}
