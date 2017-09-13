//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Pete Barnes on 9/11/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

// MARK: - UdacityClient (Constants)

extension UdacityClient {
    
    // MARK: Constants
    struct Constants {
        
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Session
        static let StudentLocation = "/session"
        
    }
    

    // MARK: Parameter Keys
    struct ParameterKeys {
        static let Udacity = "udacity"
        static let UserName = "username"
        static let Password = "password"
    }
    
    // MARK: Header Keys
    struct HeaderKeys {
        static let Accept = "Accept"
        static let ContentType = "Content-Type"
        static let XSRFToken = "X-XSRF-TOKEN"
    }
    
    // MARK: Header Values
    struct HeaderValues {
        static let applicationJSON = "application/json"
        
    }
    
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: Account
        static let Account = "account"
        static let Registered = "registered"
        static let Key = "key"
        
        // MARK: Session
        static let Session = "session"
        static let ID = "id"
        static let Expiration = "expiration"
        
    }
    
}

