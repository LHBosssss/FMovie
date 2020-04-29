//
//  MovieDetailViewController.swift
//  FMovie
//
//  Created by Ho Duy Luong on 4/23/20.
//  Copyright © 2020 Ho Duy Luong. All rights reserved.
//

import UIKit
import AVKit
import Alamofire
import SwiftyJSON
import SDWebImage
import RealmSwift
import Zip

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
    @IBOutlet weak var loadingLink: UIActivityIndicatorView!
    
    var movieInformationManager = MovieInformationManager()
    var movieItem = JSON()
    var listTitleAndLink = JSON()
    let fshareLinkManager = FshareLinkManager()
    var session = ""
    var token = ""
    var linkToPlay = ""
    var titleToPlay = ""
    var subURL : URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieInformationManager.delegate = self
        fshareLinkManager.delegate = self
        listLink.removeExtraCellLines()
        self.loadingLink.layer.cornerRadius = 10
        self.loadingLink.backgroundColor = UIColor.systemGray4
        
        scrollView.layer.cornerRadius = 30.0
        self.movieImage.layer.cornerRadius = 30.0
        updateUI()
        self.listLink.layer.cornerRadius = 30.0
        self.listLink.isHidden = true
        self.listLink.dataSource = self
        self.listLink.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        self.loadingLink.stopAnimating()
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
                self.movieInformationManager.getMovieLinkV2(id: self.movieItem["id"].stringValue)
            }
        }
    }
    
    
}

extension MovieDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(listTitleAndLink.count)
        print("Data Source")
        self.loadingLink.stopAnimating()
        return listTitleAndLink.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(listTitleAndLink[indexPath.row])
        let cell = tableView.dequeueReusableCell(withIdentifier: "LinkCell") as! LinkViewCell
        let text = self.listTitleAndLink[indexPath.row]["title"].stringValue
        
        cell.linkTitle.text = text
        
        return cell
    }
    
}


extension MovieDetailViewController: MovieInformationManagerDelegate {
    func getMovieLinkSuccess(links: JSON) {
        print("Success")
        loadingLink.stopAnimating()
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
        self.loadingLink.stopAnimating()
        print("Description Information: \(description)")
        self.movieDesciption.text = description["descriptionInfo"].stringValue
        self.titleToPlay = description["title"].stringValue
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
        self.loadingLink.startAnimating()
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
        let checkLink = String(link.split(separator: ".").last ?? "")
        if (checkLink == "zip") ||  (checkLink == "srt")  || (checkLink == "ass") {
            downloadSubtitle(url: link)
            loadingLink.stopAnimating()
            playButtonPressed(UIButton(type: .close))
        } else if (checkLink == "iso") {
            loadingLink.stopAnimating()
            return
        } else {
            linkToPlay = link
            if link != "" {
                getIPLink(url: link)
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
            self.loadingLink.stopAnimating()

            do {
                try Zip.unzipFile(fileURL, destination: dataPath, overwrite: true, password: nil, progress: { (progress) -> () in
                    print(progress)
                }) // Unzip
                try fm.removeItem(at: fileURL)
            }
            catch {
                self.subURL = fileURL
                print("Something went wrong")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoMoviePlayer" {
            let viewController = segue.destination as! MoviePlayerViewController
            viewController.mediaURL = linkToPlay
            print(self.movieItem["title"].stringValue)
            print(self.titleToPlay)
            viewController.mediaTitle = self.titleToPlay
            viewController.subURL = self.subURL
        }
    }
    
    func getLinkFailed() {
        let alert = UIAlertController(title: "Tải dữ liệu thất bại", message: "Không thể tải dữ liệu!", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func getIPLink(url: String) {
        let originalURL = url
        
        print(originalURL.split(separator: "/"))
        
        let hostadd = String(originalURL.split(separator: "/")[1])
        
        let host = CFHostCreateWithName(nil, hostadd as CFString).takeRetainedValue()
        CFHostStartInfoResolution(host, .addresses, nil)
        var success: DarwinBoolean = false
        if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray? {
            print(addresses.count)
            if case let theAddress as NSData = addresses.lastObject
            {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length),
                               &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                    let numAddress = String(cString: hostname)
                    print(numAddress)
                    let finalURL = originalURL.replacingOccurrences(of: hostadd, with: numAddress)
                    print(finalURL)
                    linkToPlay = finalURL
                }
            }
        }
        performSegue(withIdentifier: "gotoMoviePlayer", sender: nil)
        
    }
    
}

extension UITableView {
    func removeExtraCellLines() {
        tableFooterView = UIView(frame: .zero)
    }
}
