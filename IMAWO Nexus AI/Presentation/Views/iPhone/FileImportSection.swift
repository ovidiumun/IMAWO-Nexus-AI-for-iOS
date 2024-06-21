//
//  FileImportSection.swift
//  IMAWO Nexus AI
//
//  Created by Ovidiu Muntean on 21.06.2024.
//

import SwiftUI

struct FileImportSection: View {
    @Binding var showingFileImporter: Bool
    @Binding var isFileLoaded: Bool
    @Binding var uploadedFile: String
    @Binding var fileURL: URL
    @Binding var showingOptions: Bool
    @ObservedObject var openAIViewModel: OpenAIViewModel
    @State var apiKeys: FetchedResults<ApiKeys>
    
    var body: some View {
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
                            
                            self.openAIViewModel.decodedWhisper = Whisper(text: "Nothing")
                            
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
            .frame(maxWidth: .infinity)
        } header: {
            Text("IMPORT RECORDING")
        }
    }
}
