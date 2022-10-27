//
//  AppDelegate.swift
//  WallPaperApp
//
//  Created by Mitesh's MAC on 20/12/19.
//  Copyright © 2019 Mitesh's MAC. All rights reserved.
//

import UIKit
import OneSignal
import CoreData
import GoogleMobileAds
import IQKeyboardManagerSwift
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import AppTrackingTransparency
import SwiftyStoreKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    //public static let FB_NATIVE_AD_ID: String = "456834189087408_456834665754027"
    //public static let FB_INTERSTITIAL_AD_ID: String = "456834189087408_456835352420625"
    public static let APP_OPEN_AD_ID: String = "ca-app-pub-129912/7019109429"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Thread.sleep(forTimeInterval: 3.0)
        
        IQKeyboardManager.shared.enable = true
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        FirebaseApp.configure()
        FirebaseApp.debugDescription()
        Messaging.messaging().delegate = self
        requestPushNotificationPermission()
        setupOneSignal()
        
        // in app purchasing
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
          for purchase in purchases {
            print(purchase)
            switch purchase.transaction.transactionState {
            case .purchased, .restored:
              if purchase.needsFinishTransaction {
                SwiftyStoreKit.finishTransaction(purchase.transaction)
              }
            case .failed, .purchasing, .deferred:
              break
            }
          }
        }
        checkIfPurchaed()
        
        return true
    }
    
    private func requestPushNotificationPermission() {
      let center = UNUserNotificationCenter.current()
      UNUserNotificationCenter.current().delegate = self
      center.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: { (granted, error) in
          if #available(iOS 14.0, *) {
              DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                  ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                      // Tracking authorization completed. Start loading ads here.
                      // loadAd()
                  })
              })
          }})
      UIApplication.shared.registerForRemoteNotifications()
  }
    
    
    func checkIfPurchaed () {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
          switch result {
          case .success(let receipt):
            let purchaseResult = SwiftyStoreKit.verifySubscriptions(
              ofType: .autoRenewable,
              productIds: subscriptionPlansId,
              inReceipt: receipt)
            switch purchaseResult {
            case .purchased(let expiryDate, let items):
              print("\(items) is valid until \(expiryDate)\n\(items)\n")
                PurchaseStatusUserDefualt.value = 1
            case .expired(let expiryDate, let items):
                PurchaseStatusUserDefualt.value = 2
              print("\(items) is expired since \(expiryDate)\n\(items)\n")
            case .notPurchased:
              print("The user has never purchased")
                PurchaseStatusUserDefualt.value = 0
            }
          case .error(let error):
            print("Receipt verification failed: \(error)")
          }
        }
      }
    
    
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print(deviceTokenString)
        Messaging.messaging().apnsToken = deviceToken as Data
    }
    
    func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    
    private func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }
    
    
    private func setupOneSignal() {
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        OneSignal.initWithLaunchOptions(nil)
        OneSignal.setAppId(OneSignalKey)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            OneSignal.promptForPushNotifications(userResponse: { accepted in
                print("User accepted notifications: \(accepted)")
            })
        }
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        let dataDict:[String: String] = ["token": fcmToken]
        UserDefaultManager.setStringToUserDefaults(value:fcmToken, key:UD_FcmToken)
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        print("user clicked on the notification")
        let userInfo = response.notification.request.content.userInfo
        reveivedNotification(notification: userInfo as! [String : AnyObject])
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("userInfo: \(userInfo.debugDescription)")
        reveivedNotification(notification: userInfo as! [String : AnyObject])
    }
    
    func reveivedNotification(notification: [String:AnyObject]) {
        print(notification)
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "WallPaperApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

