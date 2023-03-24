//
//  FavoritesViewController.swift
//  TheMovieDatabase
//
//  Created by Владимир Скрипченко on 01.01.2023.
//

import UIKit
import Alamofire

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var favoriteTableView: UITableView!
    var favorites: [Movie] = []
    
    weak var delegate: FavoriteTableViewCellDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoriteTableView.dataSource = self
        favoriteTableView.delegate = self
        favoriteTableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }
    
    func loadFavorites() {
        favorites = PersistenceManager.shared.getFavorites()
        favoriteTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as? FavoriteTableViewCell else { return UITableViewCell() }
        
        cell.resultFavorite = favorites[indexPath.row]
        cell.delegate = self
        let favorite = favorites[indexPath.row]
        cell.overviewText.text = favorite.overview
        cell.nameLabel.text = favorite.name ?? favorite.title
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FavoriteTableViewCell, let media = cell.resultFavorite else { return }
        
        if media.mediaType == .movie {
           
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            viewController.movie = media
            navigationController?.pushViewController(viewController, animated: true)
            
        } else if media.mediaType == .tv {
         
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            viewController.tv = media
            navigationController?.pushViewController(viewController, animated: true)
        }
        
        cell.delegate?.didCellPressed(cell: cell, media: media)
    }


    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            PersistenceManager.shared.removeFavorite(favorites[indexPath.row])
            favorites.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
extension FavoritesViewController: FavoriteTableViewCellDelegate {
    
    func didCellPressed(cell: FavoriteTableViewCell, media: Movie) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        viewController.movie = media
    }
}
