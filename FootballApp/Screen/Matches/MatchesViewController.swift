//
//  MatchesViewController.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/21/23.
//

import UIKit
import SnapKit
import Combine
import AVKit
import Reachability

final class MatchesViewController: UIViewController {
    private let loadTrigger = PassthroughSubject<Void, Never>()
    private let selectedTeams = CurrentValueSubject<[String], Never>([])
    private var isReachable = PassthroughSubject<Bool, Never>()
    
    typealias DataSource = UICollectionViewDiffableDataSource<MatchesSection, MatchItemViewModel>
    private lazy var dataSource = makeDataSource()
    private var cancellables: Set<AnyCancellable> = []
    
    private let reachability = try! Reachability()
    var viewModel: MatchesViewModel
    
    // MARK: - UI properties
    private lazy var indicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.hidesWhenStopped = true
        return view
    }()
    
    private lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        return flowLayout
    }()
    
    private lazy var collectionLayout: UICollectionViewCompositionalLayout = {
        return UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemCount = 2
            let size = NSCollectionLayoutSize(
                widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
                heightDimension: NSCollectionLayoutDimension.absolute(180)
            )
            let item = NSCollectionLayoutItem(layoutSize: size)
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: itemCount)
            group.interItemSpacing = NSCollectionLayoutSpacing.fixed(10)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 40, trailing: 10)
            section.interGroupSpacing = 10
            
            // Supplementary header view setup
            let headerFooterSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(20)
            )
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerFooterSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
        })
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.register(MatchCollectionViewCell.self, forCellWithReuseIdentifier: MatchCollectionViewCell.reuseIdentifier)
        collectionView.register(SectionHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderReusableView.reuseIdentifier)
        collectionView.collectionViewLayout = collectionLayout
        
        return collectionView
    }()
    
    // MARK: - Initialization
    init(viewModel: MatchesViewModel = MatchesViewModel()) {
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
        loadData()
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    // MARK: - UI setup
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(indicator)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        indicator.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        addRightBarButton()
    }
    
    private func addRightBarButton() {
        let rightButton = UIButton(type: .system)
        rightButton.snp.makeConstraints { make in
            make.size.equalTo(30.0)
        }
        rightButton.setImage(UIImage(named: "filter"), for: .normal)
        rightButton.tintColor = .black
        rightButton.addTarget(self, action: #selector(onTouchRightBarButton), for: .touchUpInside)
        let rightButtonItem = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = rightButtonItem
    }
    
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, cellItem) ->
                UICollectionViewCell? in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MatchCollectionViewCell.reuseIdentifier, for: indexPath) as? MatchCollectionViewCell else {
                    fatalError("Can not dequeue cell")
                }
                cell.configure(with: cellItem)
                return cell
            })
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }
            let section = self.dataSource.snapshot()
                .sectionIdentifiers[indexPath.section]
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeaderReusableView.reuseIdentifier,
                for: indexPath) as? SectionHeaderReusableView
            view?.titleLabel.text = section.title
            return view
        }
        return dataSource
    }
    
    private func loadData() {
        loadTrigger.send(())
    }
    
    // MARK: - Actions
    @objc private func onTouchRightBarButton() {
        showTeamsScreen()
    }
    
    private func showTeamsScreen() {
        let viewModel = TeamsViewModel()
        let viewController = TeamsViewController(viewModel: viewModel, selectedTeams: selectedTeams.value)
        viewController.delegate = self
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    private func showFullScreenVideo(_ url: URL) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
        }
    }
}

// MARK: - Bindable
extension MatchesViewController: Bindable {
    func bindViewModel() {
        reachability.isReachable
            .sink { [isReachable] reachable in
                isReachable.send(reachable)
            }
            .store(in: &cancellables)
        
        let input = MatchesViewModel.Input(loadTrigger: loadTrigger, selectedTeams: selectedTeams, isReachable: isReachable)
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
            .sink { [collectionView, dataSource] snapshot in
                dataSource.apply(snapshot)
                collectionView.setContentOffset(.zero, animated: false)
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

// MARK: - UICollectionViewDataSource Implementation
extension MatchesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath),
              let urlString = item.highlights,
              let url = URL(string: urlString) else {
            return
        }
        showFullScreenVideo(url)
    }
}

// MARK: TeamsViewControllerDelegate
extension MatchesViewController: TeamsViewControllerDelegate {
    func didSelectTeams(_ teams: [String]) {
        selectedTeams.send(teams)
    }
}
