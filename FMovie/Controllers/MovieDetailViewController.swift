//
//  MovieDetailViewController.swift
//  FMovie
//
//  Created by Ho Duy Luong on 4/23/20.
//  Copyright © 2020 Ho Duy Luong. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

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
    var fshareManager: FshareManager?
    var listTitleAndLink = JSON()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieInformationManager.delegate = self
        scrollView.layer.cornerRadius = 30.0
        self.movieImage.layer.cornerRadius = 30.0
        updateUI()
        self.listLink.layer.cornerRadius = 30.0
        self.listLink.isHidden = true
        self.listLink.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func updateUI() {
        let title = self.movieItem["title"].stringValue
        let link = self.movieItem["link"].stringValue
        let id = self.movieItem["id"].stringValue
        self.movieTitle.text = title
        
        print(self.movieItem["image"].stringValue)
        self.movieImage.sd_setImage(with: URL(string: self.movieItem["image"].stringValue), completed: nil)
        
        if link != "" {
            DispatchQueue.main.async {
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
        self.movieInformationManager.getMovieLink(id: self.movieItem["id"].stringValue)
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
        cell.linkTitle.text = self.listTitleAndLink[indexPath.row]["title"].stringValue
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

