//
//  Response.swift
//  IMAWO Nexus AI
//
//  Created by Ovidiu Muntean on 06.10.2023.
//

import Foundation

struct APIResponse: Codable {
    var id: String
    var object: String
    var created: Int
    var model: String
    var choices: [Choice]
    var usage: Usage

    struct Choice: Codable {
        var index: Int
        var message: Message
        var finish_reason: String
    }

    struct Message: Codable {
        var role: String
        var content: String
    }

    struct Usage: Codable {
        var prompt_tokens: Int
        var completion_tokens: Int
        var total_tokens: Int
    }
}
