//
//  FilePlaybackSection.swift
//  IMAWO Nexus AI
//
//  Created by Ovidiu Muntean on 21.06.2024.
//

import AVFoundation
import AVKit
import SwiftUI

struct FilePlaybackSection: View {
    @Binding var videoPlayer: AVPlayer?
    @Binding var showVideoPlayer: Bool
    
    var body: some View {
        Section(header: Text("FILE PLAYBACK")) {
            if let player = videoPlayer {
                VideoPlayer(player: player)
                    .frame(height: 320)
            }
        }
        .opacity(showVideoPlayer ? 1 : 0)
    }
}
