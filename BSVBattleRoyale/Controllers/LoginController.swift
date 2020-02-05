//
//  LoginController.swift
//  BSVBattleRoyale
//
//  Created by John Pitts on 2/4/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

import Foundation

class LoginController {
    
    let baseURL = URL(string: "nonsenseBackendEndpoints.com/blah")!
    
    enum HTTPMethod: String {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
    }
    
    init() {
        
        // if you wanna grab login token from storage, if it exists
    }
    
    func register(with username: String, password: String, completion: @escaping (Error?) -> Void) {
        
        var request = URLRequest(url: baseURL)
        
        request.httpMethod = HTTPMethod.post.rawValue
        
        // The body of our request is JSON.
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let user = User(username: username, password: password)
        
        // Base64( usernamepassword) hash
        
        
        
        do {
            request.httpBody = try JSONEncoder().encode(user)
        } catch {
            NSLog("Error encoding User: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                
                // Something went wrong
                completion(NSError())
                return
            }
            
            if let error = error {
                NSLog("Error signing up: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
        
        // login = adminpassword
        
        func logIn(with username: String, password: String, completion: @escaping (Error?) -> Void) {
            
            // Content-Type: "application/x-
            
            let requestURL = signinURL.appendingPathComponent("grant_type=password&username=admin&password=password")

            var request = URLRequest(url: requestURL)
            
            //HEADERS:
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("dadjoke-client:lambda-secret".toBase64(), forHTTPHeaderField: "Basic ")
            
            request.httpMethod = HTTPMethod.post.rawValue
            
            // The body of our request is JSON.
            //request.setValue("application/json", forHTTPHeaderField: "Accept")
            
    //        let user = User(username: username, password: password)
    //
    //        do {
    //            //request.httpBody = try JSONEncoder().encode(user)
    //        } catch {
    //            NSLog("Error encoding User: \(error)")
    //            completion(error)
    //            return
    //        }
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                if let response = response as? HTTPURLResponse,
                    response.statusCode != 200 {
                    
                    // Something went wrong
                    completion(NSError())
                    return
                }
                
                if let error = error {
                    NSLog("Error logging in: \(error)")
                    completion(error)
                    return
                }
                
                // Get the bearer token by decoding it.
                
                guard let data = data else {
                    NSLog("No data returned from data task")
                    completion(NSError())
                    return
                }
                
                //let decoder = JSONDecoder()
                
                
    //            func fromBase64() -> String? {
    //                guard let data = Data(base64Encoded: self) else { return nil }
    //                return String(data: data, encoding: .utf8)
                
                //let bearer = try JSONDecoder.decode(Bearer.self, from: data)
                
                //let bearer = try Base64Encoded.utf8(Bearer.self, from: data)
                
                //let decodedData = data.utf8
                
                
                
                
                do {
                    let bearer = try String(data: data, encoding: .utf8)
                    let x = Bearer.init(token: bearer!)
                    
                    // We now have the bearer to authenticate the other requests
                    self.bearer = x
                    // store bearer.token as "success"
                    completion(nil)
                } catch {
                    NSLog("Error decoding Bearer: \(error)")
                    completion(error)
                    return
                }
                }.resume()
        }
    
    
}
