//
//  DecodableModel.swift
//  Formingo iOS SDK
//
//  Copyright © 2025 Genvera SRL. All rights reserved.
//

import Foundation

// MARK: - DecodableModel

protocol DecodableModel: Codable { }

extension DecodableModel {
  static func createFrom(_ data: Data) throws -> Self {
    do {
      return try JSONHelper.decoder.decode(Self.self, from: data)
    } catch let error as DecodingError {
      throw DecodableModelError.decodingError(error.prettyDescription)
    } catch {
      throw DecodableModelError.invalidJSONData
    }
  }

  static func createArrayFrom(_ data: Data) throws -> [Self] {
    do {
      return try JSONHelper.decoder.decode([Self].self, from: data)
    } catch let error as DecodingError {
      throw DecodableModelError.decodingError(error.prettyDescription)
    } catch {
      throw DecodableModelError.invalidJSONData
    }
  }
}

// MARK: - JSONHelper

enum DecodableModelError: LocalizedError {
  case decodingError(String)
  case invalidJSONData

  var localizedDescription: String {
    switch self {
    case .decodingError(let message):
      "Decoding Error: \(message)"
    case .invalidJSONData:
      "Invalid JSON data"
    }
  }
}

extension DecodingError {
  fileprivate var prettyDescription: String {
    switch self {
    case .typeMismatch(let type, let context):
      "DecodingError.typeMismatch \(type), value \(context.prettyDescription) @ ERROR: \(localizedDescription)"
    case .valueNotFound(let type, let context):
      "DecodingError.valueNotFound \(type), value \(context.prettyDescription) @ ERROR: \(localizedDescription)"
    case .keyNotFound(let key, let context):
      "DecodingError.keyNotFound \(key), value \(context.prettyDescription) @ ERROR: \(localizedDescription)"
    case .dataCorrupted(let context):
      "DecodingError.dataCorrupted \(context.prettyDescription), @ ERROR: \(localizedDescription)"
    default:
      "DecodingError: \(localizedDescription)"
    }
  }
}

extension DecodingError.Context {
  fileprivate var prettyDescription: String {
    var result = ""
    if !codingPath.isEmpty {
      result.append(codingPath.map(\.stringValue).joined(separator: "."))
      result.append(": ")
    }
    result.append(debugDescription)
    if
      let nsError = underlyingError as? NSError,
      let description = nsError.userInfo["NSDebugDescription"] as? String
    {
      result.append(description)
    }
    return result
  }
}
