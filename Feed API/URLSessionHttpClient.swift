//
//  URLSessionHttpClient.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 19/12/22.
//

import Foundation

public class URLSessionHttpClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedValuesRepresentaion: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { data,response,error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data , let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            }
            else {
                completion(.failure(UnexpectedValuesRepresentaion()))
            }
        }.resume()
    }
    
    public func post(_ data: Data,to url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedValuesRepresentaion()))
            }
        }.resume()
    }
}


public extension URLRequest {
  var httpBodyData: Data? {
    guard let stream = httpBodyStream else { return httpBody }
    
    let bufferSize = 1024
    var data = Data()
    var buffer = [UInt8](repeating: 0, count: bufferSize)
    
    stream.open()
    
    while stream.hasBytesAvailable {
      let length = stream.read(&buffer, maxLength: bufferSize)
      
      if length == 0 {
        break
      }
      
      data.append(&buffer, count: length)
    }
    
    stream.close()
    
    return data
  }
}
