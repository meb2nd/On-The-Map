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

    // MARK: Properties
    
    var studentInformationHandler: StudentInformationHandler!
    var isLoading = false
    
    //var students: [StudentInformation]?
    
    // MARK: Outlets
    @IBOutlet weak var studentInformationMapView: MKMapView!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var addStudentInformationButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentInformationMapView.delegate = self
        
        refreshData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if studentInformationHandler.students == nil {
            refreshData()
        } else {
            loadData()
        }
    }


    // MARK: Actions
    
    @IBAction func logout(_ sender: Any) {
        
        UdacityClient.sharedInstance().logout { (success, errorString) in
            
            performUIUpdatesOnMain {
                
                if success {
                    self.completeLogout()
                } else {
                    AlertViewHelper.presentAlert(self, title: "Logout Failure", message: errorString)
                }
            }
        }
    }
    
    private func completeLogout() {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addStudentInformation(_ sender: Any) {
    }
    
    @IBAction func refresh(_ sender: Any) {
        
        refreshData()
    }
    
    // MARK:  - View data updates
    fileprivate func refreshData() {

        // TODO:  Disable UI
        activityIndicator.startAnimating()
        addStudentInformationButton.isEnabled = false
        refreshButton.isEnabled = false
        if  let arrayOfTabBarItems = self.tabBarController?.tabBar.items {
            
            for tabBarItem in arrayOfTabBarItems {
                tabBarItem.isEnabled = false
            }
        }
        
        studentInformationHandler.refreshStudentData() {(success, errorString) in
            if let error = errorString {
                print(error)
                return
            }
            
            performUIUpdatesOnMain {
                self.loadData()
                // TODO:  Enable UI
                self.activityIndicator.stopAnimating()
                self.addStudentInformationButton.isEnabled = true
                self.refreshButton.isEnabled = true
                if  let arrayOfTabBarItems = self.tabBarController?.tabBar.items {
                    
                    for tabBarItem in arrayOfTabBarItems {
                        tabBarItem.isEnabled = true
                    }
                }
            }
            
        }
    }
    
    // Get the data from the Student Information Handler and update the map.
    func loadData() {
        
        var annotations = [MKPointAnnotation]()
        
        let currentAnnotations = studentInformationMapView.annotations
        
        if currentAnnotations.count > 0 {
            studentInformationMapView.removeAnnotations(currentAnnotations)
        }
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension StudentMapViewController: MKMapViewDelegate {
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!,  completionHandler: nil)
                
            }
        }
    }
    //    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    //
    //        if control == annotationView.rightCalloutAccessoryView {
    //            let app = UIApplication.sharedApplication()
    //            app.openURL(NSURL(string: annotationView.annotation.subtitle))
    //        }
    //    }
}
