//
//  TokenStore.swift
//  Forge
//
//  Created by Alexandru Solomon on 08.11.2025.
//

import Foundation
import os

actor TokenStore {
  private var cachedToken: String?

  private let keychainKey: String
  private let keychain = KeychainManager()

  init(sdkKey: String) {
    self.keychainKey = "device_\(sdkKey)"
  }

  func currentToken() -> String? {
    if let cachedToken {
      return cachedToken
    }

    do {
      guard let data = try keychain.get(byKey: keychainKey) else { return nil }

      let token = String(data: data, encoding: .utf8)
      self.cachedToken = token

      return token
    } catch {
      InternalLogger.logError("Error retrieving device from keychain: \(error)")
      return nil
    }
  }

  func setDevice(_ token: String?) async {
    cachedToken = token
    do {
      if let token, let data = token.data(using: .utf8) {
        try keychain.set(data, forKey: keychainKey)
      } else {
        try keychain.delete(byKey: keychainKey)
      }
    } catch {
      InternalLogger.logError("[TokenStore] Failed to set device")
    }
  }
}
