//
//  MoviesViewController.swift
//  FMovie
//
//  Created by Ho Duy Luong on 4/20/20.
//  Copyright © 2020 Ho Duy Luong. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage

class MoviesListViewController: UIViewController {
    
    @IBOutlet weak var mainMenuCollection: UICollectionView!
    @IBOutlet weak var subMenuCollection: UICollectionView!
    @IBOutlet weak var moviesCollection: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backgroundImage: UIImageView!
    let categoryManager = CategoryManager()
    let moviesManager = MoviesManager()
    var mainMenu = CategoryManager().mainMenuArray
    var subMenu: [[String : String]] = []
    var movieItems = [JSON]()
    var currentCellIndex = 0
    var page = 1
    var isLoadingMore = false
    var loadedMore = false
    var isLastItem = false
    var genreToLoad = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Collection Data Source
        mainMenuCollection.dataSource = self
        subMenuCollection.dataSource = self
        moviesCollection.dataSource = self
        
        // Set Collection Delegate
        mainMenuCollection.delegate = self
        subMenuCollection.delegate = self
        moviesCollection.delegate = self
        
        
        // Set Movies Manager Delegate
        moviesManager.delegate = self
        
        // Set swipe Delegate
        // Set Data For First Run App
        updataDataForFirstRun()
        
    }
    
    // MARK: - Update Data After View Did Load
    func updataDataForFirstRun() {
        // Add Swipe
        let leftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeMade(_:)))
        let rightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeMade(_:)))
        let upRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeMade(_:)))
        let downRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeMade(_:)))
        leftRecognizer.direction = .left
        rightRecognizer.direction = .right
        upRecognizer.direction = .up
        downRecognizer.direction = .down
        self.moviesCollection.addGestureRecognizer(leftRecognizer)
        self.moviesCollection.addGestureRecognizer(rightRecognizer)
        self.moviesCollection.addGestureRecognizer(upRecognizer)
        self.moviesCollection.addGestureRecognizer(downRecognizer)
        //
        self.mainMenuCollection.backgroundColor = .none
        self.subMenuCollection.backgroundColor = .none
        self.mainMenuCollection.isHidden = false
        self.subMenuCollection.isHidden = true
        self.moviesCollection.backgroundColor = .none
        self.activityIndicator.layer.cornerRadius = 10
        self.activityIndicator.backgroundColor = UIColor.systemGray4
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
            self.mainMenuCollection.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .top)
            self.collectionView(self.mainMenuCollection, didSelectItemAt: IndexPath(item: 0, section: 0))
        }
    }
    
    // MARK: - Movie Select Animation
    func gotoTop(cell: MoviesCollectionViewCell) {
        DispatchQueue.main.async {
            if let pos = self.moviesCollection.indexPath(for: cell)?.item {
                let link = self.movieItems[pos]["image"].stringValue
                self.backgroundImage.sd_setImage(with: URL(string: link))
            }
        }
        cell.movieImage.layer.borderColor = UIColor.systemBackground.cgColor
        cell.movieImage.alpha = 1.0
        
        UIView.animate(withDuration: 0.15,
                       animations: {
                        cell.transform = CGAffineTransform(translationX: 0.0, y: -50.0)
        }){ (completed) in
            UIView.animate(withDuration: 0.2,
                           animations: {
                            self.backgroundImage.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                            
            })
        }
    }
    
    func gotoDefault(cell: MoviesCollectionViewCell) {
        cell.movieImage.layer.borderColor = UIColor.systemGray5.cgColor
        cell.movieImage.alpha = 0.5
        UIView.animate(withDuration: 0.2,
                       animations: {
                        cell.transform = .identity
                        self.backgroundImage.transform = .identity
        })
    }
    
    func hideMenuBar() {
        UIView.animate(withDuration: 0.3, animations: {
            self.mainMenuCollection.transform = CGAffineTransform(translationX: 0, y: -50)
            self.subMenuCollection.transform = CGAffineTransform(translationX: 0, y: -50)
            
            self.mainMenuCollection.alpha = 0.0
            self.subMenuCollection.alpha = 0.0
        }) { (completed) in
            
        }
    }
    
    func showMenuBar() {
        UIView.animate(withDuration: 0.3, animations: {
            self.mainMenuCollection.transform = CGAffineTransform(translationX: 0, y: 0)
            self.subMenuCollection.transform = CGAffineTransform(translationX: 0, y: 0)
            self.mainMenuCollection.alpha = 1.0
            self.subMenuCollection.alpha = 1.0
        }) { (completed) in
            
        }
    }
    // MARK: - Swipe Movie Collection
    @IBAction func swipeMade(_ sender: UISwipeGestureRecognizer) {
        hideMenuBar()
        let visibleCells = self.moviesCollection.visibleCells
        var nextCell = MoviesCollectionViewCell()
        
        if sender.direction == .left {
            print("Swipe RIGHT -> LEFT")
            //            print(visibleCells)
            if var max = visibleCells.last?.frame.midX {
                for cell in visibleCells {
                    //                    print(cell.frame.midX)
                    if cell.frame.midX >= max {
                        max = cell.frame.midX
                        nextCell = cell as! MoviesCollectionViewCell
                    }
                }
            }
            
            print(nextCell.movieTitleLabel.text)
            if let indexPath = self.moviesCollection.indexPath(for: nextCell) {
                gotoTop(cell: nextCell)
                currentCellIndex = indexPath.item
                self.moviesCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                for cell in visibleCells {
                    if cell != nextCell {
                        gotoDefault(cell: cell as! MoviesCollectionViewCell)
                    }
                }
                print("Is loading more = \(isLoadingMore)")
                print("Is last Item = \(isLastItem)")
                print("Is loaded more = \(loadedMore)")
                
                if indexPath.item == self.movieItems.count - 1 && genreToLoad != "hot"{
                    isLastItem = true
                    
                    if isLoadingMore && loadedMore && isLastItem {
                        self.page += 1
                        loadedMore = false
                        print("page = \(page)")
                        self.activityIndicator.isHidden = false
                        self.activityIndicator.startAnimating()
                        if genreToLoad == "feed" {
                            DispatchQueue.global(qos: .background).async {
                                self.moviesManager.getFeedMovies(page: self.page)
                                
                            }
                        }
                        else {
                            
                            DispatchQueue.global(qos: .userInitiated).async {
                                self.moviesManager.getGenreMovies(genre: self.genreToLoad, page: self.page)
                            }
                        }
                    }
                    
                    self.isLoadingMore = true
                }
            }
            
        }
        
        
        if sender.direction == .right {
            //            let visibleCells = self.moviesCollection.visibleCells
            print("Swipe LEFT -> RIGHT")
            print(visibleCells)
            //            var nextCell = MoviesCollectionViewCell()
            if var min = visibleCells.first?.frame.midX {
                for cell in visibleCells {
                    print(cell.frame.midX)
                    if cell.frame.midX <= min {
                        min = cell.frame.midX
                        nextCell = cell as! MoviesCollectionViewCell
                    }
                }
            }
            
            print(nextCell.movieTitleLabel.text)
            if let indexPath = self.moviesCollection.indexPath(for: nextCell) {
                gotoTop(cell: nextCell)
                currentCellIndex = indexPath.item
                self.moviesCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                for cell in visibleCells {
                    if cell != nextCell {
                        gotoDefault(cell: cell as! MoviesCollectionViewCell)
                    }
                }
            }
        }
        
        if sender.direction == .up {
            hideMenuBar()
            performSegue(withIdentifier: "gotoMovieDetail", sender: nil)
        }
        
        if sender.direction == .down {
            showMenuBar()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoMovieDetail" {
            let movieDetailView = segue.destination as! MovieDetailViewController
            movieDetailView.movieItem = movieItems[currentCellIndex]
        }
        
    }
    
    
}
// MARK: - Collection Data Source

extension MoviesListViewController: UICollectionViewDataSource {
    // MARK: - Number Of Item In Section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // MARK: - Number Of Main Menu Item
        if collectionView == self.mainMenuCollection {
            return mainMenu.count
        }
        
        // MARK: - Number Of Sub Menu Item
        if collectionView == self.subMenuCollection {
            return subMenu.count
        }
        // MARK: - Number Of Movies Item
        if collectionView == self.moviesCollection {
            return movieItems.count
        }
        return 0
    }
    
    // MARK: - Cell For Item In Collection At IndexPath
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // MARK: - Cell For Main Menu Collection
        if collectionView == self.mainMenuCollection {
            let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainMenuCell", for: indexPath) as! MainMenuCollectionViewCell
            // Set Cell Text
            menuCell.mainMenuCellLabel.text = mainMenu[indexPath.item]["title"]
            
            // Set Cell Style
            //            menuCell.layer.backgroundColor = UIColor.systemGray2.cgColor
            menuCell.backgroundColor = UIColor.systemGray2
            menuCell.layer.cornerRadius = 15
            
            if menuCell.isSelected {
                menuCell.backgroundColor = UIColor.systemBackground
            }
            return menuCell
        }
        
        // MARK: - Cell For Sub Menu Collection
        if collectionView == self.subMenuCollection {
            let submenuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubMenuCell", for: indexPath) as! SubMenuCollectionViewCell
            // Set Cell Text
            submenuCell.subMenuCellLabel.text = subMenu[indexPath.item]["title"]
            
            // Set Cell Border
            submenuCell.backgroundColor = UIColor.systemGray2
            submenuCell.layer.cornerRadius = 10
            
            if submenuCell.isSelected {
                submenuCell.backgroundColor = UIColor.systemBackground
            }
            return submenuCell
        }
        
        // MARK: - Cell For Movies Collection
        if collectionView == self.moviesCollection {
            let movieCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MoviesCollectionViewCell
            let movieItem = movieItems[indexPath.item]
            // Set Cell Text
            let movieRawTitle = movieItem["title"].stringValue
            let movieTitleArray = movieRawTitle.split(separator: "&")
            let movieTitleFinal = String(movieTitleArray.first!)
            movieCell.movieTitleLabel.text = movieTitleFinal
            // Set Cell Image
            DispatchQueue.main.async {
                movieCell.movieImage.sd_setImage(with: URL(string: movieItem["image"].stringValue))
            }
            movieCell.movieImage.layer.borderColor = UIColor.systemGray5.cgColor
            movieCell.movieImage.layer.borderWidth = 30
            movieCell.movieImage.alpha = 0.5
            movieCell.movieImage.layer.cornerRadius = movieCell.movieImage.frame.width/5
            
            return movieCell
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "SubMenuCell", for: indexPath)
    }
}

// MARK:- Collection View Delegate
extension MoviesListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Did Select Main Menu Item
        
        if collectionView != self.moviesCollection {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            isLoadingMore = false
            loadedMore = true
            isLastItem = false
            page = 1
            print("Reset Data To Load")
        }
        
        // MARK: - Did Select Main Menu
        if collectionView == self.mainMenuCollection {
            print("Selected mainmenu")
            currentCellIndex = 0

            if let cell = mainMenuCollection.cellForItem(at: indexPath) as? MainMenuCollectionViewCell {
                // Load Movies
                print(indexPath.item)
                if let genre = mainMenu[indexPath.item]["genre"] {
                    self.genreToLoad = genre
                    if genre == "phim-le" || genre == "series" {
                        DispatchQueue.main.async {
                            self.subMenu = self.categoryManager.fetchSubMenu(category: genre)
                            self.subMenuCollection.reloadData()
                            self.subMenuCollection.isHidden = false
                        }
                    } else {
                        self.subMenuCollection.isHidden = true
                    }
                    if genre == "feed" {
                        DispatchQueue.global(qos: .userInitiated).async {
                            self.moviesManager.getFeedMovies(page: self.page)
                        }
                    } else {
                        DispatchQueue.global(qos: .background).async {
                            self.moviesManager.getGenreMovies(genre: genre, page: self.page)
                        }
                        
                    }
                    menuSelectAnimation(cell: cell, type: "main")
                    cell.layer.backgroundColor = UIColor.systemBackground.cgColor
                    cell.alpha = 1.0
                    cell.layer.borderColor = UIColor.systemGray.cgColor
                    cell.layer.borderWidth = 1.0
                }
            }
        }
        
        
        // MARK: - Did Select Sub Menu
        if collectionView == self.subMenuCollection {
            // Run Animation
            if let cell = collectionView.cellForItem(at: indexPath) as? SubMenuCollectionViewCell{
                menuSelectAnimation(cell: cell, type: "sub")
                cell.layer.backgroundColor = UIColor.systemBackground.cgColor
                cell.alpha = 1.0
                cell.layer.borderColor = UIColor.systemGray.cgColor
                cell.layer.borderWidth = 0.5
            }
            // Load Movies
            currentCellIndex = 0
            if let genre = subMenu[indexPath.item]["genre"] {
                self.genreToLoad = genre
                DispatchQueue.global(qos: .background).async {
                    self.moviesManager.getGenreMovies(genre: genre, page: self.page)
                }
            }
            
        }
        
        // MARK: - Did Select Movie Cell
        if collectionView == self.moviesCollection {
            print("Delegate selected movie cell at: \(indexPath.item)")
            let visibles = self.moviesCollection.visibleCells
            for visible in visibles {
                let cell = visible as! MoviesCollectionViewCell
                print("Visible Cells \(cell.movieTitleLabel)")
            }
        }
    }
    
    
    // MARK: - Did Deselect Cell
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // MARK: - Did Deselect Main Menu
        if collectionView == self.mainMenuCollection {
            if let cell = mainMenuCollection.cellForItem(at: indexPath) as? MainMenuCollectionViewCell {
                subMenuCollection.isHidden = true
                cell.backgroundColor = UIColor.systemGray2
            }
        }
        
        // MARK: - Did Deselect Sub Menu
        if collectionView == self.subMenuCollection {
            // Run Animation
            if let cell = subMenuCollection.cellForItem(at: indexPath) as? SubMenuCollectionViewCell{
                cell.backgroundColor = UIColor.systemGray2
            }
        }
        
        // MARK: - Did Deselect Movie Cell
        if collectionView == self.moviesCollection {
            //            print("Delegate DEselected movie cell at: \(indexPath.item)")
            let visibles = self.moviesCollection.visibleCells
            for visible in visibles {
                let cell = visible as! MoviesCollectionViewCell
                //                print("Visible Cells \(cell.movieTitleLabel)")
            }
        }
        
    }
    
    // MARK: - Menu Select Animation
    func menuSelectAnimation(cell: UICollectionViewCell, type: String) {
        var scale: CGFloat
        if type == "main" {
            scale = 1.15
        } else {
            scale = 1.05
        }
        UIView.animate(withDuration: 0.1,
                       animations: {
                        //Fade-out
                        cell.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
        { (completed) in
            UIView.animate(withDuration: 0.1,
                           animations: {
                            //Fade-out
                            cell.transform = CGAffineTransform.identity
            })
        }
    }
    
    
}


// MARK: - Movies Manager Delegate

extension MoviesListViewController: MoviesManagerDelegate {
    
    // MARK: - Get Movie Success
    func getMoviesSuccess(listMovies: JSON) {
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
        let newMoviesArray = listMovies.arrayValue
        
        print("Is loading more = \(isLoadingMore)")
        print("Is last Item = \(isLastItem)")
        print("Is loaded more = \(loadedMore)")
        
        loadedMore = true
        if !isLoadingMore {
            print("No loadingmore")
            movieItems.removeAll()
        }
        
        movieItems.append(contentsOf: newMoviesArray)
        self.moviesCollection.reloadData()
        
        if !isLoadingMore {
            print("Loadded new item")
            
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
                self.moviesCollection.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                    if let firstCell = self.moviesCollection.cellForItem(at: IndexPath(item: 0, section: 0)) {
                        print("Go to Top")
                        self.gotoTop(cell: firstCell as! MoviesCollectionViewCell)
                    }
                }
            }
        } else {
            isLoadingMore = false
            isLastItem = false
            print("Loadded more item")
            print("Sum = \(movieItems.count)")
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
                let newPosition = self.movieItems.count - newMoviesArray.count
                self.moviesCollection.scrollToItem(at: IndexPath(item: newPosition, section: 0), at: .centeredHorizontally, animated: false)
                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
                    if let cellToShow = self.moviesCollection.cellForItem(at: IndexPath(item: newPosition, section: 0)) {
                        print("Go to Top")
                        self.gotoTop(cell: cellToShow as! MoviesCollectionViewCell)
                    }
                }
            }
        }
    }
    
    // MARK: - Get Movie Failed
    func getMoviesFailed() {
        let alert = UIAlertController(title: "Tải dữ liệu thất bại", message: "Không thể tải dữ liệu! Vui lòng kiểm tra lại mạng.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

extension MoviesListViewController: UIScrollViewDelegate {
    
}
