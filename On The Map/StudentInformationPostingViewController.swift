//
//  StudentInformationPostingViewController.swift
//  On The Map
//
//  Created by Pete Barnes on 9/11/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import UIKit
import MapKit

class StudentInformationPostingViewController: UIViewController, StudentInformationClient {

    // MARK:  Properties
    var activeField: UITextInput?
    let defaultLocationPrompt = "Enter Your Location Here."
    let linkToShareErrorTitle = "Link to Share Error"
    var studentlatitude: Float = 0.0
    var studentLongitude: Float = 0.0
    var studentInformationHandler: StudentInformationHandler!

    
    // MARK:  Outlet
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var linkStackView: UIStackView!
    @IBOutlet weak var studentLocationMapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Code for removing the navigation bar was found at: https://stackoverflow.com/questions/26390072/remove-border-in-navigationbar-in-swift
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

        locationTextView.text = defaultLocationPrompt
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        self.locationStackView.isHidden = false
        self.linkStackView.isHidden = true
        self.submitButton.isHidden = true
        self.submitButton.backgroundColor = UIColor.white
        
        locationTextView.delegate = self
        linkTextField.delegate = self
        studentLocationMapView.delegate = self
        
        if let student = studentInformationHandler.student {
            locationTextView.text = student.studentMapString
            linkTextField.text = student.studentMediaURL
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK:  Actions
    // Code for this method based on information found at: https://stackoverflow.com/questions/41639478/mkmapview-center-and-zoom-in
    // https://stackoverflow.com/questions/10644854/ios-zoom-in-mapkit-for-two-annotation-point
    // https://littlebitesofcocoa.com/47-mklocalsearch
    @IBAction func findOnTheMap(_ sender: Any) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = locationTextView.text
        request.region = studentLocationMapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard error == nil else { return } // TODO: Handle MKError
            guard let response = response else {
                print("There was an error searching for: \(String(describing: request.naturalLanguageQuery)) error: \(String(describing: error))")
                return
            }
            guard response.mapItems.count > 0 else { return }
            
            for item in response.mapItems {
                // Display the received items
                self.studentlatitude = Float(item.placemark.coordinate.latitude)
                self.studentLongitude = Float(item.placemark.coordinate.longitude)
                
                let region = MKCoordinateRegion(center: item.placemark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.studentLocationMapView.setRegion(region, animated: true)
                self.studentLocationMapView.addAnnotation(item.placemark) 
                
                self.locationStackView.isHidden = true
                self.linkStackView.isHidden = false
                self.submitButton.isHidden = false
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
        
        guard let studentInformation = StudentInformation(dictionary: studentInfo) else {
            AlertViewHelper.presentAlert(self, title: "Error Processing Request", message: "Incomplete student information")
            return
        }
        
        submitButton.isEnabled = false
        activityIndicator.startAnimating()
        
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
            AlertViewHelper.presentAlert(self, title: "Error Processing Post Request", message: "Could not update server.")
            return
        }
        
        // Need to refresh student list
        self.studentInformationHandler.refreshStudentData(){(success, error) in
            guard error == nil else {
                AlertViewHelper.presentAlert(self, title: "Error Processing Post Request", message: "Could not refresh student data points.")
                return
            }
            
            performUIUpdatesOnMain() {
                self.submitButton.isEnabled = true
                self.activityIndicator.stopAnimating()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - StudentInformationPostingViewController: UITextFieldDelegate

extension StudentInformationPostingViewController: UITextFieldDelegate {
    
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
    
    
    private func resignIfFirstResponder(_ textInput: UITextInput) {
        if let textField = textInput as? UITextField, textField.isFirstResponder {
            textField.resignFirstResponder()
        } else if let textView = textInput as? UITextView, textView.isFirstResponder {
            textView.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(linkTextField)
        resignIfFirstResponder(locationTextView)
    }
}

// MARK: - StudentInformationPostingViewController: UITextViewDelegate

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
