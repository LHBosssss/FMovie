//
//  CategoryManager.swift
//  FMovie
//
//  Created by Ho Duy Luong on 4/21/20.
//  Copyright © 2020 Ho Duy Luong. All rights reserved.
//

import Foundation

class CategoryManager {
    
    let mainMenuArray = [
        [
            "title" : "Đề Xuất",
            "genre" : "feed",
        ],
        [
            "title" : "Phim Hot" ,
            "genre" : "hot",
        ],
        [
            "title" : "Phim Mới",
            "genre" : "phim",
        ],
        [
            "title" : "Thuyết Minh",
            "genre" : "thuyet-minh-tieng-viet",
        ],
        [
            "title" : "Phim Lẻ",
            "genre" : "phim-le",
        ],
        [
            "title" : "Phim Bộ",
            "genre" : "series",
        ],
        [
            "title" : "Tìm Kiếm",
            "genre" : "phim",
        ]
    ]
    
    private let subMenuArray = [
        "phim-le" : [
            [
                "title" : "Hành Động",
                "genre" : "action",
            ],
            [
                "title" : "Chiến Tranh" ,
                "genre" : "war",
            ],
            [
                "title" : "Viễn Tưởng",
                "genre" : "sci-fi",
            ],
            [
                "title" : "Kinh Dị" ,
                "genre" : "horror",
            ],
            [
                "title" : "Võ Thuật",
                "genre" : "vo-thuat-phim-2",
            ],
            [
                "title" : "Trung Quốc",
                "genre" : "trung-quoc-series",
            ],
            [
                "title" : "Cổ Trang",
                "genre" : "co-trang-phim",
            ],
            [
                "title" : "Tình Cảm",
                "genre" : "tinh-cam",
            ],
            [
                "title" : "Hoạt Hình",
                "genre" : "animation",
            ],
            [
                "title" : "Hài",
                "genre" : "comedy",
            ],
            [
                "title" : "Hình Sự",
                "genre" : "crime"
            ]
        ],
        "series" : [
            [
                "title" : "Hàn Quốc",
                "genre" : "korean-series",
            ],
            [
                "title" : "Trung Quốc",
                "genre" : "phim-bo-trung-quoc",
            ],
            [
                "title" : "Đài Loan",
                "genre" : "phim-bo-dai-loan",
            ],
            [
                "title" : "Mỹ",
                "genre" : "us-tv-series",
            ],
            [
                "title" : "Hồng Kông",
                "genre" : "hongkong-series",
            ],
            [
                "title" : "Ấn Độ",
                "genre" : "phim-bo-an-do",
            ],
            [
                "title" : "Thái Lan",
                "genre" : "phim-bo-thai-lan",
            ]
        ]
    ]
    
    // MARK: - Fetch Main Menu
    func fetchMainMenu() -> [[String : String]] {
        return mainMenuArray
    }
    
    func fetchSubMenu(category: String) -> [[String : String]] {
        print("Fetch Sub Menu")
        let sub = subMenuArray[category]
        return sub ?? []
    }
}
