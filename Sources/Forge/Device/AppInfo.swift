//
//  AppInfo.swift
//  Forge
//
//  Created by Alexandru Solomon on 08.11.2025.
//

import Foundation

struct AppInfo {
  let name: String
  let version: String
  let build: String
  let bundleIdentifier: String

  static var current: AppInfo {
    let bundle = Bundle.main
    return AppInfo(
      name: bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown",
      version: bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown",
      build: bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown",
      bundleIdentifier: bundle.bundleIdentifier ?? "Unknown")
  }
}
