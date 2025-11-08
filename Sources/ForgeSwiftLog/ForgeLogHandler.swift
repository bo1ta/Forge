//
//  ForgeLogHandler.swift
//  ForgeSwiftLog
//
//  Created by Alexandru Solomon on 08.11.2025.
//

import Foundation
import Logging
import Forge

public struct ForgeLogHandler: LogHandler {
  public var metadata: Logger.Metadata = [:]
  public var logLevel: Logger.Level = .trace
  
  private let label: String
  
  public init(label: String) {
    self.label = label
  }
  
  public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
    get { metadata[key] }
    set { metadata[key] = newValue }
  }
  
  public func log(level: Logger.Level, message: Logger.Message, metadata explicitMetadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
    var context = ["logger_label": label] as [String: any Encodable]

    let mergedMetadata = metadata.merging(explicitMetadata ?? [:]) { $1 }
    for (key, value) in mergedMetadata {
      context[key] = value.description
    }
    
    let source = source.isEmpty ? label : source
    
    switch level {
    case .trace, .debug:
      Forge.logDebug(message.description, context: context, source: source, fingerprint: nil, file: file, function: function, line: Int(line))
    case .info:
      Forge.logInfo(message.description, context: context, source: source, fingerprint: nil, file: file, function: function, line: Int(line))
    case .notice, .warning:
      Forge.logWarning(message.description, context: context, source: source, fingerprint: nil, file: file, function: function, line: Int(line))
    case .error, .critical:
      Forge.logError(message.description, context: context, source: source, fingerprint: nil, file: file, function: function, line: Int(line))
    }
  }
}
