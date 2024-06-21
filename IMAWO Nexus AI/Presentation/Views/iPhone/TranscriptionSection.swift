//
//  TranscriptionSection.swift
//  IMAWO Nexus AI
//
//  Created by Ovidiu Muntean on 21.06.2024.
//

import AVFoundation
import AVKit
import TipKit
import SwiftUI

struct TranscriptionSection: View {
    @Binding var showingOptions: Bool
    @Binding var uploadedFile: String
    @Binding var isFileLoaded: Bool
    @Binding var fileURL: URL
    @Binding var transcribedTextOptionsTip: TranscribedTextOptionsTip
    @Binding var videoPlayer: AVPlayer?
    @Binding var showVideoPlayer: Bool
    @Binding var showingFileImporter: Bool
    @ObservedObject var openAIViewModel: OpenAIViewModel
    @State var apiKeys: FetchedResults<ApiKeys>
    
    @State private var fileOptionsTip = FileOptionsTip()
    
    var body: some View {
        Section {
            TipView(fileOptionsTip)
            
            Text(uploadedFile)
                .padding([.top, .bottom], 0)
                .fontWeight(.light)
                .onTapGesture {
                    showingOptions = isFileLoaded
                }
                .confirmationDialog("Select an option", isPresented: $showingOptions) {
                    Button("Transcribe recording") {
                        if fileURL.startAccessingSecurityScopedResource() {
                            Task {
                                DispatchQueue.main.async {
                                    self.openAIViewModel.decodedWhisper = Whisper(text: "Converting voice to text...")
                                }
                                
                                openAIViewModel.apiKey = apiKeys.first?.apiKey
                                
                                await openAIViewModel.sendRecordingToWhisperAPI(audioFilePath: fileURL.path)
                                
                                if let decodedWhisper = openAIViewModel.decodedWhisper {
                                    AnalyzedTextCache.previouslyTranscribedText = decodedWhisper.text
                                }
                            }
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                    
                    Button("Play the file") {
                        if fileURL.startAccessingSecurityScopedResource() {
                            do {
                                /*audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                                 audioPlayer?.prepareToPlay()
                                 audioPlayer?.play()*/
                                
                                videoPlayer = AVPlayer(url: fileURL)
                                videoPlayer?.play()
                                showVideoPlayer = true
                                
                            } catch {
                                print("Error initializing media player: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                    Button("Import another file", role: .destructive) {
                        showingFileImporter = true
                    }
                    
                    Button("Cancel", role: .cancel) {
                        
                    }
                } message: {
                    Text("What do you want to do with the file?")
                }
        } header: {
            Text("YOUR IMPORTED FILE")
        }
    }
}
