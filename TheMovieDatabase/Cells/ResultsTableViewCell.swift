//
//  ResultsTableViewCell.swift
//  TheMovieDatabase
//
//  Created by Владимир Скрипченко on 03.02.2023.
//

import UIKit
import Alamofire

protocol ResultsTableViewCellDelegate: AnyObject {
    func didCellPressed(cell: ResultsTableViewCell, media: Movie)
}

var mediaType: MediaType = .movie

class ResultsTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var genre: Genre? {
        didSet {
            categoryName.text = genre?.name
            collectionView.reloadData()
            
            if genre != nil,
               ((genre?.name) != nil) {
                mediaType = .tv
            }
        }
    }

    var movies: [Movie] = []
    
    weak var delegate: ResultsTableViewCellDelegate?
 
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)

    }
}

extension UINavigationController {
    
    var rootViewController: UINavigationController? {
        return viewControllers.first as? UINavigationController
    }
}

extension ResultsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        movies.count 
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultCollectionViewCell", for: indexPath) as? ResultCollectionViewCell else { return UICollectionViewCell()
        }
        cell.movies = movies[indexPath.row]
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let media = movies[indexPath.row]
        
        switch mediaType {
        case .movie:
            delegate?.didCellPressed(cell: self, media: media)
        case .tv:
            delegate?.didCellPressed(cell: self, media: media)
        case .person:
            delegate?.didCellPressed(cell: self, media: media)
        }
        
    }
}
