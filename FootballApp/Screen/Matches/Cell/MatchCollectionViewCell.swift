//
//  MatchCollectionViewCell.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/22/23.
//

import UIKit
import SnapKit

final class MatchCollectionViewCell: UICollectionViewCell, ReusableCell {
    private lazy var containerStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .top
        view.spacing = 5
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        [descriptionLabel, dateLabel, homeLabel, awayLabel].forEach {
            view.addArrangedSubview($0)
        }
        view.setCustomSpacing(8, after: descriptionLabel)
        return view
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .systemIndigo
        label.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()
    
    private lazy var homeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize)
        label.textColor = .gray
        return label
    }()
    
    private lazy var awayLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize)
        label.textColor = .gray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func makeUI() {
        contentView.addSubview(containerStackView)
        containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        backgroundColor = .systemGroupedBackground
    }

    func configure(with item: MatchItemViewModel?) {
        descriptionLabel.text = item?.description
        dateLabel.text = item?.date
        homeLabel.text = item?.home
        awayLabel.text = item?.away
    }
}
