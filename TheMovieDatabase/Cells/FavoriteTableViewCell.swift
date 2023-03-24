//
//  FavoriteTableViewCell.swift
//  TheMovieDatabase
//
//  Created by Владимир Скрипченко on 14.03.2023.
//

import Foundation
import UIKit
import Alamofire

protocol FavoriteTableViewCellDelegate: AnyObject {
    func didCellPressed(cell: FavoriteTableViewCell, media: Movie)
}

class FavoriteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var overviewText: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageViewFavorite: UIImageView!
    
    weak var delegate: FavoriteTableViewCellDelegate?
    
    var resultFavorite: Movie? {
        didSet {
            guard let result = resultFavorite else { return }
            overviewText.text = result.overview
            nameLabel.text = "\(result.name) + \(result.title)"
            
            guard result.posterPath != nil else { return }
            let favoriteImageURL = "https://image.tmdb.org/t/p/w500\(self.resultFavorite?.posterPath ?? "")"
            AF.request(favoriteImageURL).response { response in
                guard let data = response.data, let image = UIImage(data: data) else { return }
                self.imageViewFavorite.image = image
            }
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
}

extension UINavigationController {
    
    var rootedViewController: UINavigationController? {
        return viewControllers.first as? UINavigationController
    }
}


