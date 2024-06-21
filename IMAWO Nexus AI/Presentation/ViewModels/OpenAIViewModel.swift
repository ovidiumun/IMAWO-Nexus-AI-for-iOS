//
//  OpenAIViewModel.swift
//  IMAWO Nexus AI
//
//  Created by Ovidiu Muntean on 18.10.2023.
//

import Foundation
import Alamofire
import OpenAISwift

class OpenAIViewModel: ObservableObject {
    
    @Published var decodedWhisper: Whisper?
    @Published var decodedResponse: Response?
    @Published var apiKey: String?
    
    private var openAI: OpenAISwift?
    
    func sendRecordingToWhisperAPI(audioFilePath: String) {
        guard let apiKey = apiKey else {
            handleError(.apiKeyMissing)
            return
        }
        
        APIService.uploadAudioFile(apiKey: apiKey, audioFilePath: audioFilePath) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let decodedWhisper):
                DispatchQueue.main.async {
                    self.decodedWhisper = decodedWhisper
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.handleError(error)
                }
            }
        }
    }
    
    func sendUserMessageToOpenAIAPI(prompt: String) {
        guard let apiKey = apiKey else {
            handleError(.apiKeyMissing)
            return
        }

        APIService.sendMessage(apiKey: apiKey, prompt: prompt) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.decodedResponse = response
                    AnalyzedTextCache.previouslyAnalyzedText = response.text
                    AnalyzedTextCache.previouslyTranscribedText = self.decodedWhisper?.text
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.handleError(error)
                }
            }
        }
    }
    
    func sendUserMessageToOpenAI(prompt: String) async {
        guard let apiKey = apiKey else {
            handleError(.apiKeyMissing)
            return
        }
        
        self.openAI = OpenAISwift(authToken: apiKey)
        
        do {
            let chat: [ChatMessage] = [
                ChatMessage(role: .system, content: "You are an expert."),
                ChatMessage(role: .user, content: prompt),
            ]
                        
            let result = try await openAI?.sendChat(
                with: chat,
                model: .chat(.chatgpt),
                temperature: 0,
                maxTokens: 1024
            )
            
            DispatchQueue.main.async {
                self.decodedResponse = Response(text: result?.choices?.first?.message.content ?? "")
                
                AnalyzedTextCache.previouslyAnalyzedText = self.decodedResponse?.text
                AnalyzedTextCache.previouslyTranscribedText = self.decodedWhisper?.text
                
                print("Rezultatul primit: \n\(String(describing: self.decodedResponse?.text))")
            }
        } catch {
            DispatchQueue.main.async {
                self.handleError(.networkError(error))
            }
        }
    }
    
    private func handleError(_ error: OpenAIError) {
        DispatchQueue.main.async {
            self.decodedResponse = Response(text: error.errorDescription ?? "Unknown error")
            print("Error: \(error.localizedDescription)")
        }
    }
}
