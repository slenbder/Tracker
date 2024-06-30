//
//  StatsViewController.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 29.06.2024.
//

import UIKit

final class StatsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
    }
    
    private func configureBackground() {
        view.backgroundColor = UIColor(named: "ypWhite")
    }
}
