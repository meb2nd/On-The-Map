//
//  VIewControllerExtensions.swift
//  On The Map
//
//  Created by Pete Barnes on 9/26/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension StudentInformationClient  where Self: UIViewController {
    
    func segueToStudentInformationNavigationController() {
        
        if studentInformationHandler.student != nil {
            let controller = UIAlertController()
            controller.title = "Student Post Already Exists!"
            controller.message = "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?"
            
            let overwriteAction = UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.default) { action in
                self.completeSegueToStudentInformationNavigationController ()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { action in controller.dismiss(animated: true, completion: nil)
            }
            
            controller.addAction(overwriteAction)
            controller.addAction(cancelAction)
            present(controller, animated: true, completion: nil)
        } else {
            completeSegueToStudentInformationNavigationController ()
        }
    }
    
    private func completeSegueToStudentInformationNavigationController () {
        let controller = storyboard!.instantiateViewController(withIdentifier: "StudentInformationNavigationController")
        injectViewController(controller, withStudentInformationHandler: studentInformationHandler)
        present(controller, animated: true, completion: nil)
    }
    
    func completeLogout() {
        UdacityClient.sharedInstance().logout { (success, errorString) in
            
            performUIUpdatesOnMain {
                
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    AlertViewHelper.presentAlert(self, title: "Logout Failure", message: errorString)
                }
            }
        }
        
    }
        
}

extension UIViewController {
    
    func enableTabBar(_ isEnabled: Bool) {
    
        if  let arrayOfTabBarItems = self.tabBarController?.tabBar.items {
            
            for tabBarItem in arrayOfTabBarItems {
                tabBarItem.isEnabled = isEnabled
            }
        }
    }
}

// MARK: - MKMapViewDelegate

extension UIViewController: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
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
    
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if view.annotation?.subtitle != nil {
                let toOpen = view.annotation?.title!
                app.open(URL(string: toOpen!)!,  completionHandler: nil)
            } else {
                AlertViewHelper.presentAlert(self, title: "URL Missing", message: "No URL associated with this location.")
            }
        }
    }
    
}
