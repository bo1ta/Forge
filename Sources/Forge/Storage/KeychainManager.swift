//
//  KeychainManager.swift
//  Forge
//
//  Created by Alexandru Solomon on 08.11.2025.
//

import Foundation
import Security

struct KeychainManager: Sendable {
  private static let service = "Forge"

  func set(_ value: Data, forKey key: String) throws {
    try delete(byKey: key)

    let addQuery: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: Self.service,
      kSecAttrAccount as String: key,
      kSecValueData as String: value,
    ]

    let status = SecItemAdd(addQuery as CFDictionary, nil)
    guard status == errSecSuccess else {
      throw KeychainError.failedToInsert(status)
    }
  }

  func get(byKey key: String) throws -> Data? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: Self.service,
      kSecAttrAccount as String: key,
      kSecMatchLimit as String: kSecMatchLimitOne,
      kSecReturnData as String: true,
    ]

    var item: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &item)

    guard status == errSecSuccess else {
      return nil
    }

    return item as? Data
  }

  func delete(byKey key: String) throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: Self.service,
      kSecAttrAccount as String: key,
    ]

    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw KeychainError.failedToDelete(status)
    }
  }

  enum KeychainError: Error {
    case failedToInsert(OSStatus)
    case failedToDelete(OSStatus)
  }
}
