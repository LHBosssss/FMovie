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

class SelectSubtitleViewController: UIViewController {
    var listSubtitle = JSON()
    var subURLtoPlay = ""
    var titleToPlay = ""
    var subtitleManager: SubtitleManager?

    @IBOutlet var listSubtitleLink: UITableView!
    @IBOutlet weak var movieTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listSubtitleLink.dataSource = self
        listSubtitleLink.delegate = self
        movieTitle.text = titleToPlay
        print("Select Sub")
        getData()
    }
    @IBAction func dissmissPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getData() {
        let fm = FileManager.default
        var documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        documentPath += "/SubtitleFolder"
        do {
            let allfile = try fm.contentsOfDirectory(atPath: documentPath)
            print(allfile)
            var listFile = [[String : String]]()
            for file in allfile {
                let title = file
                let url = documentPath + "/" + title
                let subtitleItem : [String : String] = [
                    "title" : title,
                    "link" : url
                ]
                listFile.append(subtitleItem)
            }
            self.listSubtitle = JSON(listFile)
            print(self.listSubtitle)
            self.listSubtitleLink.reloadData()
        } catch {
            print("Get file error")
        }
    }
    
    
}
// MARK: - Table view data source
extension SelectSubtitleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listSubtitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell", for: indexPath)
        cell.textLabel?.text = listSubtitle[indexPath.row]["title"].stringValue
        return cell
    }
    
}

extension SelectSubtitleViewController: UITableViewDelegate  {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.subURLtoPlay = listSubtitle[indexPath.row]["link"].stringValue
        subtitleManager?.subtitleURL = self.subURLtoPlay
        subtitleManager?.selected()
        self.dismiss(animated: true, completion: nil)
    }
}


