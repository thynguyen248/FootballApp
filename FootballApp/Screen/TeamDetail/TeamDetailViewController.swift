//
//  TeamDetailViewController.swift
//  FootballApp
//
//  Created by Thy Nguyen on 3/26/23.
//

import UIKit

final class TeamDetailViewController: UIViewController {
    var viewModel: TeamDetailViewModel
    
    init(viewModel: TeamDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        navigationItem.title = viewModel.title
    }
}
