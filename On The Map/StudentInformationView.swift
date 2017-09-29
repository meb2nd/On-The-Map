//
//  StudentInformationView.swift
//  On The Map
//
//  Created by Pete Barnes on 9/27/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import Foundation
import UIKit

protocol StudentInformationView  {
    var studentInformationHandler: StudentInformationHandler! { get set }
    func refreshData()
    func loadData()
    func clearView()
    func studentInformationtionView(isEnabled: Bool)
}

// MARK: - StudentInformationView
extension StudentInformationView where Self: StudentInformationClient {

    func refreshStudentInformationView() {
        if self.studentInformationHandler.students == nil {
            refreshData()
        } else {
            loadData()
        }
    }
    
    fileprivate func clearData() {
        self.studentInformationHandler.student = nil
        self.studentInformationHandler.students = nil
    }
}

extension StudentInformationView where Self: UIViewController {
    
    func completeLogout(andClear studentInformationHandler: StudentInformationHandler) {
        
        studentInformationtionView(isEnabled: false)
        UdacityClient.sharedInstance().logout { (success, errorString) in
            
            studentInformationHandler.student = nil
            studentInformationHandler.students = nil
            
            performUIUpdatesOnMain {
                
                self.studentInformationtionView(isEnabled: true)
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    let controller = UIAlertController()
                    controller.title = "Logout Complete"
                    controller.message = "There was a problem connecting to the server.  For security purposes you will be automatically logged out later."
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { action in self.dismiss(animated: true, completion: nil)
                    }
                    
                    controller.addAction(okAction)
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
    func refreshData() {
        
        clearView()
        
        studentInformationtionView(isEnabled: false)
        
        studentInformationHandler.refreshStudentData() {(success, errorString) in
            performUIUpdatesOnMain {
                if let error = errorString {
                    print(error)
                    AlertViewHelper.presentAlert(self, title: "Data Update Error", message: error)
                    self.studentInformationtionView(isEnabled: true)
                }
                self.studentInformationtionView(isEnabled: true)
                self.loadData()
            }
        }
    }
}
