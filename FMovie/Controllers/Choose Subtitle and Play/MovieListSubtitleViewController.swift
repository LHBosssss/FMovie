//
//  SubtitlesViewController.swift
//  dummy
//
//  Created by Ho Duy Luong on 4/27/20.
//  Copyright © 2020 Ho Duy Luong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSoup

class MovieListSubtitleViewController: UIViewController {
    
    @IBOutlet weak var listMovieTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var listMovie = JSON()
    var movieTitle = ""
    var movieSelected = JSON()
    var subtitleManager: SubtitleManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Perform Segue")
        subtitleManager?.delegate3 = self
        listMovieTable.delegate = self
        listMovieTable.dataSource = self
        searchBar.delegate = self
        var enTitle = String(movieTitle.split(separator: "&").last ?? "")
        print(enTitle)
        if enTitle.first == " " {
            enTitle.removeFirst(1)
        }
        enTitle = enTitle.replacingOccurrences(of: " ", with: "-")
        print(enTitle)
        fetchData(title: enTitle)
        
        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func dismissPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchData(title: String) {
        let requestURL = "https://subscene.com/subtitles/searchbytitle?query=\(title)"
        let headers: HTTPHeaders = [
            "User-Agent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:41.0) Gecko/20100101 Firefox/41.0",
            "Referer" : "https://subscene.com",
            "Accept-encoding" : "gzip",
            "Cookie" : "LanguageFilter=45"
        ]
        
        AF.request(requestURL, method: .get, headers: headers).responseString { (response) in
            do {
                var listMovie = [[String : String]]()
                let result = try response.result.get()
                let doc: Document = try SwiftSoup.parse(result)
                
                if let divSearchResult = try doc.getElementsByClass("search-result").first() {
                    let list = try divSearchResult.getElementsByTag("li")
                    for item in list {
                        let title = try item.select("a").first()?.text()
                        let link = try item.select("a").first()?.attr("href")
                        let subtitleItem : [String : String] = [
                            "title" : title ?? "",
                            "link" : link ?? ""
                        ]
                        listMovie.append(subtitleItem)
                    }
                    self.listMovie = JSON(listMovie)
                    print(self.listMovie)
                    self.listMovieTable.reloadData()
                }
            }
            catch (let error) {
                print("First Fetch Data Error: \(error)")
            }
        }
    }
    
}

extension MovieListSubtitleViewController: UISearchBarDelegate  {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search clicked")
        searchBar.resignFirstResponder()
        searchPressed(text: searchBar.text)
    }
    
    
    
    func searchPressed(text: String?) {
        if let title = text {
            if title != "" {
                let finalTitle = title.replacingOccurrences(of: " ", with: "-")
                fetchData(title: finalTitle)
            }
        }
    }
    
}

extension MovieListSubtitleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movieSelected = JSON()
        return listMovie.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath)
        cell.textLabel?.text = listMovie[indexPath.row]["title"].stringValue
        return cell
    }
    
    
}

extension MovieListSubtitleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(listMovie[indexPath.row])
        movieSelected = listMovie[indexPath.row]
        performSegue(withIdentifier: "gotoSubtitleList", sender: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoSubtitleList" {
            let controller = segue.destination as! ListSubtitleViewController
            controller.linkToGet = movieSelected
            controller.titleToPlay = movieTitle
            controller.subtitleManager = self.subtitleManager

        }
    }
}


extension MovieListSubtitleViewController: SubtitleManagerDelegate {
    func selectedSubtitle(url: String) {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
            print("Delegate 3")
            self.dismiss(animated: true, completion: nil)
        }
    }
}
