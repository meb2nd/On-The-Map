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

class StudentInformationTableViewController: UITableViewController, StudentInformationClient {
    
    // MARK: - Properties
    
    var studentInformationHandler: StudentInformationHandler!

    weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Outlets
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var addStudentInformationButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicatorView.hidesWhenStopped = true
        tableView.backgroundView = activityIndicatorView
        activityIndicator = activityIndicatorView
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshStudentInformationView()
    }
    
    
    // MARK: - Actions
    
    @IBAction func logout(_ sender: Any) {
        clearView()
        completeLogout(andClear: studentInformationHandler)
    }
    
    @IBAction func addStudentInformation(_ sender: Any) {
        
        segueToStudentInformationNavigationController()
    }
    
    @IBAction func refresh(_ sender: Any) {
        
        refreshData()
    }
    
    // MARK: UI
    
    func clearView() {
        studentInformationHandler.students = nil
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return (studentInformationHandler.students == nil) ? 0 : 1
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return studentInformationHandler.students?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentInformationTableViewCell", for: indexPath)
        let studentInformation = studentInformationHandler.students![(indexPath as NSIndexPath).row]
        
        cell.textLabel?.text = studentInformation.studentFirstName + " " + studentInformation.studentLastName
        cell.detailTextLabel?.text = studentInformation.studentMediaURL
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /* Show the media URL of the selected student */
        let studentInformation = studentInformationHandler.students![(indexPath as NSIndexPath).row]
        
        let app = UIApplication.shared
        let url = studentInformation.studentMediaURL.lowercased()
        if !url.isEmpty, url.starts(with: "http://") || url.starts(with: "https://") {
            app.open(URL(string: url)!,  completionHandler: nil)
        } else {
            AlertViewHelper.presentAlert(self, title: "Cannot Display Student Link", message: "Student has entered an invalid URL")
        }
    }
}

// MARK:  - StudentInformationView

extension StudentInformationTableViewController: StudentInformationView {
    
    // Get the data from the Student Information Handler and update the table.
    func loadData() {
        tableView.reloadData()
    }
    
    func studentInformationtionView(isEnabled: Bool) {
        isEnabled ? activityIndicator.stopAnimating(): activityIndicator.startAnimating()
        addStudentInformationButton.isEnabled = isEnabled
        refreshButton.isEnabled = isEnabled
        tableView.separatorStyle = isEnabled ? UITableViewCellSeparatorStyle.singleLine: UITableViewCellSeparatorStyle.none
        enableTabBar(isEnabled)
    }
}
