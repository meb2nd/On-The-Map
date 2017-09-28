//
//  NetworkClient.swift
//  On The Map
//
//  Created by Pete Barnes on 9/11/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import Foundation

// MARK: - HTTPMethod

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// MARK: - ErrorCode

enum ErrorCode: Int {
    case REQUEST_ERROR = 100
    case SERVER_ERROR = 200
    case SERVER_REFUSED_REQUEST = 201
    case RESPONSE_ERROR = 300
}

// MARK: - NetworkClient

protocol NetworkClient {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    
    func preprocessData (data: Data) -> Data
}

// Enums below from suggestions at:  https://appventure.me/2015/10/17/advanced-practical-enum-examples/#errortype

// MARK: - HttpError

enum HttpError: String {
    case Code400 = "Bad Request"
    case Code401 = "Unauthorized"
    case Code402 = "Payment Required"
    case Code403 = "Forbidden"
    case Code404 = "Not Found"
}

// MARK: - DecodeError

enum DecodeError: Error {
    case TypeMismatch(expected: String, actual: String)
    case MissingKey(String)
    case Custom(String)
}

// MARK: - APIError

enum APIError : Error {
    // Missing parameters to make request
    case MissingParametersError(String)
    // Can't connect to the server (maybe offline?)
    case ConnectionError(error: NSError)
    // The server responded with a non 200 status code
    case ServerError(statusCode: Int, error: NSError)
    // We got no data (0 bytes) back from the server
    case NoDataError
    // The server response can't be converted from JSON to a Dictionary
    case JSONSerializationError(error: Error)
    // The decoding Failed
    case JSONMappingError(converstionError: DecodeError)
}

// MARK: - NetworkClient

extension NetworkClient {
    
    
    func buildTheURL(_ method: String, parameters: [String: String?], httpMethod: HTTPMethod = .GET, headers: [String:AnyObject] = [:], jsonBodyParameters: [String:AnyObject] = [:]) -> NSMutableURLRequest {
        
        let request = NSMutableURLRequest(url: buildURLFromParameters(parameters, withPathExtension: method))
        
        request.httpMethod = httpMethod.rawValue
        
        let headersKeys = headers.keys
        
        for key in headersKeys {
            request.addValue((headers[key] as? String)!, forHTTPHeaderField: key)
        }
        
        if jsonBodyParameters.count > 0 {
            let postData: Data!
            do {
                postData =  try JSONSerialization.data(withJSONObject: jsonBodyParameters, options: .prettyPrinted)
            } catch {
                print("Could not create JSON data from \(jsonBodyParameters)")
                return request
            }
            
            request.httpBody = postData
        }
        
        return request
    }
    
    func makeTheTask(request: URLRequest, errorDomain: String, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        var session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            
            func sendError(_ error: String,_ errorCode: ErrorCode) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandler(nil, NSError(domain: errorDomain, code: errorCode.rawValue, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)", ErrorCode.REQUEST_ERROR)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                
                if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 403 {
                    sendError("Your request returned a status code of 403!", ErrorCode.SERVER_REFUSED_REQUEST)
                } else {
                    sendError("Your request returned a status code other than 2xx!", ErrorCode.SERVER_ERROR)
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!", ErrorCode.RESPONSE_ERROR)
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */

            let newData = self.preprocessData(data: data)
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandler)
        }
        
        /* 7. Start the request */
        task.resume()
        
        
        return task
    }
    
    
    
    // MARK: Helpers
    
    // substitute the key for the value that is contained within the method name
    func substituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    
    // create a URL from parameters
    private func buildURLFromParameters(_ parameters: [String:String?], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: value)
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
}
