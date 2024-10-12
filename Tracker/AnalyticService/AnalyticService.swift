//
//  Untitled.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 22.09.2024.
//

import UIKit
import YandexMobileMetrica

struct AnalyticsService {
    static func activate() {
        let configuration = YMMYandexMetricaConfiguration(apiKey: Constants.YMMAPIKey)
        guard let validConfiguration = configuration else {
            print("Failed to create YMMYandexMetricaConfiguration")
            return
        }
        
        YMMYandexMetrica.activate(with: validConfiguration)
    }
    
    static func report(event: String, params: [AnyHashable: Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: \(error.localizedDescription)")
        })
    }
}

