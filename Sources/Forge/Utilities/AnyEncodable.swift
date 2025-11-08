//
//  AnyEncodable.swift
//  Forge
//
//  Created by Alexandru Solomon on 07.11.2025.
//

struct AnyEncodable: Encodable, @unchecked Sendable {
  private let _encode: (Encoder) throws -> Void

  init(_ value: some Encodable) {
    _encode = value.encode
  }

  func encode(to encoder: Encoder) throws {
    try _encode(encoder)
  }
}
