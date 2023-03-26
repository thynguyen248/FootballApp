//
//  TeamTableViewCell.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/26/23.
//

import UIKit
import SnapKit
import Kingfisher

final class TeamTableViewCell: UITableViewCell, ReusableCell {
    private lazy var containerStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 20
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 8)
        [logo, nameLabel, selectButton].forEach {
            view.addArrangedSubview($0)
        }
        return view
    }()
    
    private lazy var logo: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .systemIndigo
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .semibold)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private lazy var selectButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.snp.makeConstraints { make in
            make.size.equalTo(40.0)
        }
        button.setImage(UIImage(named: "unchecked"), for: .normal)
        button.setImage(UIImage(named: "checked"), for: .selected)
        button.addTarget(self, action: #selector(didSelect), for: .touchUpInside)
        return button
    }()
    
    var didSelectTeam: ((_ team: String, _ isSelected: Bool) -> Void)?
    private var viewModel: TeamItemViewModel?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func makeUI() {
        selectionStyle = .none
        contentView.addSubview(containerStackView)
        containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func configure(with item: TeamItemViewModel?) {
        self.viewModel = item
        logo.kf.setImage(with: item?.logoUrl)
        nameLabel.text = item?.name
        selectButton.isSelected = item?.isSelected ?? false
    }
    
    @objc private func didSelect() {
        guard let name = viewModel?.name else { return }
        didSelectTeam?(name, !selectButton.isSelected)
    }
}
