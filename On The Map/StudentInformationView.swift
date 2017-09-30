//
//  StudentInformationView.swift
//  On The Map
//
//  Created by Pete Barnes on 9/27/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import Foundation
import UIKit

protocol StudentInformationView: class  {
    var studentInformationHandler: StudentInformationHandler! { get set }
    var activeField: UITextInput? { get set }
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
    
    // MARK: Default function implementations
    
    func loadData(){}
    func clearView(){}
    func studentInformationtionView(isEnabled: Bool){}
    var activeField: UITextInput? {
        get { return nil }
        set { }
    }
    
    // MARK: - Logout
    func completeLogout(andClear studentInformationHandler: StudentInformationHandler) {
        
        self.studentInformationtionView(isEnabled: false)
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
    
    // MARK: - Refresh Data
    func refreshData() {
        
        self.clearView()
        
        self.studentInformationtionView(isEnabled: false)
        
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
    
    // MARK: - Keyboard Offset Functions
    func getKeyboardOffset(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        // If textfield is active make sure it does not move out of view
        if let activeField = activeField as? UITextField {
            let textFieldOrigin = activeField.convert(activeField.frame.origin, to: self.view)
            return calculateOffset(fromTextInputOrigin: textFieldOrigin, fieldFrame: activeField.frame, keyBoardSize: keyboardSize)
            
        } else if let activeField = activeField as? UITextView {
            let textFieldOrigin = activeField.convert(activeField.frame.origin, to: self.view)
            return calculateOffset(fromTextInputOrigin: textFieldOrigin, fieldFrame: activeField.frame, keyBoardSize: keyboardSize)
            
        } else {
            return keyboardSize.cgRectValue.height
        }
    }
    
    private func calculateOffset (fromTextInputOrigin textInputOrigin: CGPoint, fieldFrame: CGRect, keyBoardSize: NSValue)  -> CGFloat {
        let offset = textInputOrigin.y - fieldFrame.height
        return keyBoardSize.cgRectValue.height > offset ? offset: keyBoardSize.cgRectValue.height
    }
}
