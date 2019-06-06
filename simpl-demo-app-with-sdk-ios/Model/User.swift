//
//  User.swift
//  simpl-demo-app-with-sdk-ios
//
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
