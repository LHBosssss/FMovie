//
//  MoviePlayerViewController.swift
//  FMovie
//
//  Created by Ho Duy Luong on 4/25/20.
//  Copyright © 2020 Ho Duy Luong. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class MoviePlayerViewController: UIViewController {

    var url = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        print(url)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func playButton(_ sender: UIButton) {
        guard let url = URL(string: url) else {return}
        
        let player = AVPlayer(url: url)
        let controller = AVPlayerViewController()
        print(url)

        controller.player = player
        controller.allowsPictureInPicturePlayback = true
        controller.entersFullScreenWhenPlaybackBegins = true
        controller.player?.play()
        present(controller, animated: true) 
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
