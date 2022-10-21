import Foundation
import UIKit
import SwiftyStoreKit
import StoreKit

protocol InAppPurchaseDelegate: AnyObject {
  func restoreDidSucceed()
  func purchaseDidSucceed()
  func nothingToRestore()
  func paymentCancelled()
  func unknowErrorOccur()
  func returnProduct(product: SKProduct)
}

class IAPHelper {
  weak var delegate: InAppPurchaseDelegate?
  var selectedProductID = monthlySubscriptionId
                                               
  func getIAPlocalPrice(){
    SwiftyStoreKit.retrieveProductsInfo(subscriptionPlansId) { [self] result in
      let products = result.retrievedProducts
      for product in products {
        delegate?.returnProduct(product: product)
      }
    }
  }
    
  func restorePurchase() {
    SwiftyStoreKit.restorePurchases(atomically: true) { [self] results in
      if results.restoreFailedPurchases.count > 0 {
        print("Restore Failed: \(results.restoreFailedPurchases)")
      }
      else if results.restoredPurchases.count > 0 {
        print("Restore Success: \(results.restoredPurchases)")
        delegate?.restoreDidSucceed()
      }
      else {
        // Nothing to restore
        delegate?.nothingToRestore()
      }
    }
  }
    
  func purchase() {
    SwiftyStoreKit.purchaseProduct(selectedProductID, quantity: 1, atomically: true) { [self] result in
      switch result {
      case .success:
        self.validateSubscription()
      case .error(let error):
        switch error.code {
        case .unknown:
          delegate?.unknowErrorOccur()
        case .clientInvalid: print("Not allowed to make the payment")
        case .paymentCancelled:
          delegate?.paymentCancelled()
        case .paymentInvalid: print("The purchase identifier was invalid")
        case .paymentNotAllowed: print("The device is not allowed to make the payment")
        case .storeProductNotAvailable: print("The product is not available in the current storefront")
        case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
        case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
        case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
        default: print((error as NSError).localizedDescription)
        }
      }
    }
  }
    
  func validateSubscription() {
    let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
    SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
      switch result {
      case .success(let receipt):
        let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: self.selectedProductID, inReceipt: receipt)
        switch purchaseResult {
        case .purchased(let expiryDate, let items):
          print("Items",items)
          print("\(items) is valid until \(expiryDate)\n\(items)\n")
            PurchaseStatusUserDefualt.value = 1
          self.delegate?.purchaseDidSucceed()
        case .expired(let expiryDate, let items):
            PurchaseStatusUserDefualt.value = 2
          print("\(items) is expired since \(expiryDate)\n\(items)\n")
//          DispatchQueue.main.async {
//            NotificationCenter.default.post(name: .SubscriptionStatusUpdated, object: nil)
//          }
        case .notPurchased:
          print("The user has never purchased")
            PurchaseStatusUserDefualt.value = 0
//          DispatchQueue.main.async {
//            NotificationCenter.default.post(name: .SubscriptionStatusUpdated, object: nil)
//          }
        }
      case .error(let error):
        print("Receipt verification failed: \(error)")
      }
    }
  }
}
