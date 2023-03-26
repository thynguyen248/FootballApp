//
//  TeamsViewController.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/26/23.
//

import UIKit
import Combine

final class TeamsViewController: UIViewController {
    private let loadTrigger = PassthroughSubject<Void, Never>()
    private let selectedTeams = CurrentValueSubject<[String], Never>([])
    
    typealias DataSource = UITableViewDiffableDataSource<TeamsSection, TeamItemViewModel>
    private lazy var dataSource = makeDataSource()
    private var cancellables: Set<AnyCancellable> = []

    var viewModel: TeamsViewModel
    weak var delegate: TeamsViewControllerDelegate?
    
    // MARK: - UI properties
    private lazy var indicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.hidesWhenStopped = true
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorColor = .gray
        tableView.register(TeamTableViewCell.self, forCellReuseIdentifier: TeamTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    private lazy var applyButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.snp.makeConstraints { make in
            make.height.equalTo(50.0)
        }
        button.setTitle("APPLY", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemIndigo
        button.addTarget(self, action: #selector(didTouchApply), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    init(viewModel: TeamsViewModel = TeamsViewModel(),
         selectedTeams: [String] = []) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        bindViewModel()
        self.selectedTeams.send(selectedTeams)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    // MARK: - UI setup
    private func setupUI() {
        navigationController?.configDefaultBarStyle()
        
        view.addSubview(tableView)
        view.addSubview(applyButton)
        view.addSubview(indicator)
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(applyButton.snp.top)
        }
        applyButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        indicator.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        addRightBarButton()
    }
    
    private func addRightBarButton() {
        let rightButton = UIButton(type: .system)
        rightButton.setTitle("Cancel", for: .normal)
        rightButton.tintColor = .black
        rightButton.addTarget(self, action: #selector(onTouchRightBarButton), for: .touchUpInside)
        let rightButtonItem = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = rightButtonItem
    }

    private func makeDataSource() -> DataSource {
        let dataSource = UITableViewDiffableDataSource<TeamsSection, TeamItemViewModel>(tableView: tableView) { (tableView, indexPath, cellItem) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TeamTableViewCell.reuseIdentifier, for: indexPath) as? TeamTableViewCell else {
                fatalError("Can not dequeue cell")
            }
            cell.configure(with: cellItem)
            cell.didSelectTeam = { [weak self] (team, isSelected) in
                isSelected ?
                self?.selectedTeams.value.append(team) :
                self?.selectedTeams.value.removeAll(where: { $0 == team })
            }
            return cell
        }
        return dataSource
    }
    
    private func loadData() {
        loadTrigger.send(())
    }
    
    //MARK: - Actions
    @objc private func onTouchRightBarButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTouchApply() {
        delegate?.didSelectTeams(selectedTeams.value)
        dismiss(animated: true)
    }
    
    private func showTeamDetailScreen(with item: TeamItemViewModel) {
        let viewModel = TeamDetailViewModel(teamName: item.name)
        let viewController = TeamDetailViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Bindable
extension TeamsViewController: Bindable {
    func bindViewModel() {
        let input = TeamsViewModel.Input(loadTrigger: loadTrigger, selectedTeams: selectedTeams)
        let output = viewModel.transform(input: input)
        
        output.$isLoading
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [indicator] isLoading in
                isLoading ? indicator.startAnimating() : indicator.stopAnimating()
            }
            .store(in: &cancellables)
        
        output.$snapShot
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [dataSource] snapshot in
                dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        output.$error
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                self?.showAlerWithMessage(error?.localizedDescription ?? "")
            }
            .store(in: &cancellables)
    }
}

//MARK: - UITableViewDelegate
extension TeamsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        showTeamDetailScreen(with: item)
    }
}

//MARK: - TeamsViewControllerDelegate
protocol TeamsViewControllerDelegate: AnyObject {
    func didSelectTeams(_ teams: [String])
}
