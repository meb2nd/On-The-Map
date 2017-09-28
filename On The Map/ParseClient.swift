//
//  ParseClient.swift
//  On The Map
//
//  Created by Pete Barnes on 9/11/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import Foundation

final class ParseClient : NSObject {
    
    // MARK: - Properties
    
    var students: [StudentInformation] = [StudentInformation]()
    
    // shared session
    var session = URLSession.shared
    
    //NetworkClient
    let scheme = ParseClient.Constants.ApiScheme
    let host = ParseClient.Constants.ApiHost
    let path = ParseClient.Constants.ApiPath
    
    
    // MARK: - Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: - HTTP Tasks
    
    func taskForGETMethod(_ method: String, parameters: [String: String?], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        let headers = [ParameterKeys.RESTApiKey: Constants.RESTApiKey,
                       ParameterKeys.ApplicationID: Constants.ApplicationID]
        
        /* 2/3. Build the URL, Configure the request */
        let request = buildTheURL(method, parameters: parameters, headers: headers as [String : AnyObject])
        
        
        /* 4. Make the request */
        return makeTheTask(request: request as URLRequest, errorDomain: "ParseClient.taskForGETMethod", completionHandler: completionHandlerForGET)
        
    }
    
    func taskForPOSTMethod(_ method: String, parameters: [String:String?], jsonBodyParameters: [String:AnyObject], completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        let headers = [HeaderKeys.ContentType: HeaderValues.applicationJSON,
                       HeaderKeys.Accept: HeaderValues.applicationJSON,
                       ParameterKeys.RESTApiKey: Constants.RESTApiKey,
                       ParameterKeys.ApplicationID: Constants.ApplicationID]
        
        /* 2/3. Build the URL, Configure the request */
        let request  = buildTheURL(method, parameters: parameters, httpMethod: .post, headers: headers as [String : AnyObject], jsonBodyParameters: jsonBodyParameters)
        
        /* 4. Make the request */
        return makeTheTask(request: request as URLRequest, errorDomain: "ParseClient.taskForPOSTMethod", completionHandler: completionHandlerForPOST)
        
    }
    
    func taskForPUTMethod(_ method: String, parameters: [String:String?], jsonBodyParameters: [String:AnyObject], completionHandlerForPUT: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        let headers = [HeaderKeys.ContentType: HeaderValues.applicationJSON,
                       ParameterKeys.RESTApiKey: Constants.RESTApiKey,
                       ParameterKeys.ApplicationID: Constants.ApplicationID]
        
        /* 2/3. Build the URL, Configure the request */
        let request  = buildTheURL(method, parameters: parameters, httpMethod: .put, headers: headers as [String : AnyObject], jsonBodyParameters: jsonBodyParameters)
        
        /* 4. Make the request */
        return makeTheTask(request: request as URLRequest, errorDomain: "ParseClient.taskForPUTMethod", completionHandler: completionHandlerForPUT)
        
    }
    
    // MARK: - Student Location Functions
    
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
    
    func getStudents(_ completionHandlerForStudents: @escaping (_ result: [StudentInformation]?, _ error: Error?) -> Void) {
        
        let parameters = [ParameterKeys.Limit: "100",
                          ParameterKeys.Order: ParameterValues.DescendingUpdatedAt]
        
        _ = taskForGETMethod(Methods.StudentLocation, parameters: parameters){ (result, error) in
            
            guard (error == nil) else {
                
                print("There was an error in the request: \(String(describing: error))")
                
                completionHandlerForStudents(nil, error)
                
                return
            }
            
            /* GUARD: Is the "results" key in parsedResult? */
            guard let students = result?[JSONResponseKeys.StudentResults] as? [[String: AnyObject]] else {
                
                print("Cannot find key '\(JSONResponseKeys.StudentResults)' in \(String(describing: result))")
                completionHandlerForStudents(nil, DecodeError.missingKey(JSONResponseKeys.StudentResults))
                return
            }
            
            completionHandlerForStudents(StudentInformation.StudentInformationFromResults(students), nil)
            
        }
    }
    
    
    func getStudent(_ studentUniqueKey:String, completionHandlerForGetStudent: @escaping (_ result: StudentInformation?, _ error: Error?) -> Void) {
        
        guard !studentUniqueKey.isEmpty else {
            completionHandlerForGetStudent(nil, APIError.missingParametersError("Missing Student Unique Key"))
            return
        }
        
        let parameters = [ParameterKeys.Where: "{\"\(ParameterKeys.StudentUniqueKey)\":\"\(studentUniqueKey)\"}"]
        
        _ = taskForGETMethod(Methods.StudentLocation, parameters: parameters){ (result, error) in
            
            guard (error == nil) else {
                
                print("There was an error in the request: \(String(describing: error))")
                
                completionHandlerForGetStudent(nil, error)
                
                return
            }
            
            /* GUARD: Is the "results" key in parsedResult? */
            guard let students = result?[JSONResponseKeys.StudentResults] as? [[String: AnyObject]] else {
                
                print("Cannot find key '\(JSONResponseKeys.StudentResults)' in \(String(describing: result))")
                completionHandlerForGetStudent(nil, DecodeError.missingKey(JSONResponseKeys.StudentResults))
                return
            }
            
            guard students.count > 0 else {
                print("No student found in the results")
                completionHandlerForGetStudent(nil, nil)
                return
            }
            
            completionHandlerForGetStudent(StudentInformation.StudentInformationFromResults(students).first, nil)
            
        }
    }
    
    
    func putStudentLocation(_ studentInformation: StudentInformation, completionHandlerForPutStudentLocation: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard let method = substituteKeyInMethod(Methods.StudentLocationObjectID, key: URLKeys.StudentObjectID, value: studentInformation.studentObjectID) else {
            
            print("There was an error in the request. Could not generate method with student object ID.")
            
            completionHandlerForPutStudentLocation(false, "There was an error in processing the Put Student Location request.")
            
            return
        }
        
        let jsonBodyParameters = [ParameterKeys.StudentUniqueKey: studentInformation.studentUniqueKey,
                                  ParameterKeys.StudentFirstName: studentInformation.studentFirstName,
                                  ParameterKeys.StudentLastName: studentInformation.studentLastName,
                                  ParameterKeys.StudentMapString: studentInformation.studentMapString,
                                  ParameterKeys.StudentMediaURL: studentInformation.studentMediaURL,
                                  ParameterKeys.StudentLatitude: studentInformation.studentLatitude,
                                  ParameterKeys.StudentLongitude: studentInformation.studentLongitude] as [String : AnyObject]
        
        
        
        _ = taskForPUTMethod(method, parameters: [:], jsonBodyParameters: jsonBodyParameters as [String : AnyObject]){ (result, error) in
            
            guard (error == nil) else {
                
                print("There was an error in the request: \(String(describing: error))")
                
                completionHandlerForPutStudentLocation(false, "There was an error in processing the Put Student Location request.")
                
                return
            }
            
            /* GUARD: Is the "updated at" key in parsedResult? */
            guard result?[JSONResponseKeys.StudentUpdatedAt] as? String != nil else {
                
                print("Cannot find key '\(JSONResponseKeys.StudentUpdatedAt)' in \(String(describing: result))")
                completionHandlerForPutStudentLocation(false, "Cannot find student 'updatedAt' key.")
                return
            }
            
            completionHandlerForPutStudentLocation(true, nil)
        }
    }
    
    
    func postStudentLocation(_ studentInformation: StudentInformation, completionHandlerForPostStudentLocation: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        
        let jsonBodyParameters = [ParameterKeys.StudentUniqueKey: studentInformation.studentUniqueKey,
                                  ParameterKeys.StudentFirstName: studentInformation.studentFirstName,
                                  ParameterKeys.StudentLastName: studentInformation.studentLastName,
                                  ParameterKeys.StudentMapString: studentInformation.studentMapString,
                                  ParameterKeys.StudentMediaURL: studentInformation.studentMediaURL,
                                  ParameterKeys.StudentLatitude: studentInformation.studentLatitude,
                                  ParameterKeys.StudentLongitude: studentInformation.studentLongitude] as [String : AnyObject]
        
        
        
        _ = taskForPOSTMethod(Methods.StudentLocation, parameters: [:], jsonBodyParameters: jsonBodyParameters as [String : AnyObject]){ (result, error) in
            
            guard (error == nil) else {
                
                print("There was an error in the request: \(String(describing: error))")
                
                completionHandlerForPostStudentLocation(false, "There was an error in processing the Post Student Location request.")
                
                return
            }
            
            /* GUARD: Is the "object ID" key in parsedResult? */
            guard result?[JSONResponseKeys.StudentObjectID] as? String != nil else {
                
                print("Cannot find key '\(JSONResponseKeys.StudentObjectID)' in \(String(describing: result))")
                completionHandlerForPostStudentLocation(false, "Cannot find student 'objectID' key.")
                return
            }
            
            completionHandlerForPostStudentLocation(true, nil)
        }
    }
    
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}

// MARK: - ParseClient: NetworkClient

extension ParseClient: NetworkClient {
    
    func preprocessData (data: Data) -> Data {
        return data
    }
}
