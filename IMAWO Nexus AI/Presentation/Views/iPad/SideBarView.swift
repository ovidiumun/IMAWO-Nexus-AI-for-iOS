//
//  SideBarView.swift
//  IMAWO Nexus AI
//
//  Created by Ovidiu Muntean on 21.06.2024.
//

import AVFoundation
import AVKit
import SwiftUI
import TipKit
import Combine

struct SideBarView: View {
    @Binding var showingFileImporter: Bool
    @Binding var showingOptions: Bool
    @Binding var showingCopyTranscribedText: Bool
    @Binding var showingAnalyzedText: Bool
    @Binding var showingAddAPIKey: Bool
    @Binding var showVideoPlayer: Bool
    @Binding var isFileLoaded: Bool
    @Binding var uploadedFile: String
    @Binding var fileOptionsTipForIpad: FileOptionsTipForIpad
    @Binding var transcribedTextOptionsTip: TranscribedTextOptionsTip
    @Binding var fileURL: URL
    @Binding var appTitle: String
    @Binding var audioPlayer: AVAudioPlayer?
    @Binding var videoPlayer: AVPlayer?
    
    var apiKeys: FetchedResults<ApiKeys>
    var openAIViewModel: OpenAIViewModel
    
    var body: some View {
        ZStack {
            Color(uiColor: UIColor.quaternarySystemFill)
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Form {
                    Section {
                        Button("Upload a file") {
                            showingFileImporter = true
                        }
                        .fileImporter(
                            isPresented: $showingFileImporter,
                            allowedContentTypes: [.audio, .video, .mpeg, .mpeg2Video, .mpeg4Movie, .avi, .appleProtectedMPEG4Video, .quickTimeMovie],
                            allowsMultipleSelection: false
                        ) { result in
                            isFileLoaded = false
                            
                            if case .success = result {
                                do {
                                    fileURL = try result.get().first!
                                    
                                    if fileURL.startAccessingSecurityScopedResource() {
                                        uploadedFile = fileURL.lastPathComponent
                                        
                                        openAIViewModel.decodedWhisper = Whisper(text: "Nothing")
                                        
                                        isFileLoaded = true
                                        showingOptions = isFileLoaded
                                        
                                        AnalyzedTextCache.previouslyAnalyzedText = ""
                                        AnalyzedTextCache.previouslyTranscribedText = ""
                                    }
                                } catch {
                                    let nsError = error as NSError
                                    
                                    print(error)
                                    uploadedFile = "Upload failed with error \(error.localizedDescription)"
                                    
                                    fatalError("File Import Error \(nsError), \(nsError.userInfo)")
                                }
                            } else {
                                print("File Import Failed")
                            }
                        }
                    } header: {
                        Text("IMPORT RECORDING")
                    }
                    
                    Section {
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
                                                openAIViewModel.decodedWhisper = Whisper(text: "Converting voice to text...")
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
                    
                    if (isFileLoaded) {
                        Section {
                            TipView(fileOptionsTipForIpad)
                            
                            Button("Transcribe recording") {
                                if fileURL.startAccessingSecurityScopedResource() {
                                    Task {
                                        DispatchQueue.main.async {
                                            openAIViewModel.decodedWhisper = Whisper(text: "Converting voice to text...")
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
                        } header: {
                            Text("OPTIONS")
                        }
                    }
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
}
