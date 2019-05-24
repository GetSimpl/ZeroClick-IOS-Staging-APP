//
//  ViewController.swift
//  simpl-demo-app-with-sdk-ios
//
//  Created by Eleven on 17/05/19.
//  Copyright © 2019 Simpl Pay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var email: UITextField!
    var user: User? = nil
    var userNetworkClient: UserNetworkClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
       
        if (phoneNumber.text?.count == 0){
            return false
        }
        else if (email.text?.count == 0){
            return false
        }
        
        user = User(emailId: email.text ?? "", phoneNumber: phoneNumber.text ?? "", hasZeroClickToken: false)
        return true;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toCart"){
            guard let cartViewController = segue.destination as? CartViewController else { return }
            cartViewController.userModel = (user ?? nil)!
        }
    }
}

