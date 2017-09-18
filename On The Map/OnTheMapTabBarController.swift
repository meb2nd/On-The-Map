//
//  OnTheMapTabBarController.swift
//  On The Map
//
//  Created by Pete Barnes on 9/17/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import UIKit

class OnTheMapTabBarController: UITabBarController {

    
    // MARK:  Outlets
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var pinButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    @IBAction func logout(_ sender: Any) {
    }
    
    
    @IBAction func postStudentInformation(_ sender: Any) {
    }

    
    @IBAction func refresh(_ sender: Any) {
    }
}
