//
//  DeviceContext.swift
//  Forge
//
//  Created by Alexandru Solomon on 08.11.2025.
//

struct DeviceContext {
  let device: DeviceInfo
  let app: AppInfo

  static var current: DeviceContext {
    DeviceContext(device: DeviceInfo.current, app: AppInfo.current)
  }

  var toDictionary: [String: Any] {
    [
      "device_model": device.model,
      "os_version": device.osVersion,
      "os_name": device.platform,
      "app_version": app.version,
      "app_build": app.build,
    ]
  }
}
