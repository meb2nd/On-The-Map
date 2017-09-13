//
//  UdacityClient.swift
//  On The Map
//
//  Created by Pete Barnes on 9/11/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import Foundation

// MARK: - ParseClient: NSObject

final class UdacityClient : NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    
    //NetworkClient
    let scheme = UdacityClient.Constants.ApiScheme
    let host = UdacityClient.Constants.ApiHost
    let path = UdacityClient.Constants.ApiPath
    
    // authentication state
    var sessionID : String? = nil
    var userID : Int? = nil
 
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: DELETE
    
    func taskForDELETEMethod(_ method: String, parameters: [String:AnyObject], completionHandlerForDELETE: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        var headers: [String:AnyObject] = [:]
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            headers[HeaderKeys.XSRFToken] = xsrfCookie.value as AnyObject
        }
        
        /* 2/3. Build the URL, Configure the request */
        let request = buildTheURL(method, parameters: parameters, httpMethod: .DELETE, headers: headers)

        
        /* 4. Make the request */
        return makeTheTask(request: request as URLRequest, errorDomain: "UdacityClient.taskForDELETEMethod", completionHandler: completionHandlerForDELETE)
        
    }
    
    // MARK: POST
    
    func taskForPOSTMethod(_ method: String, parameters: [String:AnyObject], jsonBodyParameters: [String:AnyObject], completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        let headers = [HeaderKeys.ContentType: HeaderValues.applicationJSON,
                       HeaderKeys.Accept: HeaderValues.applicationJSON]
        
        /* 2/3. Build the URL, Configure the request */
        
        let request  = buildTheURL(method, parameters: parameters, httpMethod: .POST, headers: headers as [String : AnyObject])

        
        /* 4. Make the request */
        return makeTheTask(request: request as URLRequest, errorDomain: "UdacityClient.taskForPOSTMethod", completionHandler: completionHandlerForPOST)

    }
 
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}

extension UdacityClient: NetworkClient {
    
    func preprocessData (data: Data) -> Data {
        let range = Range(5..<data.count)
        let newData = data.subdata(in: range) /* subset response data! */
        return newData
    }
}


