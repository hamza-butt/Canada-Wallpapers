//
//  SettingsVC.swift
//  WallPaperApp
//
//  Created by Mitesh's MAC on 11/02/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON
import StoreKit
import MBProgressHUD


class SettingsVC: UIViewController {
    
    //MARK: -  Outlets
    @IBOutlet weak var viewPrivacy: UIView!
    @IBOutlet weak var viewAbout: UIView!
    @IBOutlet weak var viewBuild: UIView!
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var priceBtn: UIButton!
    @IBOutlet weak var purchaseViewHeight: NSLayoutConstraint!
    
    
    var iAPHelper = IAPHelper()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewPrivacy.layer.cornerRadius = 5.0
        self.viewAbout.layer.cornerRadius = 5.0
        self.viewBuild.layer.cornerRadius = 5.0
        
        if #available( iOS 10.3,*){
        SKStoreReviewController.requestReview()
        }else{
            guard let url = URL(string: About_URL) else { return }
            UIApplication.shared.open(url)
        }
        
        updatePurchaseViewHeight()
        
        iAPHelper.getIAPlocalPrice()
        iAPHelper.delegate = self
        
    }
    
    
    func updatePurchaseViewHeight(){
        if PurchaseStatusUserDefualt.value == 1{
            purchaseViewHeight.constant = 0
        }else{
            purchaseViewHeight.constant = App.isRunningOnIpad ? 75 : 50
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    
    @IBAction func purchaseProTapped(_ sender: UIButton) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        self.iAPHelper.selectedProductID = monthlySubscriptionId
        iAPHelper.purchase()
    }
    
    
    @IBAction func restorePurchasingTapped(_ sender: UIButton) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        iAPHelper.restorePurchase()
    }
    
    
}


//MARK: Actions
extension SettingsVC {
    @IBAction func btnAbout_Clicked(_ sender: UIButton) {
        guard let url = URL(string: About_URL) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func btnPrivacyPolicy_Clicked(_ sender: UIButton) {
        guard let url = URL(string: Privacy_URL) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func btnRateUs_Clicked(_ sender: UIButton) {
        if #available( iOS 10.3,*){
        SKStoreReviewController.requestReview()
        }else{
            guard let url = URL(string: About_URL) else { return }
            UIApplication.shared.open(url)
        }
    }
}



extension SettingsVC : InAppPurchaseDelegate{
    func restoreDidSucceed() {
        MBProgressHUD.hide(for:self.view, animated: true)
        PurchaseStatusUserDefualt.value = 1
        updatePurchaseViewHeight()
    }
    func purchaseDidSucceed() {
        MBProgressHUD.hide(for:self.view, animated: true)
        PurchaseStatusUserDefualt.value = 1
        updatePurchaseViewHeight()
    }
    func nothingToRestore() {
        MBProgressHUD.hide(for:self.view, animated: true)
        Utility.showLoaf(message: "There is nothing to restore", state: .error)
    }
    func paymentCancelled() {
        MBProgressHUD.hide(for:self.view, animated: true)
        Utility.showLoaf(message: "The payment got cancelled", state: .error)
    }
    func unknowErrorOccur() {
        MBProgressHUD.hide(for:self.view, animated: true)
        Utility.showLoaf(message: "Unknow error occur", state: .error)
    }
    
    func returnProduct(product: SKProduct) {
        guard let currencySymbol = product.priceLocale.currencySymbol else {return}
        priceBtn.setTitle("Purchase Pro \(currencySymbol)\(product.price)/Month", for: .normal)
    }
}

