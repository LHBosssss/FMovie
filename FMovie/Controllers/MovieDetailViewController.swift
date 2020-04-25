//
//  MovieDetailViewController.swift
//  FMovie
//
//  Created by Ho Duy Luong on 4/23/20.
//  Copyright © 2020 Ho Duy Luong. All rights reserved.
//

import UIKit
import AVKit
import SwiftyJSON
import SDWebImage
import RealmSwift

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieYear: UIButton!
    @IBOutlet weak var movieCountry: UIButton!
    @IBOutlet weak var movieTime: UIButton!
    @IBOutlet weak var movieDesciption: UITextView!
    @IBOutlet weak var movieActors: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var listLink: UITableView!
    
    var movieInformationManager = MovieInformationManager()
    var movieItem = JSON()
    var listTitleAndLink = JSON()
    let fshareLinkManager = FshareLinkManager()
    var session = ""
    var token = ""
    var linkToPlay = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieInformationManager.delegate = self
        fshareLinkManager.delegate = self
        
        listLink.removeExtraCellLines()
        
        scrollView.layer.cornerRadius = 30.0
        self.movieImage.layer.cornerRadius = 30.0
        updateUI()
        self.listLink.layer.cornerRadius = 30.0
        self.listLink.isHidden = true
        self.listLink.dataSource = self
        self.listLink.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func updateUI() {
        let title = self.movieItem["title"].stringValue
        let link = self.movieItem["link"].stringValue
        let id = self.movieItem["id"].stringValue
        self.movieTitle.text = String(title.split(separator: "&").first ?? "")
        
        print(self.movieItem["image"].stringValue)
        self.movieImage.sd_setImage(with: URL(string: self.movieItem["image"].stringValue), completed: nil)
        
        if link != "" {
            DispatchQueue.global().async {
                self.movieInformationManager.getMovieDescriptionInformation(id: id)
                print("get description \(Thread.current)")
            }
            DispatchQueue.global(qos: .utility).async {
                self.movieInformationManager.getMovieExtraInformation(url: link)
                print("get extra + actors \(Thread.current)")
            }
        } else {
            DispatchQueue.main.async {
                self.movieInformationManager.getMovieDescriptionInformation(id: id)
                print("get description")
            }
        }
    }
    
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        print("Play!!!")
        self.listLink.isHidden = !self.listLink.isHidden
        print("ID = \(self.movieItem["id"])")
        if !self.listLink.isHidden {
            DispatchQueue.global().async {
                self.movieInformationManager.getMovieLink(id: self.movieItem["id"].stringValue)
            }
            
        }
    }
    
    
}

extension MovieDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(listTitleAndLink.count)
        print("Data Source")
        return listTitleAndLink.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(listTitleAndLink[indexPath.row])
        let cell = tableView.dequeueReusableCell(withIdentifier: "LinkCell") as! LinkViewCell
        var text = self.listTitleAndLink[indexPath.row]["title"].stringValue
        
        cell.linkTitle.text = text
        
        return cell
    }
    
}


extension MovieDetailViewController: MovieInformationManagerDelegate {
    func getMovieLinkSuccess(links: JSON) {
        print("Success")
        print(links)
        print("Count = \(links.count)")
        self.listTitleAndLink = links
        self.listLink.reloadData()
    }
    
    func getMovieLinkFailed() {
        let alert = UIAlertController(title: "Tải dữ liệu thất bại", message: "Không thể tải dữ liệu! Vui lòng kiểm tra lại mạng.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func getMovieExtraInformationSuccess(extraInfo: JSON) {
        print("Extra Information: \(extraInfo)")
        self.movieYear.setTitle(extraInfo["date"].stringValue, for: .normal)
        self.movieCountry.setTitle(extraInfo["country"].stringValue, for: .normal)
        self.movieTime.setTitle(extraInfo["runtime"].stringValue, for: .normal)
    }
    
    func getMovieExtraInformationFailed() {
        
    }
    
    func getMovieActorsInformationSuccess(actorsInfo: String) {
        print("Actors Information: \(actorsInfo)")
        self.movieActors.text = actorsInfo
    }
    
    
    func getMovieDescriptionInformationSuccess(description: JSON) {
        print("Description Information: \(description)")
        self.movieDesciption.text = description["descriptionInfo"].stringValue
        self.movieTitle.text = description["title"].stringValue.replacingOccurrences(of: "&&", with: "\n")
    }
    
    func getMovieDescriptionInformationFailed() {
        print("Description Failed")
    }
}


extension MovieDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.listLink.deselectRow(at: indexPath, animated: true)
        self.linkToPlay = ""
        
        let link = listTitleAndLink[indexPath.row]["link"].stringValue
        print("Selected \(link)")
        let isFolderLink = link.contains("folder")
        print("Is folder: \(isFolderLink)")
        
        let realm = try! Realm()
        let accountData = realm.objects(FshareAccount.self)
        let count = accountData.count
        if count > 0 {
            if let session = accountData.first?.sessionID, let token = accountData.first?.token {
                self.session = session
                self.token = token
                if isFolderLink {
                    fshareLinkManager.getFolderLink(session: session, token: token, link: link)
                } else {
                    fshareLinkManager.getDirectLink(session: session, token: token, link: link)
                }
            }
        }
        
    }
}


extension MovieDetailViewController: FshareLinkManagerDelegate {
    
    func getFolderLinkSuccess(links: [JSON]) {
        print("Success")
        print(links)
        print("Count = \(links.count)")
        self.listTitleAndLink = JSON(links)
        self.listLink.reloadData()
    }
    
    func getDirectLinkSuccess(link: String) {
        print("Fucking UP Direct Link: \(link)")
        guard let url = URL(string: link) else {return}
        linkToPlay = link
        performSegue(withIdentifier: "gotoMoviePlayer", sender: nil)
        
    }
//
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoMoviePlayer" {
            let viewController = segue.destination as! MoviePlayerViewController
            viewController.url = linkToPlay
        }
    }
    
    func getLinkFailed() {
        let alert = UIAlertController(title: "Tải dữ liệu thất bại", message: "Không thể tải dữ liệu!", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

extension UITableView {
    func removeExtraCellLines() {
        tableFooterView = UIView(frame: .zero)
    }
}
