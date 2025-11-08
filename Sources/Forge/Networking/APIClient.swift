//
//  APIClient.swift
//  Forge
//
//  Created by Alexandru Solomon on 08.11.2025.
//

import Foundation

final class APIClient: Sendable {
  private let urlSession: URLSession
  private let tokenStore: TokenStore
  
  init(urlSession: URLSession = .shared, tokenStore: TokenStore) {
    self.urlSession = urlSession
    self.tokenStore = tokenStore
  }
  
  @discardableResult
  private func dispatch(_ httpMethod: HTTPMethod, to endpoint: Endpoint, with body: [String: Any]? = nil) async throws -> Data {
    let urlRequest = try await makeURLRequest(httpMethod, to: endpoint, withBody: body)
    
    let (data, response) = try await urlSession.data(for: urlRequest)
    
    if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
      try tryDecodingErrorResponse(data, httpResponse)
    }
    
    return data
  }
  
  private func makeURLRequest(
    _ httpMethod: HTTPMethod,
    to endpoint: Endpoint,
    withBody body: [String: Any]? = nil)
    async throws -> URLRequest
  {
    guard let url = endpoint.url else {
      throw APIClientError.invalidURL(endpoint.rawValue)
    }
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = httpMethod.rawValue
    urlRequest.allHTTPHeaderFields = [
      HTTPHeaderKey.contentType: "application/json",
    ]

    if let token = await tokenStore.currentToken() {
      urlRequest.allHTTPHeaderFields?[HTTPHeaderKey.authorization] = "Bearer \(token)"
    }

    if let body {
      do {
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
      } catch {
        throw APIClientError.invalidBody
      }
    }

    return urlRequest
  }
  
  private func tryDecodingErrorResponse(_ data: Data, _ response: HTTPURLResponse) throws {
    if let apiError = try? APIError.createFrom(data) {
      throw APIClientError.serverError(apiError)
    }
    throw APIClientError.unknownServerError(response.statusCode)
  }
}

// MARK: - API requests

extension APIClient {
  func log(_ entry: LogEntry) async throws {
    try await dispatch(.post, to: .log, with: entry.toDictionary())
  }
  
  func batchLog(_ entries: [LogEntry]) async throws {
    try await dispatch(.post, to: .logs, with: LogEntry.arrayToDictionary(entries))
  }
  
  func registerDevice(_ sdkKey: String) async {
    if await tokenStore.currentToken() != nil {
      return
    }
    
    var body = DeviceContext.current.toDictionary
    body["sdk_key"] = sdkKey
    
    do {
      let data = try await dispatch(.post, to: .registerDevice, with: body)
      let model = try DeviceToken.createFrom(data)
      
      await tokenStore.setDevice(model.token)
    } catch {
      InternalLogger.logError("[ForgeEngine.APIClient] Failed to register device: \(error)")
    }
  }
}

// MARK: - Constants

extension APIClient {
  enum APIClientError: LocalizedError {
    case invalidURL(String)
    case invalidBody
    case serverError(APIError)
    case unknownServerError(Int)
    case notInitialized

    var errorDescription: String? {
      switch self {
      case .invalidURL(let endpoint):
        "URL is invalid. Endpoint: \(endpoint)"
      case .invalidBody:
        "Invalid request body."
      case .serverError(let apiError):
        "Server error. \(apiError.error)"
      case .unknownServerError(let errorCode):
        "Unknown server error. Error code: \(errorCode)"
      case .notInitialized:
        "Device not initialized. Make sure to call `initialize` before using the SDK."
      }
    }
  }
  
  private enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
  }

  private enum Endpoint: String {
    private static let baseUrl = "http://localhost:4000"

    case registerDevice = "/sdk/register_device"
    case log = "/sdk/api/log"
    case logs = "/sdk/api/logs"

    var url: URL? {
      URL(string: Self.baseUrl + rawValue)
    }
  }

  private enum HTTPHeaderKey {
    static let contentType = "Content-Type"
    static let authorization = "Authorization"
  }
}
