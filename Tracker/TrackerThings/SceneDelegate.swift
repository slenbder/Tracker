//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 28.06.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    // MARK: - UIScene Lifecycle
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        if hasSeenOnboarding {
            window?.rootViewController = TabBarController()
        } else {
            window?.rootViewController = OnboardingViewController()
        }
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Этот метод вызывается, когда сцена отсоединяется от приложения
        // Освободите любые ресурсы, которые могут быть связаны с этой сценой
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Восстановите активные задачи, приостановленные при переходе в фоновый режим или при отсутствии активной сцены
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Приостанавливайте активные задачи, когда сцена переходит в состояние неактивности (например, при получении звонка)
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Этот метод вызывается при возврате сцены на передний план, используйте его для обновления пользовательского интерфейса
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Этот метод вызывается при переходе сцены в фоновый режим
        // Сохраняйте данные с помощью saveContext из AppDelegate при необходимости
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

