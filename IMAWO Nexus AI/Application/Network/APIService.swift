//
//  APIService.swift
//  IMAWO Nexus AI
//
//  Created by Ovidiu Muntean on 19.06.2024.
//

import Foundation
import Alamofire

class APIService {
    static let baseURL = "https://api.openai.com/v1"
    static let audioTranscriptionEndpoint = "/audio/transcriptions"
    static let chatCompletionsEndpoint = "/chat/completions"

    private init() { }

    static func uploadAudioFile(apiKey: String, audioFilePath: String, completion: @escaping (Result<Whisper, OpenAIError>) -> Void) {
        let apiUrl = "\(APIService.baseURL)\(APIService.audioTranscriptionEndpoint)"
        let parameters: [String: Any] = ["model": "whisper-1"]

        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(URL(fileURLWithPath: audioFilePath), withName: "file")
            for (key, value) in parameters {
                if let data = "\(value)".data(using: .utf8) {
                    multipartFormData.append(data, withName: key)
                }
            }
        }, to: apiUrl, headers: HTTPHeaders(["Authorization": "Bearer \(apiKey)"]))
        .responseDecodable(of: Whisper.self) { response in
            switch response.result {
            case .success(let decodedWhisper):
                completion(.success(decodedWhisper))
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
    }

    static func sendMessage(apiKey: String, prompt: String, completion: @escaping (Result<Response, OpenAIError>) -> Void) {
        let apiUrl = "\(APIService.baseURL)\(APIService.chatCompletionsEndpoint)"
        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.0,
            "max_tokens": 1024
        ]

        let headers: HTTPHeaders = ["Authorization": "Bearer \(apiKey)"]

        AF.request(apiUrl, method: .post, parameters: requestBody, encoding: JSONEncoding.default, headers: headers)
        .responseDecodable(of: APIResponse.self) { response in
            switch response.result {
            case .success(let value):
                let text = value.choices.first?.message.content ?? ""
                completion(.success(Response(text: text)))
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
    }
}
