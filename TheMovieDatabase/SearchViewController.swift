//
//  SearchViewController.swift
//  TheMovieDatabase
//
//  Created by Владимир Скрипченко on 30.01.2023.
//

import UIKit
import Alamofire

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableViewSearch: UITableView!
    
    var movies: [Movie] = []
    var movieTest: [Results] = []
    var timer: Timer?
    
    weak var delegate: SearchResultTableViewCellDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
        self.tableViewSearch.dataSource = self
        self.tableViewSearch.delegate = self
    }
    
    func searchMovies(query: String) {
        let queryWithSpacesReplaced = query.replacingOccurrences(of: " ", with: "%20")
        let urlString = "https://api.themoviedb.org/3/search/multi?api_key=ed303f39f93f7741fce35dfeb5e6c02f&query=\(queryWithSpacesReplaced)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        AF.request(url, method: .get).responseDecodable(of: MoviesModel.self) { (response) in
            switch response.result {
            case .success(let result):
                if let results = result.results {
                    self.movies = results
                    DispatchQueue.main.async {
                        self.tableViewSearch.reloadData()
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            self?.searchMovies(query: searchText)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.movies = []
        self.tableViewSearch.reloadData()
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableViewCell", for: indexPath) as? SearchResultTableViewCell else { return UITableViewCell() }
        
        cell.result = movies[indexPath.row]
        cell.delegate = self
        let media = movies[indexPath.row]
        let title = media.title ?? media.name ?? "Unknown"
        cell.nameLabel.text = "\(title)"

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SearchResultTableViewCell, let media = cell.result else { return }
        
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

}

//MARK: -  and open detail Controller
extension SearchViewController: SearchResultTableViewCellDelegate {
    
    func didCellPressed(cell: SearchResultTableViewCell, media: Movie) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        viewController.movie = media
    }
}

