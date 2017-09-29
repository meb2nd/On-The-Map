//
//  UdacityClient.swift
//  On The Map
//
//  Created by Pete Barnes on 9/11/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import Foundation

final class UdacityClient : NSObject {
    
    // MARK: - Properties
    
    // shared session
    var session = URLSession.shared
    
    //NetworkClient
    let scheme = UdacityClient.Constants.ApiScheme
    let host = UdacityClient.Constants.ApiHost
    let path = UdacityClient.Constants.ApiPath
    
    // authentication state
    var sessionID : String? = nil
    var userID : String? = nil
    
    // user info
    var firstName : String? = nil
    var lastName : String? = nil
    
    
    // MARK: - Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: - HTTP Tasks
    
    func taskForGETMethod(_ method: String, parameters: [String:String?], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: APIError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        // No common paramers defined
        
        /* 2/3. Build the URL, Configure the request */
        let request = buildTheURL(method, parameters: parameters)
        
        
        /* 4. Make the request */
        return makeTheTask(request: request as URLRequest, errorDomain: "UdacityClient.taskForGETMethod", completionHandler: completionHandlerForGET)
        
    }
    
    func taskForDELETEMethod(_ method: String, parameters: [String: String?], completionHandlerForDELETE: @escaping (_ result: AnyObject?, _ error: APIError?) -> Void) -> URLSessionDataTask {
        
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
        let request = buildTheURL(method, parameters: parameters, httpMethod: .delete, headers: headers)
        
        
        /* 4. Make the request */
        return makeTheTask(request: request as URLRequest, errorDomain: "UdacityClient.taskForDELETEMethod", completionHandler: completionHandlerForDELETE)
        
    }
    
    func taskForPOSTMethod(_ method: String, parameters: [String: String?], jsonBodyParameters: [String:AnyObject], completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: APIError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        let headers = [HeaderKeys.ContentType: HeaderValues.applicationJSON,
                       HeaderKeys.Accept: HeaderValues.applicationJSON]
        
        /* 2/3. Build the URL, Configure the request */
        
        let request  = buildTheURL(method, parameters: parameters, httpMethod: .post, headers: headers as [String : AnyObject], jsonBodyParameters: jsonBodyParameters)
        
        
        /* 4. Make the request */
        return makeTheTask(request: request as URLRequest, errorDomain: "UdacityClient.taskForPOSTMethod", completionHandler: completionHandlerForPOST)
        
    }
    
    // MARK:  - User Functions
    
    func authenticateUser(username: String, password: String, completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        let bodyParameters = [ParameterKeys.Udacity: [ParameterKeys.UserName: username, ParameterKeys.Password: password]]
        
        _ = taskForPOSTMethod(UdacityClient.Methods.Session, parameters: [:], jsonBodyParameters: bodyParameters as [String : AnyObject], completionHandlerForPOST: { (result, error) in
            
            guard (error == nil) else {
                
                print("There was an error in the request: \(String(describing: error))")
                
                if let error = error {
                    switch error {
                    case .connectionError(error: _) :
                        completionHandlerForAuth(false, "There was a problem contacting the server.")
                    case .missingParametersError(_):
                        completionHandlerForAuth(false, "There was a problem processing the request.")
                    case .serverError(statusCode: let code, error: _):
                        if code == 403 {
                            completionHandlerForAuth(false, "Invalid username and/or password.")
                        } else {
                            completionHandlerForAuth(false, "There was a server error.")
                        }
                    default:
                        completionHandlerForAuth(false, "There was a problem processing the response.")
                    }
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
            
            self.getUserName(completionHandlerForUserName: completionHandlerForAuth)
            
        }
        )
    }
    
    private func getUserName(completionHandlerForUserName: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard let userID = userID, let method = substituteKeyInMethod(UdacityClient.Methods.Users, key: "user_id", value: userID) else {
            
            completionHandlerForUserName(false, "There was an error in creating the user information request.")
            return
        }
        
        _ = taskForGETMethod(method, parameters: [:], completionHandlerForGET: { (result, error) in
            
            guard (error == nil) else {
                
                print("There was an error in the request: \(String(describing: error))")
                
                completionHandlerForUserName(false, "There was an error in processing the User Information request.")
                
                return
            }
            
            /* GUARD: Is the "user" key in parsedResult? */
            guard let user = result?[JSONResponseKeys.User] as? [String: AnyObject] else {
                
                print("Cannot find key '\(JSONResponseKeys.Session)' in \(String(describing: result))")
                completionHandlerForUserName(false, "Cannot find session key.")
                return
            }
            
            /* GUARD: Is the "first name" key in parsedResult? */
            guard let firstName = user[JSONResponseKeys.FirstName] as? String else {
                completionHandlerForUserName(false, "User Information is missing First Name.")
                return
            }
            
            /* GUARD: Is the "last name" key in parsedResult? */
            guard let lastName = user[JSONResponseKeys.LastName] as? String else {
                completionHandlerForUserName(false, "User Information is missing Last Name.")
                return
            }
            
            self.firstName = firstName
            self.lastName = lastName
            completionHandlerForUserName(true, nil)
            
        }
        )
    }
    
    func logout(completionHandlerForLogout: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        _ = taskForDELETEMethod(UdacityClient.Methods.Session, parameters: [:], completionHandlerForDELETE: { (result, error) in
            
            guard (error == nil) else {
                
                print("There was an error in the request: \(String(describing: error))")
                
                completionHandlerForLogout(false, "There was an error in processing the request.")
                
                return
            }
            
            /* GUARD: Is the "session" key in parsedResult? */
            guard let session = result?[JSONResponseKeys.Session] as? [String: AnyObject] else {
                
                print("Cannot find key '\(JSONResponseKeys.Session)' in \(String(describing: result))")
                completionHandlerForLogout(false, "Cannot find session key.")
                return
            }
            
            /* GUARD: Is the "session ID" key in parsedResult? */
            guard (session[JSONResponseKeys.ID] as? String) != nil else {
                completionHandlerForLogout(false, "Session ID is missing.")
                return
            }
            
            self.sessionID = nil
            self.userID = nil
            self.firstName = nil
            self.lastName = nil
            completionHandlerForLogout(true, nil)
            
        }
        )
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}

// MARK: - NetworkClient

extension UdacityClient: NetworkClient {
    
    func preprocessData (data: Data) -> Data {
        let range = Range(5..<data.count)
        let newData = data.subdata(in: range) /* subset response data! */
        return newData
    }
}


