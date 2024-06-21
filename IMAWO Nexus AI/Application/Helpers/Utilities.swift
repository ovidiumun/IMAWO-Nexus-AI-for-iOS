//
//  Utilities.swift
//  IMAWO Nexus AI
//
//  Created by Ovidiu Muntean on 13.10.2023.
//

import Foundation
import UIKit

struct Utilities {
    static let shared = Utilities()
    
    private init() { }
    
    func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }
    
    static func analyzeText(openAIViewModel: OpenAIViewModel, apiKey: String) async {
        guard let decodedWhisper = openAIViewModel.decodedWhisper else {
            DispatchQueue.main.async {
                openAIViewModel.decodedResponse = Response(text: "No results")
            }
            return
        }
        
        print("\nDECODED WHISPER: \n\(decodedWhisper.text)")
        print("\nPREVIOUSLY DECODED WHISPER: \(String(describing: AnalyzedTextCache.previouslyTranscribedText))")
        
        if decodedWhisper.text == AnalyzedTextCache.previouslyTranscribedText {
            DispatchQueue.main.async {
                openAIViewModel.decodedResponse = Response(text: AnalyzedTextCache.previouslyAnalyzedText ?? "No results")
                print("\nPreviously analyzed text:\n\(String(describing: AnalyzedTextCache.previouslyAnalyzedText))")
            }
        } else {
            DispatchQueue.main.async {
                openAIViewModel.decodedResponse = Response(text: "Analyzing text (it may take a while)...")
                print("\nAnalyzing text (it may take a while)...\n")
            }
            
            openAIViewModel.apiKey = apiKey
            let text = "Analyze the text and tell me: the participants in the discussion, the tone of voice, the involvement of participants, and the main topics of the discussion. Use emojis and spacing between paragraphs when you give me the result. \(String(describing: decodedWhisper.text))"
            
            do {
                try await openAIViewModel.sendUserMessageToOpenAIAPI(prompt: text)
            } catch {
                DispatchQueue.main.async {
                    openAIViewModel.decodedResponse = Response(text: error.localizedDescription)
                }
            }
        }
    }
}
