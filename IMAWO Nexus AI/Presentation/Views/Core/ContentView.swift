//
//  ContentView.swift
//  IMAWO Nexus AI
//
//  Created by Ovidiu Muntean on 04.10.2023.
//

import AVFoundation
import AVKit
import SwiftUI
import TipKit
import Combine

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.horizontalSizeClass) var sizeClass
    @FetchRequest(entity: ApiKeys.entity(), sortDescriptors: []) var apiKeys: FetchedResults<ApiKeys>
    
    @State private var appTitle: String = "IMAWO Nexus AI"
    @State private var uploadedFile: String = "Nothing"
    @State private var fileURL: URL = URL(fileURLWithPath: "")
    @State private var videoPlayer: AVPlayer?
    
    @State private var showingFileImporter = false
    @State private var showingOptions = false
    @State private var showingCopyTranscribedText = false
    @State private var showingCopyAnalyzedText = false
    @State private var showingAnalyzedText = false
    @State private var isFileLoaded = false
    @State private var showingAddAPIKey = false
    @State private var showVideoPlayer = false
    
    @State private var apiKey: String?
    @State private var audioPlayer: AVAudioPlayer?
    
    @State private var transcribedTextOptionsTip = TranscribedTextOptionsTip()
    @State private var analyzedTextOptionsTip = AnalyzedTextOptionsTip()
    
    @State private var fileOptionsTipForIpad = FileOptionsTipForIpad()
    @State private var transcribedTextOptionsTipForIpad = TranscribedTextOptionsTipForIpad()
    @State private var analyzedTextOptionsTipForIpad = AnalyzedTextOptionsTipForIpad()
    
    @StateObject private var openAIViewModel = OpenAIViewModel()
    
    var body: some View {
        if sizeClass == .compact {
            // iPhone layout
            iPhoneLayout()
        } else {
            // iPad layout
            iPadLayout()
        }
    }
    
    @ViewBuilder
    func iPhoneLayout() -> some View {
        NavigationView {
            ZStack {
                Color(uiColor: UIColor.quaternarySystemFill)
                    .ignoresSafeArea()
                
                VStack(alignment: .center) {
                    AudioRecordingAnimationView()
                    
                    Text("Voice analyzer")
                        .padding(.top, 10)
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 10)
                    
                    Form {
                        FileImportSection(showingFileImporter: $showingFileImporter,
                                          isFileLoaded: $isFileLoaded,
                                          uploadedFile: $uploadedFile,
                                          fileURL: $fileURL,
                                          showingOptions: $showingOptions,
                                          openAIViewModel: openAIViewModel,
                                          apiKeys: apiKeys)
                        
                        TranscriptionSection(showingOptions: $showingOptions,
                                             uploadedFile: $uploadedFile,
                                             isFileLoaded: $isFileLoaded,
                                             fileURL: $fileURL,
                                             transcribedTextOptionsTip: $transcribedTextOptionsTip,
                                             videoPlayer: $videoPlayer,
                                             showVideoPlayer: $showVideoPlayer,
                                             showingFileImporter: $showingFileImporter,
                                             openAIViewModel: openAIViewModel,
                                             apiKeys: apiKeys)
                        
                        AnalysisSection(showingCopyTranscribedText: $showingCopyTranscribedText,
                                        showingAnalyzedText: $showingAnalyzedText,
                                        videoPlayer: $videoPlayer,
                                        showVideoPlayer: $showVideoPlayer,
                                        openAIViewModel: openAIViewModel,
                                        apiKeys: apiKeys)
                    }
                    .scrollContentBackground(.hidden)
                    
                }
                .toolbar {
                    ToolbarItem {
                        Button(action: {
                            showingAddAPIKey = true
                        }) {
                            Label("", systemImage: "key.icloud")
                        }
                    }
                }
                .sheet(isPresented: $showingAddAPIKey) {
                    APIKeysView()
                }
                .onAppear{
                    guard (apiKeys.first?.apiKey) != nil else {
                        showingAddAPIKey = true
                        return
                    }
                }
            }
            .navigationTitle(appTitle)
            .navigationBarTitleDisplayMode(.large)
            .navigationBarHidden(false)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    func iPadLayout() -> some View {
        NavigationSplitView {
            SideBarView(
                showingFileImporter: $showingFileImporter,
                showingOptions: $showingOptions,
                showingCopyTranscribedText: $showingCopyTranscribedText,
                showingAnalyzedText: $showingAnalyzedText,
                showingAddAPIKey: $showingAddAPIKey,
                showVideoPlayer: $showVideoPlayer,
                isFileLoaded: $isFileLoaded,
                uploadedFile: $uploadedFile,
                fileOptionsTipForIpad: $fileOptionsTipForIpad,
                transcribedTextOptionsTip: $transcribedTextOptionsTip,
                fileURL: $fileURL,
                appTitle: $appTitle,
                audioPlayer: $audioPlayer,
                videoPlayer: $videoPlayer,
                apiKeys: apiKeys,
                openAIViewModel: openAIViewModel
            )
            .frame(minWidth: 200)
        } detail: {
            DetailView(
                showingCopyTranscribedText: $showingCopyTranscribedText,
                showingCopyAnalyzedText: $showingCopyAnalyzedText,
                showVideoPlayer: $showVideoPlayer,
                transcribedTextOptionsTipForIpad: $transcribedTextOptionsTipForIpad,
                analyzedTextOptionsTipForIpad: $analyzedTextOptionsTipForIpad,
                videoPlayer: $videoPlayer,
                apiKeys: apiKeys,
                openAIViewModel: openAIViewModel
            )
        }
    }
}
    
struct ContentViewPreviews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        ContentView().environment(\.managedObjectContext, context)
    }
}
