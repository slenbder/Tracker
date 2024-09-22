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

        func testViewController() {
            let vc = TrackerViewController()
            assertSnapshot(matching: vc, as: .image)
        }
}
