//
//  PaymentViewController.swift
//  simpl-demo-app-with-sdk-ios
//
//  Created by Eleven on 20/05/19.
//  Copyright © 2019 Simpl Pay. All rights reserved.
//

import UIKit
import SimplZeroClick

class PaymentViewController: UIViewController {

    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var simplBtn: UIButton!
    
    var cartController: CartController? = nil
    var userModel: User? = nil
    var zeroClickToken: String = ""
    var transactionStatus: TransactionStatus = TransactionStatus.incomplete
    var userNetworkClient: UserNetworkClient = UserNetworkClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let total = cartController?.getTotal()
        self.setTotal(total ?? 0)
        if (self.userModel?.hasZeroClickToken ?? false){
            print("this user has a zero click token")
        }
        
        // initialize simpl
        initSimpl()
    }
    
    private func initSimpl() {
        if (initZeroClickSDK()){
            if self.userModel?.hasZeroClickToken ?? false {
                self.callEligility()
            } else {
                self.callAproval()
            }
        }
    }
    
    private func initZeroClickSDK() -> Bool {
        GSManager.initialize(withMerchantID: "e4a905492fc1ec16d8f2d25bfd9885c7")
        GSManager.enableSandBoxEnvironment(true)
        
        return true;
    }
    
    private func setTotal(_ total: Int){
        totalAmount.text = "Total: \(total)"
    }
    
    private func setStatus(_ s: String){
        status.text = s
    }
    
    private func callAproval() {
        var params: [String: Any] = [:]
        params["transaction_amount_in_paise"] = "\(String(describing: totalAmount.text))00"
        let user = GSUser(phoneNumber: self.userModel?.phoneNumber ?? "", email: self.userModel?.emailId ?? "")
        user.headerParams = params
        GSManager.shared().checkApproval(for: user, onCompletion: {
          (approved, firstTransaction, text, error) in
            self.simplBtn.isHidden = !approved
            self.simplBtn.setTitle(text, for: self.simplBtn.state)
            if (approved){
                self.setStatus("User is approved")
            }else {
                self.setStatus("User is not approved")
            }
        })
    }
    
    private func callEligility(){
        let body: [String: String] = ["number": self.userModel?.phoneNumber ?? "", "amount_in_paise": "\(String(describing: cartController!.getTotal()))00", "items": ""]
        self.userNetworkClient.checkEligibility(token: zeroClickToken, dictionary: body, completion: {
            (completed, responseJson, error) in
            if let error = error {
                NSLog("Error: \(error)")
            } else {
                let redirection_url: String = responseJson["redirection_url"] as? String ?? ""
                if completed{
                    DispatchQueue.main.sync {
                        self.setStatus("User is eligible to make this transaction")
                        self.simplBtn.isHidden = false
                        self.simplBtn.setTitle("Pay with simpl", for: self.simplBtn.state)
                    }
                } else if redirection_url.count > 0 {
                    DispatchQueue.main.sync {
                        GSManager.shared().openRedirectionURL(redirection_url, onCompletion: {
                            (response, error) in
                            if error != nil {
                                NSLog("%@", error.debugDescription)
                            } else {
                                
                            }
                        })
                    }
                } else {
                    DispatchQueue.main.sync {
                        self.setStatus("something went wrong \(String(describing: responseJson["error_code"] as? String))")
                        self.status.textColor = UIColor.red
                    }
                }
            }
        })
    }
    
    private func generateZCToken(){
        let user = GSUser(phoneNumber: self.userModel?.phoneNumber ?? "", email: self.userModel?.emailId ?? "")
        GSManager.shared().generateToken(for: user) {
            (jsonResponse, error) in
            if error != nil {
                NSLog("SDK DEMO APP ERRO: %@", error.debugDescription)
            } else {
                self.simplBtn.isEnabled = false
                let data = jsonResponse!["data"] as! [AnyHashable: Any]
                self.zeroClickToken = data["zero_click_token"] as! String
                self.performZCTransaction()
            }
        }
    }
    
    private func performZCTransaction(){
        let body: [String: String] = ["number": self.userModel?.phoneNumber ?? "", "amount_in_paise": "\(String(describing: cartController!.getTotal()))00", "items": ""]
        self.userNetworkClient.placeOrder(token: zeroClickToken, dictionary: body, completion: {
            (completed, responseJson, error) in
            if let error = error {
                NSLog("Error: \(error)")
            } else {
                let redirection_url: String = responseJson["redirect_url"] as? String ?? ""
                if completed{
                    // TODO steps after finishing the transaction
                    DispatchQueue.main.sync {
                        print("transaction is completed")
                        self.transactionStatus = TransactionStatus.complete
                    }
                } else if redirection_url.count > 0{
                    DispatchQueue.main.sync {
                        GSManager.shared().openRedirectionURL(redirection_url, onCompletion: {
                            (response, error) in
                            if error != nil {
                                NSLog("%@", error.debugDescription)
                            } else {
                                
                            }
                        })
                    }
                } else {
                    DispatchQueue.main.sync {
                        self.setStatus("something went wrong \(String(describing: responseJson["error_code"] as? String))")
                        self.status.textColor = UIColor.red
                    }
                }
            }
        })
    }

    @IBAction func simplBtnClick(_ sender: Any) {
        if (self.userModel?.hasZeroClickToken ?? false){
            self.performZCTransaction()
        } else {
            self.generateZCToken()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "toCompleted" && self.transactionStatus == TransactionStatus.incomplete){
            return true
        }
        
        return false
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    enum TransactionStatus: String {
        case incomplete = "incomplete"
        case complete = "complete"
    }

}
