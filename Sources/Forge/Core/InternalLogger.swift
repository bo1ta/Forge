//
//  InternalLogger.swift
//  Forge
//
//  Created by Alexandru Solomon on 08.11.2025.
//

import Foundation

enum InternalLogger {
  private static var isDebug: Bool {
    #if DEBUG
    return true
    #else
    return false
    #endif
  }

  static func logInfo(_ message: String) {
    guard isDebug else { return }

    print("[INFO] \(message)")
  }

  static func logError(_ message: String) {
    guard isDebug else { return }

    print("[ERROR] \(message)")
  }

  static func logWarning(_ message: String) {
    guard isDebug else { return }

    print("[WARNING] \(message)")
  }
}
