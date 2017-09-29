//
//  StudentInformation.swift
//  On The Map
//
//  Created by Pete Barnes on 9/11/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

struct StudentInformation {
    
    
    // MARK: - Properties
   
    let studentUniqueKey: String
    let studentFirstName: String
    let studentLastName: String
    let studentMapString: String
    let studentMediaURL: String
    let studentLatitude: Float
    let studentLongitude: Float
    let studentObjectID: String

    
    // MARK: - Initializers
    
    // construct a StudentInformation from a dictionary
    init?(_ dictionary: [String:Any]) {
        
        guard let studentLatitude = dictionary[ParseClient.JSONResponseKeys.StudentLatitude] as? Float else {
            print("Cannot create StudentInformation from dictionary: Missing Student Latitude")
            return nil
        }
        guard let studentLongitude = dictionary[ParseClient.JSONResponseKeys.StudentLongitude] as? Float else {
            print("Cannot create StudentInformation from dictionary: Missing Student Longitude")
            return nil
        }

        self.studentLatitude = studentLatitude
        self.studentLongitude = studentLongitude
        
        // Will not have an object ID when creating a new student
        self.studentObjectID = dictionary[ParseClient.JSONResponseKeys.StudentObjectID] as? String ?? ""
        
        // Removed guards for these fields due to high number entries in database that were missing them.
        // Added non empty values for display purposes
        self.studentUniqueKey = dictionary[ParseClient.JSONResponseKeys.StudentUniqueKey] as? String ?? ""
        self.studentFirstName = dictionary[ParseClient.JSONResponseKeys.StudentFirstName] as? String ?? "(N/A)"
        self.studentLastName = dictionary[ParseClient.JSONResponseKeys.StudentLastName] as? String ?? "(N/A)"
        self.studentMediaURL = dictionary[ParseClient.JSONResponseKeys.StudentMediaURL] as? String ?? "(N/A)"
        self.studentMapString = dictionary[ParseClient.JSONResponseKeys.StudentMapString] as? String ?? ""
        
    }
    
    static func StudentInformationFromResults(_ results: [[String:Any]]) -> [StudentInformation] {
        
        var students = [StudentInformation]()
        
        // iterate through array of dictionaries, each Student is a dictionary
        for result in results {
            
            if let student = StudentInformation(result) {
                students.append(student)
            }
            
        }
        
        return students
    }
    
}

// MARK: - Equatable

extension StudentInformation: Equatable {}

func == (lhs: StudentInformation, rhs: StudentInformation) -> Bool {
    return lhs.studentUniqueKey == rhs.studentUniqueKey
}
