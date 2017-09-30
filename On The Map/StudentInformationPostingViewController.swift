//
//  StudentInformationPostingViewController.swift
//  On The Map
//
//  Created by Pete Barnes on 9/11/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import UIKit
import MapKit

class StudentInformationPostingViewController: UIViewController, StudentInformationClient, StudentInformationView {
    
    // MARK: - Properties
    
    var activeField: UITextInput?
    let defaultLocationPrompt = "Enter Your Location Here."
    let linkToShareErrorTitle = "Link to Share Error"
    let findOnMapErrorTitle = "Location Not Found"
    var studentlatitude: Float = 0.0
    var studentLongitude: Float = 0.0
    var studentInformationHandler: StudentInformationHandler!
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var linkStackView: UIStackView!
    @IBOutlet weak var studentLocationMapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Code for removing the navigation bar was found at: https://stackoverflow.com/questions/26390072/remove-border-in-navigationbar-in-swift
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        locationTextView.text = defaultLocationPrompt
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        findOnTheMapView(isHidden: false)
        submitButton.backgroundColor = UIColor.white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: - UI
    
    func findOnTheMapView(isHidden: Bool) {
        
        locationStackView.isHidden = isHidden
        linkStackView.isHidden = !isHidden
        submitButton.isHidden = !isHidden
    }
    
    func findOnTheMapView(isEnabled: Bool) {
        findOnTheMapButton.isEnabled = isEnabled
        locationTextView.isEditable = isEnabled
        isEnabled ? activityIndicator.stopAnimating(): activityIndicator.startAnimating()
    }
    
    func locationLinkView(isEnabled: Bool) {
        submitButton.isEnabled = isEnabled
        linkTextField.isEnabled = isEnabled
        isEnabled ? activityIndicator.stopAnimating(): activityIndicator.startAnimating()
    }
    
    
    // MARK:  - Actions
    
    // Code for this method based on information found at: https://stackoverflow.com/questions/41639478/mkmapview-center-and-zoom-in
    // https://stackoverflow.com/questions/10644854/ios-zoom-in-mapkit-for-two-annotation-point
    // https://littlebitesofcocoa.com/47-mklocalsearch
    
    @IBAction func findOnTheMap(_ sender: Any) {
        
        let searchText = locationTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !searchText.isEmpty, defaultLocationPrompt != searchText  else {
            AlertViewHelper.presentAlert(self, title: "Find On Map Error", message: "You must enter a location to search.")
            return
        }
        
        findOnTheMapView(isEnabled: false)
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = locationTextView.text
        request.region = studentLocationMapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard error == nil else {
                
                performUIUpdatesOnMain() {
                    AlertViewHelper.presentAlert(self, title: self.findOnMapErrorTitle, message: "Could not geocode the string.")
                    self.findOnTheMapView(isEnabled: true)
                }
                return
                
            }
            
            guard let response = response else {
                
                performUIUpdatesOnMain {
                    AlertViewHelper.presentAlert(self, title: self.findOnMapErrorTitle, message: "Unexpected Error - Invalid response from the server.")
                    self.findOnTheMapView(isEnabled: true)
                }
                return
            }
            guard response.mapItems.count > 0 else {
                
                performUIUpdatesOnMain {
                    AlertViewHelper.presentAlert(self, title: self.findOnMapErrorTitle, message: "Unexpected Error - No map items returned from the server.")
                    self.findOnTheMapView(isEnabled: true)
                }
                
                return
                
            }
            
            for item in response.mapItems {
                // Display the received items
                self.studentlatitude = Float(item.placemark.coordinate.latitude)
                self.studentLongitude = Float(item.placemark.coordinate.longitude)
                
                let region = MKCoordinateRegion(center: item.placemark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.studentLocationMapView.setRegion(region, animated: true)
                self.studentLocationMapView.addAnnotation(item.placemark)
            }
            
            performUIUpdatesOnMain {
                self.findOnTheMapView(isEnabled: true)
                self.findOnTheMapView(isHidden: true)
            }
            
        }
    }
    
    @IBAction func submitStudentInformation(_ sender: Any) {
        
        
        guard let urlString = linkTextField.text?.lowercased().trimmingCharacters(in: .whitespaces), !urlString.isEmpty else {
            AlertViewHelper.presentAlert(self, title: linkToShareErrorTitle, message: "URL field cannot be empty")
            return
        }
        
        guard (urlString.starts(with: "http://")) || (urlString.starts(with: "https://")) else {
            AlertViewHelper.presentAlert(self, title: linkToShareErrorTitle, message: "Invalid URL. Include http(s)://")
            return
        }
        
        let studentInfo: [String: Any] = [ParseClient.ParameterKeys.StudentUniqueKey: UdacityClient.sharedInstance().userID ?? "",
                                          ParseClient.ParameterKeys.StudentFirstName: UdacityClient.sharedInstance().firstName  ?? "",
                                          ParseClient.ParameterKeys.StudentLastName: UdacityClient.sharedInstance().lastName  ?? "",
                                          ParseClient.ParameterKeys.StudentMapString: self.locationTextView.text.trimmingCharacters(in: .whitespacesAndNewlines),
                                          ParseClient.ParameterKeys.StudentLongitude: studentLongitude,
                                          ParseClient.ParameterKeys.StudentLatitude: studentlatitude,
                                          ParseClient.ParameterKeys.StudentMediaURL: linkTextField.text?.trimmingCharacters(in: .whitespaces) ?? "",
                                          ParseClient.ParameterKeys.StudentObjectID: studentInformationHandler.student?.studentObjectID ?? ""
        ]
        
        guard let studentInformation = StudentInformation(studentInfo) else {
            AlertViewHelper.presentAlert(self, title: "Error Processing Request", message: "Incomplete student information")
            return
        }
        
        locationLinkView(isEnabled: false)
        
        if studentInformationHandler.student == nil {
            
            ParseClient.sharedInstance().postStudentLocation(studentInformation){(result, error) in
                
                self.processResults(success: result, error)
            }
            
        } else {
            
            ParseClient.sharedInstance().putStudentLocation(studentInformation){(result, error) in
                
                self.processResults(success: result, error)
                
            }
        }
        
    }
    
    private func processResults(success: Bool, _ error: String?) {
        
        guard error == nil else {
            performUIUpdatesOnMain {
                AlertViewHelper.presentAlert(self, title: "Error Processing Post Request", message: "Could not update server.")
                self.locationLinkView(isEnabled: true)
            }
            return
        }
        
        // Need to refresh student list
        self.studentInformationHandler.refreshStudentData(){(success, error) in
            guard error == nil else {
                performUIUpdatesOnMain {
                    AlertViewHelper.presentAlert(self, title: "Error Processing Post Request", message: "Could not refresh student data points.")
                    self.locationLinkView(isEnabled: true)
                }
                
                return
            }
            
            performUIUpdatesOnMain() {
                self.locationLinkView(isEnabled: true)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate

extension StudentInformationPostingViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func resignIfFirstResponder(_ textInput: UITextInput) {
        if let textField = textInput as? UITextField, textField.isFirstResponder {
            textField.resignFirstResponder()
        } else if let textView = textInput as? UITextView, textView.isFirstResponder {
            textView.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(linkTextField)
        resignIfFirstResponder(locationTextView)
    }
}

// MARK: - UITextViewDelegate

extension StudentInformationPostingViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        let currentText = textView.text
        
        if currentText?.trimmingCharacters(in: .whitespacesAndNewlines) == defaultLocationPrompt {
            
            textView.text = ""
        }
        
        activeField = textView
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        let currentText = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if currentText == "" {
            
            textView.text = defaultLocationPrompt
        }
        
        activeField = nil
        return true
    }
}

// MARK: LoginViewController (Show/Hide Keyboard)

extension StudentInformationPostingViewController {
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if traitCollection.verticalSizeClass == .compact {
            view.frame.origin.y = 0 - getKeyboardOffset(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        view.frame.origin.y = 0
    }
    
}

// MARK: - StudentInformationPostingViewController (Notifications)

private extension StudentInformationPostingViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
}
