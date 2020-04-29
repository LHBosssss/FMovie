//
//  FshareLinkManager.swift
//  FMovie
//
//  Created by Ho Duy Luong on 4/25/20.
//  Copyright © 2020 Ho Duy Luong. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol FshareLinkManagerDelegate {
    func getFolderLinkSuccess(links: [JSON])
    func getDirectLinkSuccess(link: String)
    func getLinkFailed()
}

class FshareLinkManager {
    
    var delegate: FshareLinkManagerDelegate?
    
    func getDirectLink(session: String, token: String, link: String) {        
        let requestURL = URL(string: "https://api.fshare.vn/api/session/download")
        let header: HTTPHeaders = [
            "Referer" : "www.fshare.vn",
            "User-Agent": "okhttp/3.6.0",
            "Cookie" : "session_id=\(session)"
        ]
        
        let data = [
            "token": token,
            "url": link
        ]
        AF.request(requestURL!, method: .post,parameters: data,encoding: JSONEncoding.default, headers: header).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let directLink = json["location"].stringValue
                self.delegate?.getDirectLinkSuccess(link: directLink)
                return
            case .failure(let error):
                print(error)
                self.delegate?.getLinkFailed()
            }
        }
    }
    
    
    
    func getFolderLink(session: String, token: String, link: String) {
        let requestURL = URL(string: "https://api.fshare.vn/api/fileops/getFolderList")
        let header: HTTPHeaders = [
            "Cookie" : "session_id=\(session)"
        ]
        let data = [
            "token": token,
            "url": link
        ]
        AF.request(requestURL!, method: .post, parameters: data, encoding: JSONEncoding.default ,headers: header).responseJSON { response in
            switch response.result {
            case .success(let value):
                var links = [JSON]()
                let json = JSON(value)
                let jsonarr = json.arrayValue
                for item in jsonarr {
                    let file: JSON = [
                        "title" : item["ftitle"],
                        "link" : item["furl"]
                    ]
                    links.append(file)
                }
                self.delegate?.getFolderLinkSuccess(links: links)
                print(JSON(links))
                return
            case .failure(let error):
                print(error)
                self.delegate?.getLinkFailed()
            }
        }
    }
    
    
}
