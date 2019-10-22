//
//  PaymentViewController.swift
//  simpl-demo-app-with-sdk-ios
//
//  Copyright © 2019 Simpl Pay. All rights reserved.
//

import UIKit
import SimplZeroClick

class PaymentViewController: UIViewController {

    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var simplBtn: UIButton!
    
    var total: Int = 0
    var userModel: User? = nil
    var zeroClickToken: String = ""
    var userNetworkClient: UserNetworkClient = UserNetworkClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTotal(self.total)
    
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
        // Add your merchantID here.
        GSManager.initialize(withMerchantID: self.userModel?.emailId ?? "")
        // While going live, change this to false 
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
        params["transaction_amount_in_paise"] = "\(total * 100)"
        let user = GSUser(phoneNumber: self.userModel!.phoneNumber, email: self.userModel!.emailId)
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
    };
    
    private func callEligility(){
        let body: [String: String] = ["number": self.userModel?.phoneNumber ?? "", "amount_in_paise": "\(total * 100)", "items": ""]
        self.userNetworkClient.checkEligibility(token: zeroClickToken, dictionary: body, completion: {
            (completed, responseJson, error) in
            if let err : Error = error {
                NSLog("Error: \(err.localizedDescription)")
                self.setStatus(error!.localizedDescription)
            } else {
                let redirection_url: String = responseJson["redirection_url"] as? String ?? ""
                if completed{
                    self.setStatus("User is eligible to make this transaction")
                    self.simplBtn.isHidden = false
                    self.simplBtn.setTitle("Pay with simpl", for: self.simplBtn.state)
                } else if redirection_url.count > 0 {
                    GSManager.shared().openRedirectionURL(redirection_url, onCompletion: {
                        (response, error) in
                        if error != nil {
                            NSLog("%@", error!.localizedDescription)
                            self.setStatus("Error \(error!.localizedDescription)")
                        } else {
                            self.performZCTransaction()
                        }
                    })
                } else {
                    self.setStatus("something went wrong \(String(describing: responseJson["error_code"]))")
                    self.status.textColor = UIColor.red
                }
            }
        })
    }
    
    private func generateZCToken(){
        let user = GSUser(phoneNumber: self.userModel!.phoneNumber, email: self.userModel!.emailId)
        GSManager.shared().generateToken(for: user) {
            (jsonResponse, error) in
            if error != nil {
                NSLog("SDK DEMO APP ERRO: %@", error!.localizedDescription)
                self.setStatus("SDK error in gerating zerocilck token")
            } else {
                self.simplBtn.isEnabled = false
                let data = jsonResponse!["data"] as! [AnyHashable: Any]
                self.zeroClickToken = data["zero_click_token"] as! String
                //self.performZCTransaction()
            }
        }
    }
    
    private func performZCTransaction(){
        let items: [[String: String]] = [[
            "sku": "some id",
            "quantity": "12",
            "rate_per_item": "1200"
        ]]
        let body: [String: Any] = ["number": self.userModel!.phoneNumber, "amount_in_paise": "\(total * 100)", "items": items]
        self.userNetworkClient.placeOrder(token: zeroClickToken, dictionary: body, completion: {
            (completed, responseJson, error) in
            if let error = error {
                NSLog("Error: \(error)")
                self.setStatus("Error: \(error.localizedDescription)")
            } else {
                let redirection_url = responseJson["redirect_url"] as? String
                if completed{
                    self.performSegue(withIdentifier: "toCompleted", sender: nil)
                } else if redirection_url != nil {
                    GSManager.shared().openRedirectionURL(redirection_url!, onCompletion: {
                        (response, error) in
                        if error != nil {
                            NSLog("%@", error!.localizedDescription)
                            self.setStatus("Error: \(error!.localizedDescription)")
                        } else {
                            self.performZCTransaction()
                        }
                    })
                } else {
                    self.setStatus("something went wrong \(String(describing: responseJson["error_code"]))")
                    self.status.textColor = UIColor.red
                }
            }
        })
    }

    @IBAction func simplBtnClick(_ sender: Any) {
        if (self.userModel!.hasZeroClickToken){
            self.performZCTransaction()
        } else {
            self.generateZCToken()
        }
    }
}
