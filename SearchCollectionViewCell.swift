//
//  SearchCollectionViewCell.swift
//  MovieDB-CSS214
//
//  Created by Zhanserik Aldibay on 08.11.2025.
//

import UIKit
import SnapKit

class SearchCollectionViewCell: UICollectionViewCell {
    static let reuseId = "SearchCollectionViewCell"

    private let posterImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.numberOfLines = 2
        l.textAlignment = .center
        return l
    }()

    private let ratingBadge: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .bold)
        l.textAlignment = .center
        l.layer.cornerRadius = 12
        l.clipsToBounds = true
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(ratingBadge)

        posterImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(posterImageView.snp.width).multipliedBy(1.45) 
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(4)
            make.bottom.lessThanOrEqualToSuperview().offset(-4)
        }
        ratingBadge.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(8)
            make.width.greaterThanOrEqualTo(36)
            make.height.equalTo(24)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        titleLabel.text = nil
        ratingBadge.text = nil
        ratingBadge.backgroundColor = nil
        ratingBadge.textColor = nil
    }

    func configure(with result: Result) {
        titleLabel.text = result.title ?? "No title"
        if let vote = result.voteAverage {
            ratingBadge.text = String(format: "%.1f", vote)
            applyBadgeStyle(rating: vote)
        } else {
            ratingBadge.text = "-"
            ratingBadge.backgroundColor = .systemGray
            ratingBadge.textColor = .white
        }

        if let poster = result.posterPath {
            NetworkManager.shared.loadImage(posterPath: poster) { data in
                DispatchQueue.main.async {
                    self.posterImageView.image = UIImage(data: data)
                }
            }
        } else {
            posterImageView.image = nil
        }
    }

    private func applyBadgeStyle(rating: Double) {
        let bg: UIColor
        if rating < 5.0 {
            bg = .systemRed
        } else if rating < 7.0 {
            bg = .systemGray
        } else if rating < 8.0 {
            bg = .systemGreen
        } else {
            bg = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        }
        ratingBadge.backgroundColor = bg
        ratingBadge.textColor = rating < 8.0 ? .white : .black
    }
}
