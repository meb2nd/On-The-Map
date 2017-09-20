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
    
    var students: [StudentInformation] = [StudentInformation]()
    
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
    
    func taskForGETMethod(_ method: String, parameters: [String: String?], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        let headers = [ParameterKeys.RESTApiKey: Constants.RESTApiKey,
                       ParameterKeys.ApplicationID: Constants.ApplicationID]
        
        /* 2/3. Build the URL, Configure the request */
        let request = buildTheURL(method, parameters: parameters, headers: headers as [String : AnyObject])

        
        /* 4. Make the request */
        return makeTheTask(request: request as URLRequest, errorDomain: "ParseClient.taskForGETMethod", completionHandler: completionHandlerForGET)
        
    }
    
    // MARK: POST
    
    func taskForPOSTMethod(_ method: String, parameters: [String:String?], jsonBodyParameters: [String:AnyObject], completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        let headers = [HeaderKeys.ContentType: HeaderValues.applicationJSON,
                       HeaderKeys.Accept: HeaderValues.applicationJSON,
                       ParameterKeys.RESTApiKey: Constants.RESTApiKey,
                       ParameterKeys.ApplicationID: Constants.ApplicationID]
        
        /* 2/3. Build the URL, Configure the request */
        let request  = buildTheURL(method, parameters: parameters, httpMethod: .POST, headers: headers as [String : AnyObject], jsonBodyParameters: jsonBodyParameters)
        
        /* 4. Make the request */
        return makeTheTask(request: request as URLRequest, errorDomain: "ParseClient.taskForPOSTMethod", completionHandler: completionHandlerForPOST)

    }
    
    // MARK: Refresh Student Locations
    func refreshStudentLocations(completionHandlerForStudentLocations: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let parameters = [ParameterKeys.Limit: "100",
                          ParameterKeys.Order: ParameterValues.DescendingUpdatedAt]
        
        _ = taskForGETMethod(Methods.StudentLocation, parameters: parameters){ (result, error) in
            
            guard (error == nil) else {
                
                print("There was an error in the request: \(String(describing: error))")
                
                completionHandlerForStudentLocations(false, "There was an error in processing the Student Locations request.")
                
                return
            }
            
            /* GUARD: Is the "results" key in parsedResult? */
            guard let students = result?[JSONResponseKeys.StudentResults] as? [[String: AnyObject]] else {
                
                print("Cannot find key '\(JSONResponseKeys.StudentResults)' in \(String(describing: result))")
                completionHandlerForStudentLocations(false, "Cannot find results key.")
                return
            }
            
            self.students = StudentInformation.StudentInformationFromResults(students)
            completionHandlerForStudentLocations(true, nil)

        }
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
