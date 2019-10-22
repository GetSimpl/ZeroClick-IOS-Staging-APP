//
//  CartViewController.swift
//  simpl-demo-app-with-sdk-ios
//
//  Copyright © 2019 Simpl Pay. All rights reserved.
//

import Foundation
import UIKit

class CartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CartTableViewCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var toPaymentButton: UIButton!
    
    let cart = Cart();
    var userModel: User? = nil
    var userNetworkClient: UserNetworkClient = UserNetworkClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cart.create(name: "Awesome Item 1", quantity: 0, price: 50)
        cart.create(name: "Awesome Item 2", quantity: 0, price: 100)
        
        tableView.dataSource = self
        tableView.delegate = self
        let body: [String: String] = ["number": userModel!.phoneNumber]
//        userNetworkClient.checkUserHasToken(dictionary: body, completion: { (completed, jsonResponse, error) in
//            if let error = error {
//                NSLog("Error: \(error)")
//            } else {
//                self.userModel?.hasZeroClickToken = jsonResponse["hasToken"] as? Bool ?? false
//            }
//
//        })
    }
    
    func updateView(){
        let _total = cart.getTotal()
        if (_total > 0){
            total.text = "Total: \(_total)"
        }else {
            total.text = "Total: 0"
        }
    }

    func tappedStepper(on cell: CartInemTableViewCell) {
        cart.update(name: cell.cartItemName.text ?? "", quantity: Int(cell.cartItemStepper!.value))
        updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart.cart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TestCell", for: indexPath) as? CartInemTableViewCell else { fatalError("cell must have a reuse identifier") }
        
        cell.delegate = self
        cell.cartItem = cart.cart[indexPath.row]
        cell.cartItemName.text = cell.cartItem?.name
        
        return cell
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if (cart.getTotal() == 0){
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toPayment"){
            guard let paymentViewController = segue.destination as? PaymentViewController else { return }
            paymentViewController.total = cart.getTotal()
            paymentViewController.userModel = userModel
        }
    }
}
