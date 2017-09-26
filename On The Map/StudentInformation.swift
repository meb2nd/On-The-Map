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
    init?(dictionary: [String:Any]) {
        guard let studentUniqueKey = dictionary[ParseClient.JSONResponseKeys.StudentUniqueKey] as? String, !studentUniqueKey.isEmpty else {
            print("Cannot create StudentInformation from dictionary: Missing Student Unique Key")
            return nil
        }
        guard let studentFirstName = dictionary[ParseClient.JSONResponseKeys.StudentFirstName] as? String, !studentFirstName.isEmpty else {
            print("Cannot create StudentInformation from dictionary: Missing Student First Name")
            return nil
        }
        guard let studentLastName = dictionary[ParseClient.JSONResponseKeys.StudentLastName] as? String, !studentLastName.isEmpty else {
            print("Cannot create StudentInformation from dictionary: Missing Student Last Name")
            return nil
        }
        guard let studentMapString = dictionary[ParseClient.JSONResponseKeys.StudentMapString] as? String, !studentMapString.isEmpty else {
            print("Cannot create StudentInformation from dictionary: Missing Student Map String")
            return nil
        }
        guard let studentMediaURL = dictionary[ParseClient.JSONResponseKeys.StudentMediaURL] as? String, !studentMediaURL.isEmpty else {
            print("Cannot create StudentInformation from dictionary: Missing Student Media URL")
            return nil
        }
        guard let studentLatitude = dictionary[ParseClient.JSONResponseKeys.StudentLatitude] as? Float else {
            print("Cannot create StudentInformation from dictionary: Missing Student Latitude")
            return nil
        }
        guard let studentLongitude = dictionary[ParseClient.JSONResponseKeys.StudentLongitude] as? Float else {
            print("Cannot create StudentInformation from dictionary: Missing Student Longitude")
            return nil
        }
        
        self.studentUniqueKey = studentUniqueKey
        self.studentFirstName = studentFirstName
        self.studentLastName = studentLastName
        self.studentMapString = studentMapString
        self.studentMediaURL = studentMediaURL
        self.studentLatitude = studentLatitude
        self.studentLongitude = studentLongitude
        // Will not have an object ID when creating a new student
        self.studentObjectID = dictionary[ParseClient.JSONResponseKeys.StudentObjectID] as? String ?? ""
    }
    
    static func StudentInformationFromResults(_ results: [[String:Any]]) -> [StudentInformation] {
        
        var students = [StudentInformation]()
        
        // iterate through array of dictionaries, each Student is a dictionary
        for result in results {
            
            if let student = StudentInformation(dictionary: result) {
                students.append(student)
            }
            
        }
        
        return students
    }
    
}

// MARK: - StudentInformation: Equatable

extension StudentInformation: Equatable {}

func == (lhs: StudentInformation, rhs: StudentInformation) -> Bool {
    return lhs.studentUniqueKey == rhs.studentUniqueKey
}
