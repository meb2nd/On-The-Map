//
//  StudentInformationHandler.swift
//  On The Map
//
//  Created by Pete Barnes on 9/11/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

// MARK: - StudentInformationHandler

class StudentInformationHandler {
    
    // MARK: Properties
    var students: [StudentInformation]?
    
    func refreshStudentData(completionHandlerForRefreshStudentData: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
    
        ParseClient.sharedInstance().getStudents() { (result, error) in
        
            if let students = result {
                self.students = students
                completionHandlerForRefreshStudentData(true, nil)
            } else if let error = error as? APIError {            
                var errorString:String
                switch error as APIError  {
                case .ConnectionError:
                    errorString = "Could not connect to server, try again later."
                default:
                    errorString = "Could not retrieve student map data."
                }
                completionHandlerForRefreshStudentData(false, errorString)
            } else {
                completionHandlerForRefreshStudentData(false, "Could not retrieve student map data.")
            }
        }
    }
}

