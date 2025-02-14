//
//  MoviesManager.swift
//  FMovie
//
//  Created by Ho Duy Luong on 4/21/20.
//  Copyright © 2020 Ho Duy Luong. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftSoup

protocol MovieInformationManagerDelegate {
    func getMovieExtraInformationSuccess(extraInfo: JSON)
    func getMovieExtraInformationFailed()
    
    func getMovieActorsInformationSuccess(actorsInfo: String)
    
    func getMovieDescriptionInformationSuccess(description: JSON)
    func getMovieDescriptionInformationFailed()
    
    func getMovieLinkSuccess(links: JSON)
    func getMovieLinkFailed()
    
}

class MovieInformationManager {
    
    var delegate: MovieInformationManagerDelegate?
    // MARK: - Get Movie Extra Information
    
    func getMovieExtraInformation(url: String) {
        print("getMovieExtraInformation \(Thread.current)")
        
        var extraInfo = JSON()
        var actors = ""
        guard let url = URL(string: url) else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = TimeInterval(exactly: 10)!
        AF.request(url).responseString { (response) in
            do {
                let html = try response.result.get()
                let doc: Document = try SwiftSoup.parse(html)
                // Get Year, Country, Runtime
                let extraClass = try doc.getElementsByClass("extra").first()!
                let date = try extraClass.getElementsByClass("date").first()?.text()
                let country = try extraClass.getElementsByClass("country").first()?.text()
                let runtime = try extraClass.getElementsByClass("runtime").first()?.text()
                extraInfo = [
                    "date" : date ?? "",
                    "country" : country ?? "",
                    "runtime" : runtime ?? ""
                ]
                self.delegate?.getMovieExtraInformationSuccess(extraInfo: extraInfo)
                // Get Actors
                let personsClass = try doc.getElementsByClass("persons").last()!
                let listActor = try personsClass.getElementsByClass("cast")
                let listActorRow = try listActor.select("li")
                print(listActorRow.count)
                for actor in listActorRow {
                    let act = try actor.text()
                    actors += act
                    if actor != listActorRow.last() {
                        actors += ", "
                    } else {
                        actors += "."
                    }
                    self.delegate?.getMovieActorsInformationSuccess(actorsInfo: actors)
                }
            } catch Exception.Error(let type, let message) {
                print("Get Movie Extra Information Error: \(type) \(message)")
                self.delegate?.getMovieExtraInformationFailed()
            } catch {
                print("Get Movie Extra Information Error")
                self.delegate?.getMovieExtraInformationFailed()
            }
        }
    }
    
    func getMovieDescriptionInformation(id: String) {
        print("getMovieDescriptionInformation \(Thread.current)")
        
        guard let url = URL(string: "https://vaphim.com/?feed=fsharejson&id=\(id)") else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = TimeInterval(exactly: 10)!
        AF.request(urlRequest).responseJSON { (response) in
            switch response.result {
                
            case .success(let value):
                let json = JSON(value)
                let des = json["description"].stringValue
                let title = json["title"].stringValue
                let image = json["image"].stringValue
                let description: JSON = [
                    "title": title,
                    "image": image,
                    "descriptionInfo": des
                ]
                self.delegate?.getMovieDescriptionInformationSuccess(description: description)
                
            case .failure(let error):
                print("Get Movie Description Information Error: \(error)")
                self.delegate?.getMovieDescriptionInformationFailed()
            }
        }
    }
    
    func getMovieLink(id: String) {
        print("getMovieLink \(Thread.current)")
        
        guard let url = URL(string: "https://vaphim.com/?feed=fsharejson&id=\(id)") else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = TimeInterval(exactly: 10)!
        AF.request(urlRequest).responseJSON { (response) in
            switch response.result {
                
            case .success(let value):
                let json = JSON(value)
                let links = json["link"]
                self.delegate?.getMovieLinkSuccess(links: links)
                
            case .failure(let error):
                print("Get Movie Description Information Error: \(error)")
                self.delegate?.getMovieLinkFailed()
            }
        }
    }
    
    
    func getMovieLinkV2(id: String) {
        print("getMovieLinkV2 \(Thread.current)")
        
        guard let url = URL(string: "https://www.thuvienaz.net/convert-video?id=\(id)") else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = TimeInterval(exactly: 10)!
        AF.request(urlRequest).responseString { (response) in
            do {
                var listLinktoReturn = [[String : String]]()
                let html = try response.result.get()
                let doc: Document = try SwiftSoup.parse(html)
                // Get Year, Country, Runtime
                let tableClass = try doc.getElementsByClass("post_table").first()
                let tbody = try tableClass?.select("tbody").first()
                let listLink = try tbody?.getElementsByTag("tr")
                if let list = listLink {
                    for link in list {
                        let title = try link.text()
                        let link = try link.select("input").attr("value")
                        let itemLink = [
                            "title" : title,
                            "link" : link
                        ]
                        listLinktoReturn.append(itemLink)
                        print(itemLink)
                    }
                    let json = JSON(listLinktoReturn)
                    self.delegate?.getMovieLinkSuccess(links: json)
                }
            } catch Exception.Error(let type, let message) {
                print("Get Movie Extra Information Error: \(type) \(message)")
                self.delegate?.getMovieExtraInformationFailed()
            } catch {
                print("Get Movie Extra Information Error")
                self.delegate?.getMovieExtraInformationFailed()
            }
        }
    }
}
