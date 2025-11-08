//
//  LogWorker.swift
//  Forge
//
//  Created by Alexandru Solomon on 08.11.2025.
//

import Foundation

actor LogWorker {
  private let client: APIClient
  private let batchSize: Int
  private let flushInterval: Duration

  private var buffer: [LogEntry] = []
  private var nextFlush: ContinuousClock.Instant

  init(client: APIClient, batchSize: Int, flushInterval: Duration) {
    self.client = client
    self.batchSize = batchSize
    self.flushInterval = flushInterval
    self.nextFlush = ContinuousClock.now.advanced(by: flushInterval)
  }

  func run(stream: AsyncStream<PipelineEvent>) async {
    for await event in stream {
      if case .log(let entry) = event {
        buffer.append(entry)
      }
      if buffer.count >= batchSize || ContinuousClock.now >= nextFlush {
        await flush()
      }
    }

    await flush()
  }

  private func flush() async {
    guard !buffer.isEmpty else { return }

    let payload = buffer
    do {
      try await client.batchLog(payload)
      buffer.removeAll()
      nextFlush = ContinuousClock.now.advanced(by: flushInterval)
    } catch {
      InternalLogger.logError("[ForgeEngine] Error flushing buffer")
    }
  }
}
