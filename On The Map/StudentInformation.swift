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

        self.studentObjectID = dictionary[ParseClient.JSONResponseKeys.StudentObjectID] as? String ?? ""
        self.studentUniqueKey = dictionary[ParseClient.JSONResponseKeys.StudentUniqueKey] as? String ?? ""
        self.studentFirstName = dictionary[ParseClient.JSONResponseKeys.StudentFirstName] as? String ?? "[No First Name]"
        self.studentLastName = dictionary[ParseClient.JSONResponseKeys.StudentLastName] as? String ?? "[No Last Name]"
        self.studentMediaURL = dictionary[ParseClient.JSONResponseKeys.StudentMediaURL] as? String ?? "[No Media URL]"
        self.studentMapString = dictionary[ParseClient.JSONResponseKeys.StudentMapString] as? String ?? ""
        self.studentLongitude = dictionary[ParseClient.JSONResponseKeys.StudentLongitude] as? Float ?? 0.0
        self.studentLatitude = dictionary[ParseClient.JSONResponseKeys.StudentLatitude] as? Float  ?? 0.0
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
