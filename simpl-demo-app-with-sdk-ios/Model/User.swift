//
//  User.swift
//  simpl-demo-app-with-sdk-ios
//
//  Created by Eleven on 17/05/19.
//  Copyright © 2019 Simpl Pay. All rights reserved.
//

import Foundation

struct User {
    let emailId: String
    let phoneNumber: String
    var hasZeroClickToken: Bool
    
    init(emailId: String, phoneNumber: String, hasZeroClickToken: Bool) {
        self.emailId = emailId
        self.phoneNumber = phoneNumber
        self.hasZeroClickToken = hasZeroClickToken
    }
}
