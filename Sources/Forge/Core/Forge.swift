//
//  Forge.swift
//  Forge
//
//  Created by Alexandru Solomon on 07.11.2025.
//

import Foundation
import os

public class Forge: @unchecked Sendable {
  private static let instance = Forge()
  private var engine: ForgeEngine?
  private let initLock = OSAllocatedUnfairLock(initialState: ())

  private static func guardEngine() -> ForgeEngine? {
    guard let engine = instance.engine else {
      InternalLogger.logWarning("[Forge]: Forge not initialized. Make sure to call `Forge.initialize(sdkKey:)` first.")
      return nil
    }
    return engine
  }

  public static func initialize(_ sdkKey: String, flushInterval: TimeInterval = 10) {
    instance.initLock.withLock { _ in
      guard instance.engine == nil else { return }
      instance.engine = ForgeEngine(sdkKey: sdkKey, flushInterval: flushInterval)
    }
  }

  public static func logInfo(
    _ message: String,
    context: [String: any Encodable] = [:],
    source: String? = nil,
    fingerprint: String? = nil,
    file: String = #file,
    function: String = #function,
    line: Int = #line)
  {
    guard let engine = guardEngine() else { return }

    engine.log(
      .info,
      message: message,
      source: source,
      fingerprint: fingerprint,
      context: context,
      file: file,
      function: function,
      line: line)
  }

  public static func logDebug(
    _ message: String,
    context: [String: any Encodable] = [:],
    source: String? = nil,
    fingerprint: String? = nil,
    file: String = #file,
    function: String = #function,
    line: Int = #line)
  {
    guard let engine = guardEngine() else { return }

    engine.log(
      .debug,
      message: message,
      source: source,
      fingerprint: fingerprint,
      context: context,
      file: file,
      function: function,
      line: line)
  }

  public static func logWarning(
    _ message: String,
    context: [String: any Encodable] = [:],
    source: String? = nil,
    fingerprint: String? = nil,
    file: String = #file,
    function: String = #function,
    line: Int = #line)
  {
    guard let engine = guardEngine() else { return }

    engine.log(
      .warn,
      message: message,
      source: source,
      fingerprint: fingerprint,
      context: context,
      file: file,
      function: function,
      line: line)
  }

  public static func logError(
    _ error: Error,
    _ message: String = "",
    context: [String: any Encodable] = [:],
    source: String? = nil,
    fingerprint: String? = nil,
    file: String = #file,
    function: String = #function,
    line: Int = #line)
  {
    guard let engine = guardEngine() else { return }

    var context = context
    context["error_type"] = String((error as NSError).domain)
    context["error_description"] = error.localizedDescription

    engine.log(
      .error,
      message: message,
      source: source,
      fingerprint: fingerprint,
      context: context,
      file: file,
      function: function,
      line: line)
  }
}
