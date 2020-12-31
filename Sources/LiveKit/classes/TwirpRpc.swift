//
//  File.swift
//  
//
//  Created by Russell D'Sa on 12/10/20.
//

import Foundation
import Promises
import SwiftProtobuf

struct TwirpRpc {
    static let pkg = "livekit"
    
    static func request<RequestData: SwiftProtobuf.Message, ResponseData: SwiftProtobuf.Message>
    (
        connectOptions: ConnectOptions,
        service: String,
        method: String,
        data: RequestData,
        to: ResponseData.Type
    ) -> Promise<ResponseData>
    {
        let transportProtocol = connectOptions.config.isSecure ? "https" : "http"
        let host = connectOptions.config.host
        let port = connectOptions.config.httpPort
        let prefix = connectOptions.config.rpcPrefix
        
        let urlString = "\(transportProtocol)://\(host):\(port)\(prefix)/\(TwirpRpc.pkg).\(service)/\(method)"
        let jsonData = try? data.jsonUTF8Data()
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = jsonData
        
        let promise = Promise<ResponseData>.pending()
        let task = URLSession.shared.uploadTask(with: urlRequest, from: jsonData) { (data, response, error) in
            if let error = error {
                promise.reject(error)
                return
            }
            do {
                let result = try to.init(jsonUTF8Data: data!)
                promise.fulfill(result)
            } catch {
                print("Error: \(error)")
            }
        }
        task.resume()
        
        return promise
    }
}