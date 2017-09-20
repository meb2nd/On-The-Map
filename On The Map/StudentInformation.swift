//
//  StudentInformation.swift
//  On The Map
//
//  Created by Pete Barnes on 9/11/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

// MARK: - StudentInformation

struct StudentInformation {
    
    
    // MARK: Properties
   
    let studentUniqueKey: String
    let studentFirstName: String
    let studentLastName: String
    let studentMapString: String
    let studentMediaURL: String
    let studentLatitude: Float
    let studentLongitude: Float
    let studentObjectID: String

    
    // MARK: Initializers
    
    // construct a StudentInformation from a dictionary
    init(dictionary: [String:AnyObject]) {
        studentUniqueKey = dictionary[ParseClient.JSONResponseKeys.StudentUniqueKey] as! String
        studentFirstName = dictionary[ParseClient.JSONResponseKeys.StudentFirstName] as! String
        studentLastName = dictionary[ParseClient.JSONResponseKeys.StudentLastName] as! String
        studentMapString = dictionary[ParseClient.JSONResponseKeys.StudentMapString] as! String
        studentMediaURL = dictionary[ParseClient.JSONResponseKeys.StudentMediaURL] as! String
        studentLatitude = dictionary[ParseClient.JSONResponseKeys.StudentLatitude] as! Float
        studentLongitude = dictionary[ParseClient.JSONResponseKeys.StudentLongitude] as! Float
        studentObjectID = dictionary[ParseClient.JSONResponseKeys.StudentObjectID] as! String
    }
    
    static func StudentInformationFromResults(_ results: [[String:AnyObject]]) -> [StudentInformation] {
        
        var students = [StudentInformation]()
        
        // iterate through array of dictionaries, each Student is a dictionary
        for result in results {
            
            if isDictionaryComplete(result) {
                students.append(StudentInformation(dictionary: result))
            }
            
        }
        
        return students
    }
    
    static private func isDictionaryComplete (_ dictionary: [String: AnyObject]) -> Bool {
        if (dictionary[ParseClient.JSONResponseKeys.StudentUniqueKey] != nil) &&
           (dictionary[ParseClient.JSONResponseKeys.StudentFirstName] != nil) &&
           (dictionary[ParseClient.JSONResponseKeys.StudentLastName] != nil) &&
           (dictionary[ParseClient.JSONResponseKeys.StudentMapString] != nil) &&
           (dictionary[ParseClient.JSONResponseKeys.StudentMediaURL] != nil) &&
           (dictionary[ParseClient.JSONResponseKeys.StudentLatitude] != nil) &&
           (dictionary[ParseClient.JSONResponseKeys.StudentLongitude] != nil) &&
           (dictionary[ParseClient.JSONResponseKeys.StudentObjectID] != nil) {
            return true
        } else {
            return false
        }

    }
}

// MARK: - StudentInformation: Equatable

extension StudentInformation: Equatable {}

func ==(lhs: StudentInformation, rhs: StudentInformation) -> Bool {
    return lhs.studentUniqueKey == rhs.studentUniqueKey
}
