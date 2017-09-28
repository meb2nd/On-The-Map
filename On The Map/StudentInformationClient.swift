//
//  StudentInformationClient.swift
//  On The Map
//
//  Created by Pete Barnes on 9/22/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import Foundation
import UIKit

// MARK: - StudentInformationClient
protocol StudentInformationClient {
    var studentInformationHandler: StudentInformationHandler! { get set }
}

extension StudentInformationClient {
    func injectViewController (_ viewController: UIViewController, withStudentInformationHandler studentInformationHandler: StudentInformationHandler) {
        
        // Following code is based upon information found at: http://cleanswifter.com/dependency-injection-with-storyboards/
        if let tabVC = viewController as? UITabBarController {
            for controller in tabVC.viewControllers ?? [] {
                injectViewController(controller, withStudentInformationHandler: studentInformationHandler)
            }
        } else if let navVC = viewController as? UINavigationController{
            for controller in navVC.viewControllers {
                injectViewController(controller, withStudentInformationHandler: studentInformationHandler)
            }
        } else if var firstViewController = viewController as? StudentInformationClient {
            firstViewController.studentInformationHandler = studentInformationHandler
        }
    }
}
