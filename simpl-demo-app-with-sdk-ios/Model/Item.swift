//
//  Item.swift
//  simpl-demo-app-with-sdk-ios
//
//  Created by Eleven on 17/05/19.
//  Copyright © 2019 Simpl Pay. All rights reserved.
//

import Foundation

struct Item {
    let name: String
    var quantity: Int
    let price: Int
    
    init(name: String, quantity: Int, price: Int){
        self.name = name
        self.quantity = quantity
        self.price = price
    }
}
