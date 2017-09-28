//
//  StudentInformationView.swift
//  On The Map
//
//  Created by Pete Barnes on 9/27/17.
//  Copyright © 2017 Pete Barnes. All rights reserved.
//

import Foundation

// MARK: - StudentInformationView

protocol StudentInformationView  {
    func refreshData()
    func loadData()
}

extension StudentInformationView where Self: StudentInformationClient {

    func refreshStudentInformationView() {
        if self.studentInformationHandler.students == nil {
            refreshData()
        } else {
            loadData()
        }
    }
}
