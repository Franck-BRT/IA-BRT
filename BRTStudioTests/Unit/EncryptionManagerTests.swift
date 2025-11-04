//
//  EncryptionManagerTests.swift
//  BRT Studio Tests - Encryption Manager Tests
//
//  Copyright © 2025 Black Room Technologies. All rights reserved.
//

import XCTest
@testable import BRTStudio

final class EncryptionManagerTests: XCTestCase {

    var encryptionManager: EncryptionManager!

    override func setUp() async throws {
        encryptionManager = EncryptionManager.shared
    }

    func testEncryptDecryptData() async throws {
        let originalData = "Hello, World! This is sensitive data.".data(using: .utf8)!

        // Encrypt
        let encryptedData = try await encryptionManager.encrypt(originalData)

        XCTAssertNotNil(encryptedData, "Encrypted data should not be nil")
        XCTAssertNotEqual(encryptedData.ciphertext, originalData, "Ciphertext should differ from original")
        XCTAssertEqual(encryptedData.algorithm, .aesGcm, "Algorithm should be AES-GCM")

        // Decrypt
        let decryptedData = try await encryptionManager.decrypt(encryptedData)

        XCTAssertEqual(decryptedData, originalData, "Decrypted data should match original")
    }

    func testEncryptDecryptString() async throws {
        let originalString = "Sensitive information 🔐"

        // Encrypt
        let encryptedData = try await encryptionManager.encrypt(originalString)

        XCTAssertNotNil(encryptedData, "Encrypted data should not be nil")

        // Decrypt
        let decryptedString = try await encryptionManager.decryptToString(encryptedData)

        XCTAssertEqual(decryptedString, originalString, "Decrypted string should match original")
    }

    func testEncryptionProducesUniqueCiphertext() async throws {
        let originalData = "Same data".data(using: .utf8)!

        // Encrypt same data twice
        let encrypted1 = try await encryptionManager.encrypt(originalData)
        let encrypted2 = try await encryptionManager.encrypt(originalData)

        // Ciphertexts should differ due to unique nonces in AES-GCM
        XCTAssertNotEqual(encrypted1.ciphertext, encrypted2.ciphertext, "Each encryption should produce unique ciphertext")

        // Both should decrypt to same original
        let decrypted1 = try await encryptionManager.decrypt(encrypted1)
        let decrypted2 = try await encryptionManager.decrypt(encrypted2)

        XCTAssertEqual(decrypted1, originalData)
        XCTAssertEqual(decrypted2, originalData)
    }

    func testDecryptionFailsWithTamperedData() async throws {
        let originalData = "Secret data".data(using: .utf8)!

        // Encrypt
        var encryptedData = try await encryptionManager.encrypt(originalData)

        // Tamper with ciphertext
        var tamperedCiphertext = encryptedData.ciphertext
        if tamperedCiphertext.count > 10 {
            tamperedCiphertext[5] ^= 0xFF // Flip bits
        }
        encryptedData.ciphertext = tamperedCiphertext

        // Decryption should fail
        do {
            _ = try await encryptionManager.decrypt(encryptedData)
            XCTFail("Decryption should fail with tampered data")
        } catch {
            // Expected to throw
            XCTAssertTrue(true, "Decryption correctly failed with tampered data")
        }
    }

    func testEmptyDataEncryption() async throws {
        let emptyData = Data()

        let encryptedData = try await encryptionManager.encrypt(emptyData)
        let decryptedData = try await encryptionManager.decrypt(encryptedData)

        XCTAssertEqual(decryptedData, emptyData, "Empty data should encrypt and decrypt correctly")
    }

    func testLargeDataEncryption() async throws {
        // Create 1MB of data
        let largeData = Data(repeating: 0x42, count: 1024 * 1024)

        let encryptedData = try await encryptionManager.encrypt(largeData)
        let decryptedData = try await encryptionManager.decrypt(encryptedData)

        XCTAssertEqual(decryptedData, largeData, "Large data should encrypt and decrypt correctly")
    }
}
