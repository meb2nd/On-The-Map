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
    let studentLogitude: Float
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
        studentLogitude = dictionary[ParseClient.JSONResponseKeys.StudentLogitude] as! Float
        studentObjectID = dictionary[ParseClient.JSONResponseKeys.StudentObjectID] as! String
    }
    
    static func StudentInformationFromResults(_ results: [[String:AnyObject]]) -> [StudentInformation] {
        
        var students = [StudentInformation]()
        
        // iterate through array of dictionaries, each Movie is a dictionary
        for result in results {
            students.append(StudentInformation(dictionary: result))
        }
        
        return students
    }
}

// MARK: - StudentInformation: Equatable

extension StudentInformation: Equatable {}

func ==(lhs: StudentInformation, rhs: StudentInformation) -> Bool {
    return lhs.studentUniqueKey == rhs.studentUniqueKey
}
