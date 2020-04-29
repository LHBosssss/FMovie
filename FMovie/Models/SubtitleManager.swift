//
//  SubtitleManager.swift
//  FMovie
//
//  Created by Ho Duy Luong on 4/28/20.
//  Copyright © 2020 Ho Duy Luong. All rights reserved.
//

import Foundation

protocol SubtitleManagerDelegate {
    func selectedSubtitle(url: String)
}

class SubtitleManager {
    var delegate: SubtitleManagerDelegate?
    var delegate2: SubtitleManagerDelegate?
    var delegate3: SubtitleManagerDelegate?

    var subtitleURL = ""
    
    func selected() {
        self.delegate?.selectedSubtitle(url: subtitleURL)
        self.delegate2?.selectedSubtitle(url: subtitleURL)
        self.delegate3?.selectedSubtitle(url: subtitleURL)

    }
}
