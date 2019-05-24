//
//  CartViewController.swift
//  simpl-demo-app-with-sdk-ios
//
//  Created by Eleven on 17/05/19.
//  Copyright © 2019 Simpl Pay. All rights reserved.
//

import Foundation
import UIKit

class CartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CartTableViewCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var toPaymentButton: UIButton!
    
    let cartController = CartController();
    var userModel: User? = nil
    var userNetworkClient: UserNetworkClient = UserNetworkClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cartController.create(name: "Awesome Item 1", quantity: 0, price: 50)
        cartController.create(name: "Awesome Item 2", quantity: 0, price: 100)
        
        tableView.dataSource = self
        tableView.delegate = self
        let body: [String: String] = ["number": userModel?.phoneNumber ?? ""]
        userNetworkClient.checkUserHasToken(dictionary: body, completion: { (hasToken, error) in
            if let error = error {
                NSLog("Error: \(error)")
            } else {
                self.userModel?.hasZeroClickToken = hasToken
            }
            
        })
    }
    
    func updateView(){
        //print(cartController.cart)
        let _total = cartController.getTotal()
        if (_total > 0){
            total.text = "Total: \(_total)"
        }else {
            total.text = "Total: 0"
        }
    }

    func tappedStepper(on cell: CartInemTableViewCell) {
        cartController.update(name: cell.cartItemName.text ?? "", quantity: Int(cell.cartItemStepper?.value ?? 0))
        updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartController.cart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TestCell", for: indexPath) as? CartInemTableViewCell else { fatalError("cell must have a reuse identifier") }
        
        cell.delegate = self
        cell.cartItem = cartController.cart[indexPath.row]
        cell.cartItemName.text = cell.cartItem?.name
        
        return cell
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if (cartController.getTotal() == 0){
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toPayment"){
            guard let paymentViewController = segue.destination as? PaymentViewController else { return }
            paymentViewController.cartController = cartController
            paymentViewController.userModel = userModel
        }
    }
}
