//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 17.07.2024.
//

import UIKit

final class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackersViewController = TrackerViewController()
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "tracker_active"),
            selectedImage: nil
        )
        
        let statsViewController = StatsViewController()
        statsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "statistics_active"),
            selectedImage: nil
        )
        
        self.viewControllers = [trackersNavigationController, statsViewController]
        
        addTabBarBorder()
    }
    
    private func addTabBarBorder() {
        let border = UIView()
        border.backgroundColor = .lightGray
        border.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(border)
        
        NSLayoutConstraint.activate([
            border.topAnchor.constraint(equalTo: tabBar.topAnchor),
            border.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            border.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
