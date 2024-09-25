//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Кирилл Марьясов on 28.06.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testTrackerViewController() {
        let vc = TrackerViewController()
        assertSnapshot(of: vc, as: .image)
    }
    
    func testStatisticsViewController() {
        let vc = StatisticsViewController()
        assertSnapshot(of: vc, as: .image)
    }
}

