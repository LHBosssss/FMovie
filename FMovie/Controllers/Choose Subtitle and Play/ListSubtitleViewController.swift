//
//  ListSubtitleTableViewController.swift
//  dummy
//
//  Created by Ho Duy Luong on 4/27/20.
//  Copyright © 2020 Ho Duy Luong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSoup
import SwiftyJSON
import Zip

class ListSubtitleViewController: UIViewController {
    
    var listSubtitle = JSON()
    var linkToGet = JSON()
    var titleToPlay = ""
    var subtitleManager: SubtitleManager?
    
    @IBOutlet var listSubtitleLink: UITableView!
    @IBOutlet weak var movieTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subtitleManager?.delegate2 = self
        listSubtitleLink.dataSource = self
        listSubtitleLink.delegate = self
        movieTitle.text = titleToPlay
        fetchFirstData()
    }
    
    
    @IBAction func dissmissPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchFirstData() {
        movieTitle.text = linkToGet["title"].stringValue
        let link = linkToGet["link"]
        let requestURL = "https://subscene.com\(link)"
        let headers: HTTPHeaders = [
            "User-Agent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:41.0) Gecko/20100101 Firefox/41.0",
            "Referer" : "https://subscene.com",
            "Accept-encoding" : "gzip",
            "Cookie" : "LanguageFilter=45"
        ]
        
        AF.request(requestURL, method: .get, headers: headers).responseString { (response) in
            do {
                var listLink = [[String : String]]()
                let result = try response.result.get()
                let doc: Document = try SwiftSoup.parse(result)
                
                let table = try doc.getElementsByTag("table").first()!
                let tbody = try table.select("tbody")
                let list = try tbody.select("tr")
                for tr in list {
                    let td = try tr.select("td").first()!
                    let a = try td.select("a").first()
                    if let title = try a?.select("span").last()?.text()
                        , let link = try a?.attr("href") {
                        let subtitleItem : [String : String] = [
                            "title" : title,
                            "link" : link
                        ]
                        listLink.append(subtitleItem)
                    }
                    
                }
                self.listSubtitle = JSON(listLink)
                print(self.listSubtitle)
                self.listSubtitleLink.reloadData()
            }
            catch (let error) {
                print("Fetch List Subtitle Error: \(error)")
            }
        }
    }
    
    func downloadSubtitle(url: String) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let dataPath = docURL.appendingPathComponent("SubtitleFolder")
        if !FileManager.default.fileExists(atPath: dataPath.absoluteString) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, in: .userDomainMask, options: .removePreviousFile)
        let fm = FileManager.default
        let documentPath = documentsDirectory + "/SubtitleFolder"
        do {
            try fm.removeItem(atPath: documentPath)
        } catch {
            print("Remove Item Error")
        }
        AF.download(url, to: destination ).responseData { response in
            let filename = response
            print(filename)
            let fileURL = response.fileURL!
            print(fileURL)
            do {
                try Zip.unzipFile(fileURL, destination: dataPath, overwrite: true, password: nil, progress: { (progress) -> () in
                    print(progress)
                }) // Unzip
                try fm.removeItem(at: fileURL)
            }
            catch {
                print("Something went wrong")
            }
            
            self.performSegue(withIdentifier: "gotoSelectSubtitle", sender: nil)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! SelectSubtitleViewController
        controller.titleToPlay = self.titleToPlay
        controller.subtitleManager = self.subtitleManager
    }
    
    
}
// MARK: - Table view data source
extension ListSubtitleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSubtitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell", for: indexPath)
        cell.textLabel?.text = listSubtitle[indexPath.row]["title"].stringValue
        return cell
    }
    
}

extension ListSubtitleViewController: UITableViewDelegate  {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
        print(listSubtitle[indexPath.row])
        
        let link = listSubtitle[indexPath.row]["link"]
        let requestURL = "https://subscene.com\(link)"
        let headers: HTTPHeaders = [
            "User-Agent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:41.0) Gecko/20100101 Firefox/41.0",
            "Referer" : "https://subscene.com",
            "Accept-encoding" : "gzip",
            "Cookie" : "LanguageFilter=45"
        ]
        
        AF.request(requestURL, method: .get, headers: headers).responseString { (response) in
            do {
                let result = try response.result.get()
                let doc: Document = try SwiftSoup.parse(result)
                
                let divDownload = try doc.getElementsByClass("download").first()
                let alink = try divDownload?.select("a")
                let link = try alink?.attr("href")
                if let linkToDownload = link {
                    self.downloadSubtitle(url: "https://subscene.com\(linkToDownload)")
                }
            }
            catch (let error) {
                print("Fetch Link Download Subtitle Error: \(error)")
            }
            
        }
    }
    
}


extension ListSubtitleViewController: SubtitleManagerDelegate {
    func selectedSubtitle(url: String) {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
            print("Delegate 2")
            self.dismiss(animated: true, completion: nil)
        }
    }
}
