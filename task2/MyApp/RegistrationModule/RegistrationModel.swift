//
//  RegistrationModel.swift
//  MyApp
//
//  Created by Алексей Сушкевич on 15.11.24.
//

import Foundation
import Security

struct User {
    let username: String
    private(set) var password: String
    
    
    static func isUsernameSaved(_ username: String) -> Bool {
        do {
            let savedUsernameData = try KeychainService.load("com.example.login.username", account: "userAccount")
            let savedUsername = String(data: savedUsernameData, encoding: .utf8) ?? ""
            return savedUsername == username
        } catch {
            return false
        }
    }
    
    enum UserError: Error {
        case usernameAlreadyExists
        case emptyUsername
        case invalidPasswordLength
        case invalidData
    }
    
    init(username: String, password: String) throws {
        guard !username.isEmpty else {
            throw UserError.emptyUsername
        }
        
        guard password.count >= 8 && password.count <= 32 else {
            throw UserError.invalidPasswordLength
        }
        
        self.username = username
        self.password = password
    }
    
    
    func save() throws {
        if User.isUsernameSaved(username) {
            throw UserError.usernameAlreadyExists
        }
        
        let usernameData = Data(username.utf8)
        let passwordData = Data(password.utf8)
        
        try KeychainService.save("com.example.login.username", account: "userAccount", data: usernameData)
        try KeychainService.save("com.example.login.password", account: "userAccount", data: passwordData)
    }
}
