//
//  ForgeEngine.swift
//  Forge
//
//  Created by Alexandru Solomon on 07.11.2025.
//

import Foundation

final class ForgeEngine: @unchecked Sendable {
  private let client: APIClient
  private let batchSize: Int

  private var continuation: AsyncStream<PipelineEvent>.Continuation?

  private(set) var worker: Task<Void, Never>?
  private(set) var ticker: Task<Void, Never>?

  init(sdkKey: String, flushInterval: TimeInterval, batchSize: Int = 100) {
    self.client = APIClient(tokenStore: TokenStore(sdkKey: sdkKey))
    self.batchSize = batchSize

    let (stream, continuation) = AsyncStream.makeStream(
      of: PipelineEvent.self,
      bufferingPolicy: .bufferingNewest(1_000))
    self.continuation = continuation

    worker = Task {
      await client.registerDevice(sdkKey)

      await LogWorker(client: client, batchSize: batchSize, flushInterval: .seconds(flushInterval)).run(stream: stream)
    }

    ticker = Task {
      let interval = UInt64(flushInterval * 1_000_000_000)
      while !Task.isCancelled {
        try? await Task.sleep(nanoseconds: interval)
        continuation.yield(.tick)
      }
    }
  }

  deinit {
    ticker?.cancel()
    continuation?.finish()

    Task.detached(priority: .background) { [worker] in
      await worker?.value
    }
  }

  func log(
    _ level: LogEntry.Level,
    message: String,
    source: String?,
    fingerprint: String?,
    context: [String: any Encodable],
    file: String,
    function: String,
    line: Int)
  {
    guard let continuation else { return }

    var context = context
    context["file"] = file
    context["function"] = function
    context["line"] = line

    let logEntry = LogEntry(level: level, message: message, context: context, fingerprint: fingerprint, source: source)
    switch continuation.yield(.log(logEntry)) {
    case .enqueued:
      break
    case .dropped(let element):
      InternalLogger.logWarning("Dropped log event because the stream was full: \(element)")
    case .terminated:
      InternalLogger.logWarning("Stream terminated unexpectedly.")
    @unknown default:
      InternalLogger.logWarning("Unknown yield case encountered.")
    }
  }
}
