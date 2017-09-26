//
//  LoginViewController.swift
//  On The Map
//
//  Created by Pete Barnes on 9/11/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import UIKit
import SafariServices

class LoginViewController: UIViewController, StudentInformationClient {
    
    // MARK: Properties
    
    var appDelegate: AppDelegate!
    var backgroundGradient: CAGradientLayer!
    var activeField: UITextField?
    var studentInformationHandler: StudentInformationHandler!
    

    // MARK:  Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        configureUI()
        
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: UITraitEnvironment
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        super.traitCollectionDidChange(previousTraitCollection)
        
        if ((self.traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass)
            || (self.traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass)) {
            
            // Update the background gradient for the new orientation
            backgroundGradient.frame = view.frame
            
        }
    }
    
    // MARK: Login
    @IBAction func login(_ sender: Any) {
        
        guard !emailTextField.text!.isEmpty && !passwordTextField.text!.isEmpty else {
            AlertViewHelper.presentAlert(self, title: "Login Error", message: "Email or Password field is empty")
            return
        }
        
        self.setUIEnabled(false)
        
        UdacityClient.sharedInstance().authenticateUser(username: emailTextField.text!.trimmingCharacters(in: .whitespaces), password: passwordTextField.text!.trimmingCharacters(in: .whitespaces)) { (success, errorString) in
            
            performUIUpdatesOnMain {
                self.setUIEnabled(true)
                if success {
                    self.completeLogin()
                } else {
                    AlertViewHelper.presentAlert(self, title: "Authentication Failure", message: errorString)
                }
            }
        }
    }
    
    
    
    private func completeLogin() {

        let controller = storyboard!.instantiateViewController(withIdentifier: "OnTheMapTabBarController")
        injectViewController(controller, withStudentInformationHandler: studentInformationHandler)
        present(controller, animated: true, completion: nil)
    }
    

    // MARK: Signup
    @IBAction func signUp(_ sender: Any) {
        
        let app = UIApplication.shared
        app.open(URL(string: "https://www.udacity.com/account/auth#!/signup")!,  completionHandler: nil)

    }

}
// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(emailTextField)
        resignIfFirstResponder(passwordTextField)
    }
}

// MARK: - LoginViewController (Configure UI)

private extension LoginViewController {
    
    // MARK: UI
    struct UI {
        static let LoginColorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).cgColor
        static let LoginColorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).cgColor
        static let GreyColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
        static let BlueColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
    }
    
    func setUIEnabled(_ enabled: Bool) {
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    func configureUI() {
        
        // configure background gradient
        backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [UI.LoginColorTop, UI.LoginColorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        //backgroundGradient.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 0)
        backgroundGradient.startPoint = CGPoint(x: 0.5, y: 0.0) // default (0.5,0.0).
        backgroundGradient.endPoint = CGPoint(x: 0.5, y: 1.0) //default (0.5, 1.0)
        view.layer.insertSublayer(backgroundGradient, at: 0)
        
        configureTextField(emailTextField)
        configureTextField(passwordTextField)
    }
    
    func configureTextField(_ textField: UITextField) {
        let textFieldPaddingViewFrame = CGRect(x: 0.0, y: 0.0, width: 13.0, height: 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .always
        textField.backgroundColor = UI.GreyColor
        textField.textColor = UI.BlueColor
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.white])
        textField.tintColor = UI.BlueColor
        textField.delegate = self
    }
}

// MARK: Show/Hide Keyboard

extension LoginViewController {
    
    func keyboardWillShow(_ notification: Notification) {
        
        view.frame.origin.y = 0 - getKeyboardHeight(notification)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        view.frame.origin.y = 0
    }
    
    private func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        // If textfield is active make sure it does not move out of view
        if let activeField = activeField {
            let textFieldOrigin = activeField.convert(activeField.frame.origin, to: self.view)
            let offset = textFieldOrigin.y + 8.0
            return keyboardSize.cgRectValue.height > offset ? offset : keyboardSize.cgRectValue.height
        } else {
            return keyboardSize.cgRectValue.height
        }
    }
    
}

// MARK: - LoginViewController (Notifications)

private extension LoginViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }


}



