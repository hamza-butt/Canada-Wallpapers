//
//  SceneDelegate.swift
//  WallPaperApp
//
//  Created by Mitesh's MAC on 20/12/19.
//  Copyright © 2019 Mitesh's MAC. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import GoogleMobileAds

class SceneDelegate: UIResponder, UIWindowSceneDelegate, GADFullScreenContentDelegate {
    
    var window: UIWindow?
    var appOpenAd: GADAppOpenAd?
    
    func requestAppOpenAd() {
        let request = GADRequest()
        GADAppOpenAd.load(
            withAdUnitID: AppDelegate.APP_OPEN_AD_ID,
            request: request,
            orientation: UIInterfaceOrientation.portrait,
            completionHandler: { (appOpenAdIn, _) in
                self.appOpenAd = appOpenAdIn
                self.appOpenAd?.fullScreenContentDelegate = self
                print("Ad is ready")
                self.tryToPresentAd()
            })
    }
    
    func tryToPresentAd() {
        if let gOpenAd = self.appOpenAd, let rwc = UIApplication.shared.windows.last?.rootViewController {
            gOpenAd.present(fromRootViewController: rwc)
        } else {
            self.requestAppOpenAd()
        }
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        requestAppOpenAd()
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        self.window?.overrideUserInterfaceStyle = .light
        
        if UserDefaults.standard.value(forKey: UD_userId) == nil || UserDefaults.standard.value(forKey: UD_userId) as! String == "" || UserDefaults.standard.value(forKey: UD_userId) as! String == "N/A" {
            PurchaseStatusUserDefualt.value = 0
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let objVC = storyBoard.instantiateViewController(withIdentifier: "WelcomeVC") as! WelcomeVC
            let nav : UINavigationController = UINavigationController(rootViewController: objVC)
            nav.navigationBar.isHidden = true
            self.window?.rootViewController = nav
        }
        else {
            
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let objVC = storyBoard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            let sideMenuViewController = storyBoard.instantiateViewController(withIdentifier: "BubbleTabBarController")
            let appNavigation: UINavigationController = UINavigationController(rootViewController: objVC)
            appNavigation.setNavigationBarHidden(true, animated: true)
            self.window?.rootViewController = sideMenuViewController
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        self.tryToPresentAd()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
}

