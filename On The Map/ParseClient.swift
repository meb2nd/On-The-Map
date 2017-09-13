//
//  ParseClient.swift
//  On The Map
//
//  Created by Pete Barnes on 9/11/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import Foundation

// MARK: - ParseClient: NSObject

final class ParseClient : NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    
    //NetworkClient
    let scheme = ParseClient.Constants.ApiScheme
    let host = ParseClient.Constants.ApiHost
    let path = ParseClient.Constants.ApiPath

    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: GET
    
    func taskForGETMethod(_ method: String, parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        var parametersWithApiKeys = parameters
        parametersWithApiKeys[ParameterKeys.RESTApiKey] = Constants.RESTApiKey as AnyObject?
        parametersWithApiKeys[ParameterKeys.ApplicationID] = Constants.ApplicationID as AnyObject?
        
        /* 2/3. Build the URL, Configure the request */
        let request = buildTheURL(method, parameters: parametersWithApiKeys)

        
        /* 4. Make the request */
        return makeTheTask(request: request as URLRequest, errorDomain: "taskForGETMethod", completionHandler: completionHandlerForGET)
        
    }
    
    // MARK: POST
    
    func taskForPOSTMethod(_ method: String, parameters: [String:AnyObject], jsonBodyParameters: [String:AnyObject], completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        var parametersWithApiKeys = parameters
        parametersWithApiKeys[ParameterKeys.RESTApiKey] = Constants.RESTApiKey as AnyObject?
        parametersWithApiKeys[ParameterKeys.ApplicationID] = Constants.ApplicationID as AnyObject?
        let headers = [HeaderKeys.ContentType: HeaderValues.applicationJSON,
                       HeaderKeys.Accept: HeaderValues.applicationJSON]
        
        /* 2/3. Build the URL, Configure the request */
        let request  = buildTheURL(method, parameters: parametersWithApiKeys, httpMethod: .POST, headers: headers as [String : AnyObject])
        
        /* 4. Make the request */
        return makeTheTask(request: request as URLRequest, errorDomain: "taskForPOSTMethod", completionHandler: completionHandlerForPOST)

    }
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}

extension ParseClient: NetworkClient {
    
    func preprocessData (data: Data) -> Data {
        return data
    }
}
