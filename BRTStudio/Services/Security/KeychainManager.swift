//
//  KeychainManager.swift
//  BRT Studio - Keychain Manager for Secure Key Storage
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import Foundation
import CryptoKit
import Security

/// Manages secure storage of encryption keys in macOS Keychain
actor KeychainManager {
    static let shared = KeychainManager()

    private let service = AppConstants.keychainService
    private let logger = AppLogger.shared

    private init() {}

    /// Store a symmetric key in keychain
    func storeKey(_ key: SymmetricKey, identifier: String) async throws {
        let keyData = key.withUnsafeBytes { Data($0) }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: identifier,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        // Delete existing item first
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            await logger.log(.error, "Failed to store key in keychain", metadata: ["status": "\(status)"])
            throw KeychainError.storeFailed(status)
        }

        await logger.log(.debug, "Key stored in keychain", metadata: ["identifier": identifier])
    }

    /// Retrieve a symmetric key from keychain
    func retrieveKey(identifier: String) async throws -> SymmetricKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: identifier,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            await logger.log(.error, "Failed to retrieve key from keychain", metadata: ["status": "\(status)"])
            throw KeychainError.retrieveFailed(status)
        }

        guard let keyData = item as? Data else {
            throw KeychainError.invalidData
        }

        let key = SymmetricKey(data: keyData)

        await logger.log(.debug, "Key retrieved from keychain", metadata: ["identifier": identifier])

        return key
    }

    /// Delete a key from keychain
    func deleteKey(identifier: String) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: identifier
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            await logger.log(.error, "Failed to delete key from keychain", metadata: ["status": "\(status)"])
            throw KeychainError.deleteFailed(status)
        }

        await logger.log(.debug, "Key deleted from keychain", metadata: ["identifier": identifier])
    }

    /// Store a generic secret (password, API key, etc.)
    func storeSecret(_ secret: String, identifier: String) async throws {
        guard let data = secret.data(using: .utf8) else {
            throw KeychainError.invalidData
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: identifier,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        // Delete existing item first
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            await logger.log(.error, "Failed to store secret in keychain", metadata: ["status": "\(status)"])
            throw KeychainError.storeFailed(status)
        }

        await logger.log(.debug, "Secret stored in keychain", metadata: ["identifier": identifier])
    }

    /// Retrieve a generic secret
    func retrieveSecret(identifier: String) async throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: identifier,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            await logger.log(.error, "Failed to retrieve secret from keychain", metadata: ["status": "\(status)"])
            throw KeychainError.retrieveFailed(status)
        }

        guard let data = item as? Data,
              let secret = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }

        await logger.log(.debug, "Secret retrieved from keychain", metadata: ["identifier": identifier])

        return secret
    }

    /// List all keys in the keychain service
    func listKeys() async throws -> [String] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]

        var items: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &items)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return []
            }
            throw KeychainError.retrieveFailed(status)
        }

        guard let itemsArray = items as? [[String: Any]] else {
            return []
        }

        return itemsArray.compactMap { $0[kSecAttrAccount as String] as? String }
    }

    /// Clear all keys from the keychain service
    func clearAll() async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            await logger.log(.error, "Failed to clear keychain", metadata: ["status": "\(status)"])
            throw KeychainError.deleteFailed(status)
        }

        await logger.log(.warning, "All keys cleared from keychain")
    }
}

// MARK: - Keychain Errors

enum KeychainError: LocalizedError {
    case storeFailed(OSStatus)
    case retrieveFailed(OSStatus)
    case deleteFailed(OSStatus)
    case invalidData

    var errorDescription: String? {
        switch self {
        case .storeFailed(let status):
            return "Failed to store in keychain (status: \(status))"
        case .retrieveFailed(let status):
            return "Failed to retrieve from keychain (status: \(status))"
        case .deleteFailed(let status):
            return "Failed to delete from keychain (status: \(status))"
        case .invalidData:
            return "Invalid keychain data"
        }
    }
}
