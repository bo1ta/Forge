//
//  EncodableModel.swift
//  Formingo iOS SDK
//
//  Copyright © 2025 Genvera SRL. All rights reserved.
//

import Foundation

// MARK: - EncodableModel

protocol EncodableModel: Encodable { }

extension EncodableModel {
  func toDictionary() -> [String: Any]? {
    guard let data = try? JSONHelper.encoder.encode(self) else { return nil }

    guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    else { return nil }

    return dictionary
  }

  func toData() -> Data? {
    try? JSONHelper.encoder.encode(self)
  }

  static func arrayToDictionary(_ array: [Self]) -> [[String: Any]]? {
    guard let data = try? JSONHelper.encoder.encode(array) else {
      return nil
    }

    guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] else {
      return nil
    }

    return dictionary
  }
}
