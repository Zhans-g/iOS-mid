//
//  SearchViewController.swift
//  MovieDB-CSS214
//
//  Created by Zhanserik Aldibay on 08.11.2025.
//

import UIKit
import SnapKit

class SearchViewController: UIViewController {

    private var collectionView: UICollectionView!
    private let searchController = UISearchController(searchResultsController: nil)
    private var results: [Result] = []
    private var debounceTimer: Timer?

    private let sectionInset: CGFloat = 16
    private let spacing: CGFloat = 16

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Search"
        setupCollectionView()
        setupSearchController()
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.scrollDirection = .vertical

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: SearchCollectionViewCell.reuseId)
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupSearchController() {
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search movies"
        searchController.searchBar.delegate = self
        definesPresentationContext = true
    }

    private func performSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            self.results = []
            self.collectionView.reloadData()
            return
        }
        NetworkManager.shared.searchMovies(query: trimmed) { [weak self] res in
            self?.results = res
            self?.collectionView.reloadData()
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false, block: { [weak self] _ in
            self?.performSearch(searchText)
        })
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        performSearch(searchBar.text ?? "")
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = results[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.reuseId, for: indexPath) as! SearchCollectionViewCell
        cell.configure(with: item)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = results[indexPath.item]
        let detailVC = MovieDetailViewController()
        detailVC.movieID = movie.id ?? 0

        if let movieID = movie.id {
            NetworkManager.shared.loadVideo(movieID: movieID) { videos in
                let trailer = videos.first(where: { $0.type == "Trailer" }) ?? videos.first
                detailVC.trailerKey = trailer?.key
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(detailVC, animated: true)
                }
            }
        } else {
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = sectionInset * 2 + spacing
        let width = (collectionView.bounds.width - totalSpacing) / 2
        return CGSize(width: floor(width), height: floor(width * 1.6))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: sectionInset, left: sectionInset, bottom: sectionInset, right: sectionInset)
    }
}
