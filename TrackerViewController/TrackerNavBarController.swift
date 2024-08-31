//
//  TrackerNavBarController.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 17.07.2024.
//

import UIKit

class TrackerNavBarController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackerViewController = TrackerViewController()
        self.viewControllers = [trackerViewController]
    }
}
