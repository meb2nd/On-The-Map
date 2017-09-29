//
//  StudentMapViewController.swift
//  On The Map
//
//  Created by Pete Barnes on 9/11/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import UIKit
import MapKit

class StudentMapViewController: UIViewController, StudentInformationClient {
    
    // MARK: - Properties
    
    var studentInformationHandler: StudentInformationHandler!
    
    // MARK: - Outlets
    
    @IBOutlet weak var studentInformationMapView: MKMapView!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var addStudentInformationButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentInformationMapView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshStudentInformationView()
    }
    
    
    // MARK: - Actions
    
    @IBAction func logout(_ sender: Any) {
        completeLogout(andClear: studentInformationHandler)
    }
    
    @IBAction func addStudentInformation(_ sender: Any) {
        segueToStudentInformationNavigationController()
    }
    
    @IBAction func refresh(_ sender: Any) {
        refreshData()
    }
}


// MARK:  - StudentInformationView

extension StudentMapViewController: StudentInformationView {
    
    // Get the data from the Student Information Handler and update the map.
    func loadData() {
        
        var annotations = [MKPointAnnotation]()
        
        clearView()
        
        if let students = studentInformationHandler.students {
            for student in students {
                
                // Notice that the float values are being used to create CLLocationDegree values.
                // This is a version of the Double type.
                let lat = CLLocationDegrees(student.studentLatitude)
                let long = CLLocationDegrees(student.studentLongitude)
                
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let first = student.studentFirstName
                let last = student.studentLastName
                let mediaURL = student.studentMediaURL
                
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
                
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
            }
        }
        
        studentInformationMapView.addAnnotations(annotations)
    }
    
    func clearView() {
        let currentAnnotations = studentInformationMapView.annotations
        if currentAnnotations.count > 0 {
            studentInformationMapView.removeAnnotations(currentAnnotations)
        }
    }
    
    func studentInformationtionView(isEnabled: Bool) {
        
        isEnabled ? activityIndicator.stopAnimating(): activityIndicator.startAnimating()
        addStudentInformationButton.isEnabled = isEnabled
        refreshButton.isEnabled = isEnabled
        enableTabBar(isEnabled)
    }
}
