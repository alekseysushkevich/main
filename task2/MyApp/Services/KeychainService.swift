//
//  RegistrationModel.swift
//  MyApp
//
//  Created by Алексей Сушкевич on 15.11.24.
//

import Foundation
import Security

enum KeychainError: Error {
    case duplicateItem
    case itemNotFound
    case unexpectedData
    case unknown(OSStatus)
}

class KeychainService {
    
    static func save(_ service: String, account: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            throw interpretError(status)
        }
    }
    
    static func load(_ service: String, account: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecItemNotFound {
            throw KeychainError.itemNotFound
        } else if status != errSecSuccess {
            throw interpretError(status)
        }
        
        guard let data = dataTypeRef as? Data else {
            throw KeychainError.unexpectedData
        }
        
        return data
    }
    
    static func delete(_ service: String, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecItemNotFound {
            throw KeychainError.itemNotFound
        } else if status != errSecSuccess {
            throw interpretError(status)
        }
    }
    
    private static func interpretError(_ status: OSStatus) -> KeychainError {
        switch status {
        case errSecDuplicateItem:
            return .duplicateItem
        case errSecItemNotFound:
            return .itemNotFound
        default:
            return .unknown(status)
        }
    }
}
