//
//  DeviceConfiguration.swift
//  Forge
//
//  Created by Alexandru Solomon on 08.11.2025.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

// MARK: - DeviceInfo

struct DeviceInfo {
  let model: String
  let osVersion: String
  let platform: String

  @MainActor
  static var current: DeviceInfo {
    #if os(macOS)
    return DeviceInfo(model: "Mac", osVersion: ProcessInfo.processInfo.operatingSystemVersionString, platform: "macos")
    #elseif os(iOS)
    return DeviceInfo(model: UIDevice.current.model, osVersion: UIDevice.current.systemVersion, platform: "os")
    #elseif os(watchOS)
    return DeviceInfo(model: "Apple Watch", osVersion: WKInterfaceDevice.current().systemVersion, platform: "watchos")
    #elseif os(tvOS)
    return DeviceInfo(model: "Apple TV", osVersion: UIDevice.current.systemVersion, platform: "tvos")
    #else
    return DeviceInfo(model: "unknown", osVersion: "unknown", platform: "unknown")
    #endif
  }
}
