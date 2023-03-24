//
//  SearchResultTableViewCell.swift
//  TheMovieDatabase
//
//  Created by Владимир Скрипченко on 25.02.2023.
//


import UIKit
import Alamofire

protocol SearchResultTableViewCellDelegate: AnyObject {
    func didCellPressed(cell: SearchResultTableViewCell, media: Movie)
}

class SearchResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var overviewText: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    
    var result: Movie? {
        didSet {
            guard let result = result else { return }
            overviewText.text = result.overview
            nameLabel.text = "\(result.name) + \(result.title)"
            
            guard result.posterPath != nil else { return }
            let logoImageURL = "https://image.tmdb.org/t/p/w500\(self.result?.posterPath ?? "")"
            AF.request(logoImageURL).response { response in
                guard let data = response.data, let image = UIImage(data: data) else { return }
                self.logoImageView.image = image
            }
        }
    }
    
    weak var delegate: SearchResultTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        overviewText.isEditable = false
        overviewText.isScrollEnabled = false
    }
   
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
}

extension UINavigationController {
    
    var rootsViewController: UINavigationController? {
        return viewControllers.first as? UINavigationController
    }
}
