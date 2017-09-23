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

    // MARK: Properties
    
    var studentInformationHandler: StudentInformationHandler!
    var students: [StudentInformation]?
    weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Outlets
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var addStudentInformationButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicatorView.hidesWhenStopped = true
        tableView.backgroundView = activityIndicatorView
        self.activityIndicator = activityIndicatorView

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if studentInformationHandler.students == nil {
            refreshData()
        } else {
            loadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        students = nil
        tableView.reloadData()
        
        // TODO:  Disable UI
        activityIndicator.startAnimating()
        addStudentInformationButton.isEnabled = false
        refreshButton.isEnabled = false
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
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
                
                // TODO:  Enable UI
                self.activityIndicator.stopAnimating()
                self.addStudentInformationButton.isEnabled = true
                self.refreshButton.isEnabled = true
                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                if  let arrayOfTabBarItems = self.tabBarController?.tabBar.items {
                    
                    for tabBarItem in arrayOfTabBarItems {
                        tabBarItem.isEnabled = true
                    }
                }
               
                self.loadData()
                
            }
            
        }
    }
    
    // Get the data from the Student Information Handler and update the table.
    func loadData() {
        students = studentInformationHandler.students
        tableView.reloadData()
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
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /* Show the media URL of the selected student */
        let studentInformation = students![(indexPath as NSIndexPath).row]
        
        let app = UIApplication.shared
        if studentInformation.studentMediaURL != "" {
            app.open(URL(string: studentInformation.studentMediaURL)!,  completionHandler: nil)
        } else {
            AlertViewHelper.presentAlert(self, title: "Cannot Display Student Link", message: "Student has enetered an invalid URL")
        }
        
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
