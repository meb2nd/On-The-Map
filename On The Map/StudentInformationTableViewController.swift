//
//  StudentInformationTableViewController.swift
//  On The Map
//
//  Created by Pete Barnes on 9/11/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//
//  Technique for showing the activity indicator adapted from information found at: https://dzone.com/articles/displaying-an-activity-indicator-while-loading-tab
//

import UIKit

// MARK: - StudentInformationTableViewController

class StudentInformationTableViewController: UITableViewController, StudentInformationClient {

    // MARK: Properties
    
    var studentInformationHandler: StudentInformationHandler!
    var students: [StudentInformation]?
    weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Outlets
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var addStudentInformationButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicatorView.hidesWhenStopped = true
        tableView.backgroundView = activityIndicatorView
        self.activityIndicator = activityIndicatorView

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshStudentInformationView()
    }


    // MARK: Actions
    
    @IBAction func logout(_ sender: Any) {
        
        completeLogout()
    }
    
    @IBAction func addStudentInformation(_ sender: Any) {
        
        segueToStudentInformationNavigationController()
    }
    
    @IBAction func refresh(_ sender: Any) {
        
        refreshData()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {

        return (students == nil) ? 0 : 1

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return students?.count ?? 0
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentInformationTableViewCell", for: indexPath)
        let studentInformation = students![(indexPath as NSIndexPath).row]

        cell.textLabel?.text = studentInformation.studentFirstName + " " + studentInformation.studentLastName
        cell.detailTextLabel?.text = studentInformation.studentMediaURL
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /* Show the media URL of the selected student */
        let studentInformation = students![(indexPath as NSIndexPath).row]
        
        let app = UIApplication.shared
        let url = studentInformation.studentMediaURL.lowercased()
        if !url.isEmpty, url.starts(with: "http://") || url.starts(with: "https://") {
            app.open(URL(string: url)!,  completionHandler: nil)
        } else {
            AlertViewHelper.presentAlert(self, title: "Cannot Display Student Link", message: "Student has entered an invalid URL")
        }
        
    }

}

// MARK:  - StudentInformationTableViewController: StudentInformationView

extension StudentInformationTableViewController: StudentInformationView {
    
    internal func refreshData() {
        
        students = nil
        tableView.reloadData()

        activityIndicator.startAnimating()
        addStudentInformationButton.isEnabled = false
        refreshButton.isEnabled = false
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        enableTabBar(false)
        
        studentInformationHandler.refreshStudentData() {(success, errorString) in
            if let error = errorString {
                print(error)
                return
            }
            
            performUIUpdatesOnMain {
                
                self.activityIndicator.stopAnimating()
                self.addStudentInformationButton.isEnabled = true
                self.refreshButton.isEnabled = true
                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                self.enableTabBar(true)
                
                self.loadData()
                
            }
            
        }
    }
    
    // Get the data from the Student Information Handler and update the table.
    internal func loadData() {
        students = studentInformationHandler.students
        tableView.reloadData()
    }
}
