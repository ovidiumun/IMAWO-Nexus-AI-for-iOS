//
//  DetailView.swift
//  IMAWO Nexus AI
//
//  Created by Ovidiu Muntean on 21.06.2024.
//

import AVFoundation
import AVKit
import SwiftUI
import TipKit
import Combine

import SwiftUI

struct DetailView: View {
    @Binding var showingCopyTranscribedText: Bool
    @Binding var showingCopyAnalyzedText: Bool
    @Binding var showVideoPlayer: Bool
    @Binding var transcribedTextOptionsTipForIpad: TranscribedTextOptionsTipForIpad
    @Binding var analyzedTextOptionsTipForIpad: AnalyzedTextOptionsTipForIpad
    @Binding var videoPlayer: AVPlayer?
    
    var apiKeys: FetchedResults<ApiKeys>
    var openAIViewModel: OpenAIViewModel
    
    var body: some View {
        ZStack {
            Color(uiColor: UIColor.quaternarySystemFill)
                .ignoresSafeArea()
            
            VStack (alignment: .leading) {
                
                Text("Voice analysis")
                    .padding(.top, 10)
                    .font(.title2)
                    .bold()
                    .padding(.leading, 20)
                    .padding(.bottom, 10)
                
                LinearGradient(gradient: Gradient(colors: [.red, .blue]), startPoint: .leading, endPoint: .trailing)
                    .frame(width: 60, height: 60, alignment: .center)
                    .mask(
                        Image(systemName: "doc.text.below.ecg")
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                    )
                    .padding(.top, 20)
                    .padding(.leading, 20)
                
                Form {
                    Section(header: Text("FILE PLAYBACK")) {
                        if let player = videoPlayer {
                            VideoPlayer(player: player)
                                .frame(height: 480)
                        }
                    }
                    .opacity(showVideoPlayer ? 1 : 0)
                    
                    Section {
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
                                            Task {
                                                await Utilities.analyzeText(openAIViewModel: openAIViewModel, apiKey: apiKeys.first?.apiKey ?? "")
                                            }
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
                    } header: {
                        Text("YOUR TRANSCRIPTION")
                    }
                    
                    if let decodedWhisper = openAIViewModel.decodedWhisper {
                        Section {
                            TipView(transcribedTextOptionsTipForIpad)
                            
                            Button("Copy text to clipboard") {
                                Utilities.shared.copyToClipboard(decodedWhisper.text)
                            }
                            .keyboardShortcut(.defaultAction)
                            
                            Button("Analyze transcription", role: .destructive) {
                                Task {
                                    await Utilities.analyzeText(openAIViewModel: openAIViewModel, apiKey: apiKeys.first?.apiKey ?? "")
                                }
                            }
                        } header: {
                            Text("ACTIONS")
                        }
                    }
                    
                    Section {
                        ScrollView {
                            if let decodedResponse = openAIViewModel.decodedResponse {
                                Text(decodedResponse.text)
                                    .padding([.top, .bottom], 0)
                                    .fontWeight(.light)
                                    .onTapGesture {
                                        showingCopyAnalyzedText = true
                                    }
                                    .confirmationDialog("Select an option", isPresented: $showingCopyAnalyzedText) {
                                        Button("Copy text to clipboard") {
                                            Utilities.shared.copyToClipboard(decodedResponse.text)
                                        }
                                        .keyboardShortcut(.defaultAction)
                                        
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
                    } header: {
                        Text("YOUR ANALYSIS")
                    }
                    
                    if let decodedResponse = openAIViewModel.decodedResponse {
                        Section {
                            TipView(analyzedTextOptionsTipForIpad)
                            
                            Button("Copy text to clipboard") {
                                Utilities.shared.copyToClipboard(decodedResponse.text)
                            }
                            .keyboardShortcut(.defaultAction)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
    }
}
