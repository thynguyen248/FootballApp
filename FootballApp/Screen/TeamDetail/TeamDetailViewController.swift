//
//  TeamDetailViewController.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/26/23.
//

import UIKit
import Combine

final class TeamDetailViewController: UIViewController {
    private lazy var containerStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .top
        view.spacing = 10
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 10, right: 8)
        [nameLabel, totalInfoLabel, previousInfoLabel, upcomingInfoLabel].forEach {
            view.addArrangedSubview($0)
        }
        view.setCustomSpacing(32, after: nameLabel)
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemIndigo
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize, weight: .semibold)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private lazy var totalInfoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize, weight: .semibold)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private lazy var previousInfoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private lazy var upcomingInfoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    var viewModel: TeamDetailViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: TeamDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(containerStackView)
        containerStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - Bindable
extension TeamDetailViewController: Bindable {
    func bindViewModel() {
        let input = TeamDetailViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.$title
            .receive(on: RunLoop.main)
            .sink { [nameLabel] title in
                nameLabel.text = title
            }
            .store(in: &cancellables)
        
        output.$totalInfo
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [totalInfoLabel] info in
                totalInfoLabel.text = info
            }
            .store(in: &cancellables)
        
        output.$previousInfo
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [previousInfoLabel] info in
                previousInfoLabel.text = info
            }
            .store(in: &cancellables)
        
        output.$upcomingInfo
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [upcomingInfoLabel] info in
                upcomingInfoLabel.text = info
            }
            .store(in: &cancellables)
    }
}
