//
//  ParseConstants.swift
//  On The Map
//
//  Created by Pete Barnes on 9/11/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

// MARK: - ParseClient (Constants)

extension ParseClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let RESTApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: Application ID
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes"

    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Student Location
        static let StudentLocation = "/StudentLocation"
        static let StudentLocationObjectID = "/account/{objectId}"
        
    }
    
    // MARK: URL Keys
    struct URLKeys {
        static let StudentObjectID = "objectId"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let RESTApiKey = "X-Parse-REST-API-Key"
        static let ApplicationID = "X-Parse-Application-Id"
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
        static let Where = "where"
        static let StudentUniqueKey = "uniqueKey"
        static let StudentFirstName = "firstName"
        static let StudentLastName = "lastName"
        static let StudentMapString = "mapString"
        static let StudentMediaURL = "mediaURL"
        static let StudentLatitude = "latitude"
        static let StudentLongitude = "longitude"
    }
    
    // MARK: Parameter Values
    struct ParameterValues {
        static let DescendingUpdatedAt = "-updatedAt"

    }
    
    // MARK: Header Keys
    struct HeaderKeys {
        static let Accept = "Accept"
        static let ContentType = "Content-Type"
    }
    
    // MARK: Header Values
    struct HeaderValues {
        static let applicationJSON = "application/json"
        
    }
    
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: Students
        static let StudentCreatedAt = "createdAt"
        static let StudentFirstName = "firstName"
        static let StudentLastName = "lastName"
        static let StudentLatitude = "latitude"
        static let StudentLongitude = "longitude"
        static let StudentMapString = "mapString"
        static let StudentMediaURL = "mediaURL"
        static let StudentObjectID = "objectId"
        static let StudentUniqueKey = "uniqueKey"
        static let StudentUpdatedAt = "updatedAt"
        static let StudentResults = "results"
        
    }

}
