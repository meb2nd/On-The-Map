//
//  StudentInformationHandler.swift
//  On The Map
//
//  Created by Pete Barnes on 9/11/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

class StudentInformationHandler {
    
    // MARK: - Properties
    var students: [StudentInformation]?
    
    var student: StudentInformation?
    
    // MARK: - Refresh Student Data
    
    func refreshStudentData(completionHandlerForRefreshStudentData: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
    
        ParseClient.sharedInstance().getStudents() { (result, error) in
        
            if let students = result {
                self.students = students
                self.refreshStudentLocation(completionHandlerForRefreshStudentLocation: completionHandlerForRefreshStudentData)
            } else if let error = error {            
                var errorString:String
                switch error as APIError  {
                case .connectionError:
                    errorString = "Could not connect to server, try again later."
                default:
                    errorString = "Could not retrieve student data."
                }
                completionHandlerForRefreshStudentData(false, errorString)
            } else {
                completionHandlerForRefreshStudentData(false, "Could not retrieve student data.")
            }
        }
    }
    
    fileprivate func refreshStudentLocation(completionHandlerForRefreshStudentLocation: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        guard let userID = UdacityClient.sharedInstance().userID else {
            completionHandlerForRefreshStudentLocation(true, "Could not retrieve logged-in student data.")
            return
        }
        ParseClient.sharedInstance().getStudent(userID) { (result, error) in
            
            // If no error and no exisiting student we're good
            guard result != nil || error != nil else {
                completionHandlerForRefreshStudentLocation(true, nil)
                return
            }
            
            if let student = result {
                self.student = student
                completionHandlerForRefreshStudentLocation(true, nil)
            } else if let error = error {
                var errorString:String
                switch error as APIError  {
                case .connectionError:
                    errorString = "Could not connect to server, try again later."
                default:
                    errorString = "Could not retrieve logged-in student data."
                }
                print(error)
                completionHandlerForRefreshStudentLocation(false, errorString)
            } else {
                print(error as Any)
                completionHandlerForRefreshStudentLocation(false, "Could not retrieve logged-in student data.")
            }
        }
    }
}

