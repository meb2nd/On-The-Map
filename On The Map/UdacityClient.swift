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
    var userID : String? = nil
 
    
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
        
        let request  = buildTheURL(method, parameters: parameters, httpMethod: .POST, headers: headers as [String : AnyObject], jsonBodyParameters: jsonBodyParameters)

        
        /* 4. Make the request */
        return makeTheTask(request: request as URLRequest, errorDomain: "UdacityClient.taskForPOSTMethod", completionHandler: completionHandlerForPOST)

    }
    
    // MARK:  Login
    func authenticateUser(username: String, password: String, completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        let bodyParameters = ["udacity": ["username": username, "password": password]]
        
        _ = taskForPOSTMethod(UdacityClient.Methods.Session, parameters: [:], jsonBodyParameters: bodyParameters as [String : AnyObject], completionHandlerForPOST: { (result, error) in
            
                guard (error == nil) else {
                    
                    print("There was an error in the request: \(String(describing: error))")
                    
                    if let errorCode = ErrorCode(rawValue: (error?.code)!) {
                        switch errorCode {
                        case ErrorCode.REQUEST_ERROR:
                            completionHandlerForAuth(false, "There was a problem contacting the server.")
                        case ErrorCode.RESPONSE_ERROR:
                            completionHandlerForAuth(false, "There was a problem processing the request.")
                        case ErrorCode.SERVER_ERROR:
                            completionHandlerForAuth(false, "There was a server error.")
                        case ErrorCode.SERVER_REFUSED_REQUEST:
                            completionHandlerForAuth(false, "Invalid username and/or password.")
                        }
                    } else {
                        completionHandlerForAuth(false, "There was an error in processing the request.")
                    }
                    
                    return
                }
            
                /* GUARD: Is the "session" key in parsedResult? */
                guard let session = result?[JSONResponseKeys.Session] as? [String: AnyObject] else {
                    
                    print("Cannot find key '\(JSONResponseKeys.Session)' in \(String(describing: result))")
                    completionHandlerForAuth(false, "Cannot find session key.")
                    return
                }
            
                /* GUARD: Is the "account" key in parsedResult? */
                guard let account = result?[JSONResponseKeys.Account] as? [String: AnyObject] else {
                    print("Cannot find key '\(JSONResponseKeys.Account)' in \(String(describing: result))")
                    completionHandlerForAuth(false, "Cannot find account key.")
                    return
                }
            
                /* GUARD: Is the "session ID" key in parsedResult? */
                guard let sessionID =  session[JSONResponseKeys.ID] as? String else {
                    completionHandlerForAuth(false, "Session ID is missing.")
                    return
                }
                /* GUARD: Is the "User ID" key in parsedResult? */
                guard let userID = account[JSONResponseKeys.Key] as? String else {
                    completionHandlerForAuth(false, "User ID is missing.")
                    return
                }
            
                self.sessionID = sessionID
                self.userID = userID
            
                completionHandlerForAuth(true, nil)
            
            }
        )
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


