//
//  AnalysisSection.swift
//  IMAWO Nexus AI
//
//  Created by Ovidiu Muntean on 21.06.2024.
//

import AVFoundation
import AVKit
import TipKit
import SwiftUI

struct AnalysisSection: View {
    @Binding var showingCopyTranscribedText: Bool
    @Binding var showingAnalyzedText: Bool
    @Binding var videoPlayer: AVPlayer?
    @Binding var showVideoPlayer: Bool
    @ObservedObject var openAIViewModel: OpenAIViewModel
    @State var apiKeys: FetchedResults<ApiKeys>
    
    @State private var transcribedTextOptionsTip = TranscribedTextOptionsTip()
    
    var body: some View {
        Section(header: Text("FILE PLAYBACK")) {
            if let player = videoPlayer {
                VideoPlayer(player: player)
                    .frame(height: 320)
            }
        }
        .opacity(showVideoPlayer ? 1 : 0)
        
        Section {
            TipView(transcribedTextOptionsTip)
            
            ScrollView {
                if let decodedWhisper = openAIViewModel.decodedWhisper {
                    Text(decodedWhisper.text)
                        .padding([.top, .bottom], 0)
                        .fontWeight(.light)
                        .onTapGesture {
                            showingCopyTranscribedText = true
                        }
                        .confirmationDialog("Select an option", isPresented: $showingCopyTranscribedText) {
                            Button("Copy text to clipboard") {
                                Utilities.shared.copyToClipboard(decodedWhisper.text)
                            }
                            .keyboardShortcut(.defaultAction)
                            
                            Button("Analyze transcription", role: .destructive) {
                                showingAnalyzedText = true
                            }
                            
                            Button("Cancel", role: .cancel) {
                                
                            }
                        }
                } else {
                    Text("Nothing")
                        .padding([.top, .bottom], 0)
                        .fontWeight(.light)
                }
            }
            .padding(.top, 8)
            .sheet(isPresented: $showingAnalyzedText) {
                AnalyzedTextView(openAIViewModel: openAIViewModel)
            }
        } header: {
            Text("YOUR TRANSCRIPTION")
        }
    }
}
