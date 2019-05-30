//
//  URL.swift
//  simpl-demo-app-with-sdk-ios
//
//  Created by Eleven on 21/05/19.
//  Copyright © 2019 Simpl Pay. All rights reserved.
//

import Foundation

struct Urls {
    static let BASE_URL = "https://sandbox-zero-click-sample.getsimpl.com"
    
    static let PLACE_SIMPL_ORDER = Urls.BASE_URL + "/place_simpl_order"
    static let ELIGIBILITY_CHECK = Urls.BASE_URL + "/check_eligibility"
    static let HAS_TOKEN = Urls.BASE_URL + "/has_token"
}
