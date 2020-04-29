//
//  MoviePlayerViewController.swift
//  FMovie
//
//  Created by Ho Duy Luong on 4/26/20.
//  Copyright © 2020 Ho Duy Luong. All rights reserved.
//

import UIKit

class MoviePlayerViewController: UIViewController {
    
    @IBOutlet weak var movieView: UIView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var remainingTime: UILabel!
    @IBOutlet weak var movieProgress: UISlider!
    @IBOutlet weak var barBackground: UIView!
    @IBOutlet weak var progressView: UIStackView!
    @IBOutlet weak var subtitleMenu: UIStackView!
    @IBOutlet weak var controlView: UIStackView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var seekingTime: UILabel!
//    @IBOutlet weak var currentAction: UIImageView!
    @IBOutlet var tapped: UITapGestureRecognizer!
    @IBOutlet weak var subtitleDelay: UILabel!
    
    var mediaPlayer = VLCMediaPlayer()
    var mediaURL = ""
    var mediaTitle = ""
    var maxTimeDidSet = false
    var isSeeking = false
    var subURL : URL?
    var isShowMovieBar = false
    var subtitleManager = SubtitleManager()
    var isShowSubtitleMenu = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMediaPlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mediaPlayer.play()
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeLeft
    }
    
    
    func setupMediaPlayer() {
        loadingIndicator.stopAnimating()
        hideMovieBar()
        subtitleManager.delegate = self
        mediaPlayer.delegate = self
        mediaPlayer.drawable = movieView
//        currentAction.isHidden = true
//        currentAction.layer.cornerRadius = 10
        loadingIndicator.startAnimating()
        loadingIndicator.layer.cornerRadius = 10
        movieProgress.setThumbImage(UIImage(named: "thumb"), for: .normal)
        movieProgress.setThumbImage(UIImage(named: "thumb"), for: .highlighted)
        self.seekingTime.isHidden = true
        movieView.addGestureRecognizer(tapped)
        mediaPlayer.media = VLCMedia(url: URL(string: mediaURL)!)
        
    }
    
    func showMovieBar() {
        self.progressView.isHidden = false
        self.controlView.isHidden = false
        self.barBackground.isHidden = false
        self.movieTitle.isHidden = false
        self.isShowMovieBar = true
    }
    
    
    func hideMovieBar() {
        self.progressView.isHidden = true
        self.controlView.isHidden = true
        self.barBackground.isHidden = true
        self.movieTitle.isHidden = true
        self.subtitleMenu.isHidden = true
        self.isShowMovieBar = false
//        self.currentAction.isHidden = true

    }
    
    @IBAction func downloadSubtitle(_ sender: UIButton) {
        print("Download Sub")
        performSegue(withIdentifier: "gotoDownloadSubtitle", sender: nil)
    }

    @IBAction func selectSubtitle(_ sender: UIButton) {
        print("Select Sub")
        performSegue(withIdentifier: "gotoSelectSubtitle", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoDownloadSubtitle" {
            let controller = segue.destination as! MovieListSubtitleViewController
            controller.movieTitle = self.mediaTitle
            controller.subtitleManager = self.subtitleManager
        }
    }
    
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        print("Tapped")
        
        if isShowMovieBar {
            hideMovieBar()
        } else {
            showMovieBar()
        }
    }
    
    @IBAction func scaleFullScreen(_ sender: UIButton) {
        mediaPlayer.scaleFactor = 0
    }
    
    @IBAction func scaleWidthPressed(_ sender: UIButton) {
        
        let screenScale = UIScreen.main.scale
        let videoWidth = mediaPlayer.videoSize.width
        let screenWidth = UIScreen.main.bounds.width * screenScale
        let willScale = screenWidth / videoWidth
        print(videoWidth)
        print(screenWidth)
        print(willScale)
        mediaPlayer.scaleFactor = Float(willScale)

    }
    @IBAction func scaleHeightPressed(_ sender: UIButton) {
        let screenScale = UIScreen.main.scale
        let videoHeight = mediaPlayer.videoSize.height
        let screenHeight = UIScreen.main.bounds.height * screenScale
        let willScale = screenHeight / videoHeight
        print(videoHeight)
        print(screenHeight)
        print(willScale)
        mediaPlayer.scaleFactor = Float(willScale)
    }
    
    @IBAction func playpausePressed(_ sender: UIButton) {
        if mediaPlayer.isPlaying {
            mediaPlayer.pause()
            let remaining = mediaPlayer.remainingTime
            let time = mediaPlayer.time
//            showImage(name: "pause.fill")
            print("Paused at \(time?.stringValue ?? "nil") with \(remaining?.stringValue ?? "nil") time remaining")
        }
        else {
//            showImage(name: "play.fill")
            mediaPlayer.play()
            print("Playing")
        }
    }
    
    @IBAction func stopPressed(_ sender: UIButton) {
        mediaPlayer.stop()
//        showImage(name: "stop")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backwardPressed(_ sender: UIButton) {
        mediaPlayer.jumpBackward(10)
//        showImage(name: "backward")
    }
    
    @IBAction func forwardPressed(_ sender: UIButton) {
        mediaPlayer.jumpForward(10)
//        showImage(name: "forward")
    }
    
    @IBAction func subtitlePressed(_ sender: UIButton) {
        mediaPlayer.pause()
        isShowSubtitleMenu = !isShowSubtitleMenu
        self.subtitleMenu.isHidden = isShowSubtitleMenu
//        showImage(name: "pause")
    }
    
    @IBAction func subtitleDelayPressed(_ sender: UIStepper) {
        subtitleDelay.text = String(sender.value)
        print(sender.value*1000)
        mediaPlayer.currentVideoSubTitleDelay = Int(sender.value)*1000
        print(mediaPlayer.currentVideoSubTitleDelay)
    }
    
//    func showImage(name: String) {
//        currentAction.isHidden = false
//        currentAction.image = UIImage(systemName: name)
//    }
    
    
    @IBAction func continousSeeking(_ sender: UISlider) {
        isSeeking = true
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: Int(sender.value))
        let time = "\(h >= 10 ? "\(h)" : "0\(h)" ) : \(m >= 10 ? "\(m)" : "0\(m)") : \(s > 10 ? "\(s)" : "0\(s)")"
        seekingTime.isHidden = false
        seekingTime.text = time
        
    }
    
    @IBAction func didEndSeeking(_ sender: UISlider) {
        showMovieBar()
        isSeeking = false
        let timeToSeek = Int32(sender.value)
        print(timeToSeek)
        let timeWillSeek = timeToSeek - mediaPlayer.time.intValue/1000
        print(timeWillSeek)
        if timeWillSeek > 0 {
            self.mediaPlayer.jumpForward(timeWillSeek)
        } else {
            self.mediaPlayer.jumpBackward(-timeWillSeek)
        }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
            self.seekingTime.isHidden = true
            self.hideMovieBar()
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}


extension MoviePlayerViewController: VLCMediaPlayerDelegate {
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        if mediaPlayer.state == .stopped {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        
        if !isSeeking {
            let miniSecond = self.mediaPlayer.time.intValue
            let second = miniSecond / 100
            let checkSecond = miniSecond / 1000 * 10 + 7
            if second >= checkSecond {
                self.movieProgress.value = Float(self.mediaPlayer.time.intValue / 1000)
                self.currentTime.text = self.mediaPlayer.time.stringValue
                self.remainingTime.text = self.mediaPlayer.remainingTime.stringValue
            }
        }
        
        
        
        if !maxTimeDidSet {
            if let sub = subURL {
                self.mediaPlayer.addPlaybackSlave(sub, type: .subtitle, enforce: true)
            }
            print(VLCMediaTracksInformationSourceAspectRatio)
            loadingIndicator.stopAnimating()
            movieTitle.text = mediaTitle
            self.movieProgress.maximumValue = Float(mediaPlayer.media.length.intValue / 1000)
            maxTimeDidSet = true
        }
    }
    
}

extension MoviePlayerViewController: SubtitleManagerDelegate {
    func selectedSubtitle(url: String) {
        print("delegate 1")
        let subtitleURL: URL = URL(fileURLWithPath: url)
        self.mediaPlayer.addPlaybackSlave(subtitleURL, type: .subtitle, enforce: true)
    }
}
