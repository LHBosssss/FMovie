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

protocol MoviesManagerDelegate {
    func getMoviesSuccess(listMovies: JSON)
    func getMoviesFailed()
}

class MoviesManager {
    
    var delegate: MoviesManagerDelegate?
    // MARK: - Get Home Page Movies
    
    func getFeedMovies(search: String? = "", page: Int) {
        print("Get feed movies \(Thread.current)")
        var listMovies = JSON()
        let requestURL = "https://www.thuvienaz.net/?feed=fsharejson&search=\(search ?? "")&page=\(search == "" ? 14*(page-1) : page)"
        print(requestURL)
        AF.request(requestURL).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                listMovies = json
                self.delegate?.getMoviesSuccess(listMovies: listMovies)
                return
            case .failure(let error):
                print(error)
                self.delegate?.getMoviesFailed()
            }
        }
    }
    
    // MARK: - Get Genre Movies
    func getGenreMovies(genre: String, page: Int) {
        print("Get genre movies \(Thread.current)")
        var listMovies = [[String:String]]()
        var requestURL = "https://www.thuvienaz.net/genre/" + genre + "/page/\(page)"
        if genre == "hot" {
            requestURL = "https://www.thuvienaz.net"
        }
        print(requestURL)
        AF.request(requestURL).responseString { (response) in
            do {
                let html = try response.result.get()
                let doc: Document = try SwiftSoup.parse(html)
                var divElement = try doc.getElementsByTag("body").first()
                if genre == "" {
                    print("Get Hot Phim")
                    divElement = try doc.getElementById("featured-titles")
                } else {
                    divElement = try doc.getElementById("contenedor")
                    print("Get genre \(genre)")
                }
                let classElements = try divElement!.getElementsByClass("item movies")
                for element in classElements {
                    let mainInfo: [String:String] = self.getMovieMainInformation(element: element)
//
                        listMovies.append(mainInfo)
//
                    
                }
                self.delegate?.getMoviesSuccess(listMovies: JSON(listMovies))
            } catch Exception.Error(let type, let message) {
                print(type)
                print(message)
                self.delegate?.getMoviesFailed()
            } catch {
                print("error")
                self.delegate?.getMoviesFailed()
            }
        }
    }
    
    
    //    // MARK: - Get Movie Main Information
    
    func getMovieMainInformation(element: Element) -> [String:String] {
        var movieData = [String:String]()
        do {
            let itemID = try element.select("article").first()!.attr("id")
            let id = String(itemID.split(separator: "-").last!)
            
            // Get poster image + title
            let poster: Element = try element.select("img").first()!
            let posterImage: String = try poster.attr("src")
            let title: String = try poster.attr("alt")
            let image: String = posterImage.replacingOccurrences(of: "-225x315", with: "")
            
            // Get Movie Link
            let link: String = try element.select("a").first()!.attr("href")
            
            // Create Movie Main Information
            movieData = [
                "id": id,
                "title": title,
                "image": image,
                "link": link
            ]
            return movieData
        } catch Exception.Error(let type, let message) {
            print(type)
            print(message)
            return movieData
        } catch {
            print("Get Movie Main Information Error")
            return movieData
        }
    }
    
 
}
