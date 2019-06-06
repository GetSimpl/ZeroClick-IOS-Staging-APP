//
//  UserNetworkClient.swift
//  simpl-demo-app-with-sdk-ios
//
//  Created by Eleven on 21/05/19.
//  Copyright © 2019 Simpl Pay. All rights reserved.
//

import Foundation

struct UserNetworkClient {
    
    func checkUserHasToken(dictionary: [String: String], completion: @escaping (_ completed: Bool, _ dictionary: [String: Any], Error?) -> Void) {
       get(url: URL(string: Urls.HAS_TOKEN)!, dictionary: dictionary, completion: completion)
    }
    
    func placeOrder(token: String, dictionary: [String: Any], completion: @escaping (_ completed: Bool, _ dictionary: [String: Any], Error?) -> Void) {
        post(url: URL(string: Urls.PLACE_SIMPL_ORDER)!, token: token, dictionary: dictionary, completion: completion)
    }
    
    func checkEligibility(token: String, dictionary: [String: Any], completion: @escaping (_ completed: Bool, _ dictionary: [String: Any], Error?) -> Void){
        post(url: URL(string: Urls.ELIGIBILITY_CHECK)!, token: token, dictionary: dictionary, completion: completion)
    }
    
    struct HasTokenResponse: Codable {
        let success: Bool
    }

    private func get(url: URL, dictionary: [String: Any], completion: @escaping (_ completed: Bool,_ dictionary: [String: Any], Error?) -> Void){
        var request = URLRequest(url: url )
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                
                // Something went wrong
                completion(false, ["":""], NSError(domain:"", code:response.statusCode, userInfo:nil))
                return
            }
            
            if let error = error {
                NSLog("Error: \(error)")
                completion(false, ["":""], error)
                return
            }
            
            guard let dataResponse = data else {
                completion(false, ["":""], NSError())
                return
            }
            
            do {
                 guard let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: []) as? [String: Any] else { return }
                completion(jsonResponse["success"] as? Bool ?? false, jsonResponse, nil)
            } catch {
                completion(false, ["":""], error)
                return
            }
            }.resume()
    }
    
    private func post(url: URL, token: String, dictionary: [String: Any], completion: @escaping (_ completed: Bool, _ dictionary: [String: Any], Error?) -> Void){
        var request = URLRequest(url: url )
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "zero_click_token")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                DispatchQueue.main.sync {
                    completion(false, ["": ""], NSError(domain:"", code:response.statusCode, userInfo:nil))
                }
                return
            }
            
            if let err = error {
                NSLog("Erro: \(err)")
                DispatchQueue.main.sync {
                    completion(false, ["": ""], err)
                }
            }
            
            guard let dataResponse = data, error == nil else {
                NSLog("Response error \(error?.localizedDescription ?? "Response Error")")
                DispatchQueue.main.sync {
                    completion(false, ["": ""], NSError())
                }
                return
            }
            
            do {
                guard let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: []) as? [String: Any] else { return }
                DispatchQueue.main.sync {
                    completion(jsonResponse["success"] as? Bool ?? false, jsonResponse, error)
                }
            } catch {
                DispatchQueue.main.sync {
                    completion(false, ["": ""], error)
                }
                return
            }
            }.resume()
    }
}
