//
//  OpenAIError.swift
//  IMAWO Nexus AI
//
//  Created by Ovidiu Muntean on 19.06.2024.
//

import Foundation

enum OpenAIError: LocalizedError, Equatable {
    case apiKeyMissing
    case noDataReceived
    case invalidResponseFormat
    case rateLimitExceeded
    case maximumRetriesExceeded
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .apiKeyMissing:
            return "API key is missing. Please provide a valid API key."
        case .noDataReceived:
            return "No data received from the API. Please check your internet connection or API response."
        case .invalidResponseFormat:
            return "Invalid response format from the API. The API response did not match the expected format."
        case .networkError(let underlyingError):
            return "Network error occurred. Error: \(underlyingError.localizedDescription)"
        case .rateLimitExceeded:
            return "Rate limit exceeded!"
        case .maximumRetriesExceeded:
            return "Maximum retries exceeded!"
        }
    }
    
    static func == (lhs: OpenAIError, rhs: OpenAIError) -> Bool {
        switch (lhs, rhs) {
        case (.apiKeyMissing, .apiKeyMissing),
            (.noDataReceived, .noDataReceived),
            (.invalidResponseFormat, .invalidResponseFormat),
            (.rateLimitExceeded, .rateLimitExceeded),
            (.maximumRetriesExceeded, .maximumRetriesExceeded):
            return true
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
