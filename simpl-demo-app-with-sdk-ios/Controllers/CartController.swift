//
//  CartController.swift
//  simpl-demo-app-with-sdk-ios
//
//  Created by Eleven on 17/05/19.
//  Copyright © 2019 Simpl Pay. All rights reserved.
//

import Foundation

class CartController {
    var cart = [Item]()
    
    func create(name: String, quantity: Int, price: Int) {
        cart.append(Item(name: name, quantity: quantity, price: price))
    }
    
    func update(name: String, quantity: Int) {
        cart = cart.map {
            if ($0.name == name) {
                return Item(name: $0.name, quantity: quantity, price: $0.price)
            }
            return $0
        }
    }
    
    func delete(name: String) {
        cart = cart.filter{
            if ($0.name == name){
                return false
            }
            return true
        }
    }
    
    func getTotal() -> Int {
        return cart.reduce(0, sumQuantity)
    }
    
    func sumQuantity(acc: Int, element: Item) -> Int {
        return acc + (element.price * element.quantity)
    }
}
