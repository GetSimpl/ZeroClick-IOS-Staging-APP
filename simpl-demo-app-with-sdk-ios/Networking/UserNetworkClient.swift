//
//  UserNetworkClient.swift
//  simpl-demo-app-with-sdk-ios
//
//  Created by Eleven on 21/05/19.
//  Copyright © 2019 Simpl Pay. All rights reserved.
//

import Foundation

struct UserNetworkClient {
    
    func checkUserHasToken(dictionary: [String: String], completion: @escaping (_ hasToken: Bool, Error?) -> Void) {
        let url: URL = URL(string: Urls.HAS_TOKEN)!
        var request = URLRequest(url: url )
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                
                // Something went wrong
                completion(false, NSError())
                return
            }
            
            if let error = error {
                NSLog("Error: \(error)")
                completion(false, error)
                return
            }
            
            guard let data = data else {
                completion(false, NSError())
                return
            }
            
            do {
                let hasToken = try JSONDecoder().decode(HasTokenResponse.self, from: data)
                completion(hasToken.success, nil)
            } catch {
                completion(false, error)
                return
            }
        }.resume()
    }
    
    func placeOrder(token: String, dictionary: [String: Any], completion: @escaping (_ completed: Bool, _ dictionary: [String: Any], Error?) -> Void) {
        chargeOrEligibiltyCheck(type: RequestEndPoint.charge.rawValue, token: token, dictionary: dictionary, completion: completion)
    }
    
    func checkEligibility(token: String, dictionary: [String: Any], completion: @escaping (_ completed: Bool, _ dictionary: [String: Any], Error?) -> Void){
        // TODO send available credit also back.
       chargeOrEligibiltyCheck(type: RequestEndPoint.eligibility.rawValue, token: token, dictionary: dictionary, completion: completion)
    }
    
    private func chargeOrEligibiltyCheck(type: String, token: String, dictionary: [String: Any], completion: @escaping (_ completed: Bool, _ dictionary: [String: Any], Error?) -> Void){
        var url: URL
        
        if type == RequestEndPoint.eligibility.rawValue{
            url = URL(string: Urls.ELIGIBILITY_CHECK)!
        } else {
            url = URL(string: Urls.PLACE_SIMPL_ORDER)!
        }
        var request = URLRequest(url: url )
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "zero_click_token")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(false, ["": ""], NSError())
                return
            }
            
            if let error = error {
                NSLog("Erro: \(error)")
                completion(false, ["": ""], error)
            }
            
            guard let dataResponse = data, error == nil else {
                NSLog("Response error \(error?.localizedDescription ?? "Response Error")")
                completion(false, ["": ""], NSError())
                return
            }
        
            do {
                guard let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: []) as? [String: Any] else { return }
                completion(jsonResponse["success"] as? Bool ?? false, jsonResponse, error)
            } catch {
                completion(false, ["": ""], error)
                return
            }
        }.resume()
    }
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    enum RequestEndPoint: String {
        case eligibility = "eligibilty"
        case charge = "charge"
    }
    
    struct HasTokenResponse: Codable {
        let success: Bool
    }

}
