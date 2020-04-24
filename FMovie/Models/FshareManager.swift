//
//  FshareManager.swift
//  FMovie
//
//  Created by Ho Duy Luong on 4/20/20.
//  Copyright © 2020 Ho Duy Luong. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol FshareManagerDelegate {
    func sessionIsAlive(_ fshareManager: FshareManager)
    func sessionIsDead(_ fshareManager: FshareManager)
    func loginSuccess(_ fshareManager: FshareManager, session: String, token: String)
    func loginFailed(_ fshareManager: FshareManager)
}

class FshareManager {
    var token: String
    var sessionID: String
    private let headers: HTTPHeaders
    var delegate: FshareManagerDelegate?
    
    init(token: String, session: String) {
        self.token = token
        self.sessionID = session
        self.headers = [
            "Referer" : "www.fshare.vn",
            "User-agent" : "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.75 Safari/537.36 Edg/77.0.235.25",
            "Cookie" : "session_id=\(session)"
        ]
    }
    
    func checkSession() {
        let requestURL = "https://api.fshare.vn/api/user/get"
        AF.request(requestURL, method: .get, headers: self.headers).responseJSON { (response) in
            switch response.result {
                
            case .success(let value):
                let json = JSON(value)
                if json["account_type"] == "Vip" {
                    self.delegate?.sessionIsAlive(self)
                    return
                } else {
                    self.delegate?.sessionIsDead(self)
                    return
                }
            case .failure(let value):
                self.delegate?.sessionIsDead(self)
                return
            }
        }
    }
    
    func login(email: String, pass: String) {
        let requestURL = "https://api.fshare.vn:443/api/user/login"
        let dataRequest = [
            "app_key" : "L2S7R6ZMagggC5wWkQhX2+aDi467PPuftWUMRFSn",
            "user_email" : email,
            "password" : pass
        ]
        AF.request(requestURL, method: .post, parameters: dataRequest, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let responseData = JSON(value)
                print(responseData)
                if responseData["msg"] == "Login successfully!" {
                    print("Sussessfully Login")
                    let session = responseData["session_id"].stringValue
                    let token = responseData["token"].stringValue
                    self.delegate?.loginSuccess(self, session: session, token: token)
                    return
                } else {
                    self.delegate?.loginFailed(self)
                    return
                }
            case .failure(let value):
                self.delegate?.loginFailed(self)
                return
            }
        }
    }
}
