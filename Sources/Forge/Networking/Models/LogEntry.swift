//
//  LogEntry.swift
//  Forge
//
//  Created by Alexandru Solomon on 07.11.2025.
//

import Foundation

struct LogEntry: EncodableModel, Equatable {
  enum Level: String, Encodable {
    case debug
    case info
    case warn
    case error
    case fatal
  }

  static func ==(_ lhs: LogEntry, rhs: LogEntry) -> Bool {
    lhs.loggedAt == rhs.loggedAt
  }

  private let level: Level
  private let message: String
  private let context: [String: AnyEncodable]?
  private let fingerprint: String?
  private let source: String?
  private let loggedAt: Date

  init(
    level: Level,
    message: String,
    context: [String: any Encodable]? = nil,
    fingerprint: String? = nil,
    source: String? = nil)
  {
    self.level = level
    self.message = message
    self.fingerprint = fingerprint
    self.source = source
    self.loggedAt = Date()
    self.context = context.map { dictionary in
      dictionary.mapValues { AnyEncodable($0) }
    }
  }
}
