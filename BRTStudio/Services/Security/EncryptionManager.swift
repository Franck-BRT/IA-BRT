//
//  EncryptionManager.swift
//  BRT Studio - AES-GCM Encryption Manager
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import Foundation
import CryptoKit
import Security

/// Manages encryption and decryption of sensitive data using AES-GCM
actor EncryptionManager {
    static let shared = EncryptionManager()

    private let keychainManager = KeychainManager.shared
    private let logger = AppLogger.shared
    private let keyIdentifier = "com.blackroomtech.brtstudio.encryption.key"

    private init() {}

    /// Encrypt data using AES-GCM
    func encrypt(_ data: Data) async throws -> EncryptedData {
        let key = try await getOrCreateEncryptionKey()

        let sealedBox = try AES.GCM.seal(data, using: key)

        guard let combined = sealedBox.combined else {
            throw EncryptionError.encryptionFailed
        }

        await logger.log(.debug, "Data encrypted", metadata: ["size": "\(data.count)"])

        return EncryptedData(
            ciphertext: combined,
            algorithm: .aesGcm,
            keyIdentifier: keyIdentifier
        )
    }

    /// Decrypt data using AES-GCM
    func decrypt(_ encryptedData: EncryptedData) async throws -> Data {
        guard encryptedData.algorithm == .aesGcm else {
            throw EncryptionError.unsupportedAlgorithm
        }

        let key = try await getEncryptionKey(identifier: encryptedData.keyIdentifier)

        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData.ciphertext)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)

        await logger.log(.debug, "Data decrypted", metadata: ["size": "\(decryptedData.count)"])

        return decryptedData
    }

    /// Encrypt string
    func encrypt(_ string: String) async throws -> EncryptedData {
        guard let data = string.data(using: .utf8) else {
            throw EncryptionError.invalidData
        }
        return try await encrypt(data)
    }

    /// Decrypt to string
    func decryptToString(_ encryptedData: EncryptedData) async throws -> String {
        let data = try await decrypt(encryptedData)
        guard let string = String(data: data, encoding: .utf8) else {
            throw EncryptionError.invalidData
        }
        return string
    }

    /// Rotate encryption key
    func rotateKey() async throws {
        await logger.log(.info, "Rotating encryption key")

        // Generate new key
        let newKey = SymmetricKey(size: .bits256)

        // Store new key
        try await keychainManager.storeKey(newKey, identifier: keyIdentifier)

        await logger.log(.info, "Encryption key rotated successfully")
    }

    // MARK: - Private Methods

    private func getOrCreateEncryptionKey() async throws -> SymmetricKey {
        // Try to retrieve existing key
        if let existingKey = try? await keychainManager.retrieveKey(identifier: keyIdentifier) {
            return existingKey
        }

        // Generate new key
        let newKey = SymmetricKey(size: .bits256)

        // Store in keychain
        try await keychainManager.storeKey(newKey, identifier: keyIdentifier)

        await logger.log(.info, "New encryption key generated and stored")

        return newKey
    }

    private func getEncryptionKey(identifier: String) async throws -> SymmetricKey {
        guard let key = try? await keychainManager.retrieveKey(identifier: identifier) else {
            throw EncryptionError.keyNotFound
        }
        return key
    }
}

// MARK: - Encrypted Data Model

struct EncryptedData: Codable {
    let ciphertext: Data
    let algorithm: EncryptionAlgorithm
    let keyIdentifier: String
    let timestamp: Date

    init(ciphertext: Data, algorithm: EncryptionAlgorithm, keyIdentifier: String) {
        self.ciphertext = ciphertext
        self.algorithm = algorithm
        self.keyIdentifier = keyIdentifier
        self.timestamp = Date()
    }

    enum EncryptionAlgorithm: String, Codable {
        case aesGcm = "AES-GCM-256"
    }
}

// MARK: - Encryption Errors

enum EncryptionError: LocalizedError {
    case encryptionFailed
    case decryptionFailed
    case keyNotFound
    case invalidData
    case unsupportedAlgorithm

    var errorDescription: String? {
        switch self {
        case .encryptionFailed:
            return "Failed to encrypt data"
        case .decryptionFailed:
            return "Failed to decrypt data"
        case .keyNotFound:
            return "Encryption key not found in keychain"
        case .invalidData:
            return "Invalid data format"
        case .unsupportedAlgorithm:
            return "Unsupported encryption algorithm"
        }
    }
}
