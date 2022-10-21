//
//  WallpaperVC.swift
//  WallPaperApp
//
//  Created by iMac on 29/02/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import PinterestLayout
import SwiftyJSON
import GoogleMobileAds

class WallpaperCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imgWallpaper: UIImageView!
    @IBOutlet weak var imgWallpaper_height: NSLayoutConstraint!
    @IBOutlet weak var lblViews: UILabel!
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? PinterestLayoutAttributes {
            imgWallpaper_height.constant = attributes.imageHeight
        }
    }
}

class WallpaperVC: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var collection_wallpapers: UICollectionView!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var view_BannerAd: UIView!
    @IBOutlet weak var viewBannerAd_height: NSLayoutConstraint!
    
    //MARK: Variables
    var wallpaperArr = [[String:String]]()
    var pageIndex = 1
    private let refreshControl = UIRefreshControl()
    var categoryId = ""
    var categoryName = ""
    var bannerView: GADBannerView!
    
    //MARK: Viewcontroller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblCategory.text = categoryName
        
        let layout = PinterestLayout()
        self.collection_wallpapers.collectionViewLayout = layout
        layout.delegate = self
        layout.numberOfColumns = 2
        
        self.collection_wallpapers.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(self.refreshWallpaperData(_:)), for: .valueChanged)
        
        let urlString = API_URL + "getwallpaperbycategory.php"
        let params: NSDictionary = ["pageIndex":"\(self.pageIndex)",
            "numberOfRecords":numberOfRecords,
            "category_id":self.categoryId]
        self.Webservice_WallpapersByCategory(url: urlString, params: params)
        
        self.viewBannerAd_height.constant = 0.0
        self.bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        self.bannerView.adUnitID = AdBannerIdTest
        self.bannerView.rootViewController = self
        self.bannerView.delegate = self
        self.bannerView.load(GADRequest())
    }
    
}

//MARK: Functions
extension WallpaperVC {
    @objc private func refreshWallpaperData(_ sender: Any) {
        self.refreshControl.endRefreshing()
        self.pageIndex = 1
        var userId = ""
        if UserDefaults.standard.value(forKey: UD_userId) == nil || UserDefaults.standard.value(forKey: UD_userId) as! String == "" || UserDefaults.standard.value(forKey: UD_userId) as! String == "N/A" || UserDefaults.standard.value(forKey: UD_userId) as! String == "0" {
            userId = ""
        }
        else {
            userId = UserDefaults.standard.value(forKey: UD_userId) as! String
        }
        let urlString = API_URL + "getwallpaperbycategory.php"
        let params: NSDictionary = ["pageIndex":"\(self.pageIndex)",
            "numberOfRecords":numberOfRecords,
            "category_id":self.categoryId,
            "user_id":userId]
        self.Webservice_WallpapersByCategory(url: urlString, params: params)
    }
}

//MARK: Actions
extension WallpaperVC {
    @IBAction func btnBack_Clicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: Collectionview methods
extension WallpaperVC: UICollectionViewDelegate,UICollectionViewDataSource,PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let rect = CGRect(origin: CGPoint(x: 0,y: 0), size: CGSize(width: self.collection_wallpapers.bounds.size.width, height: self.collection_wallpapers.bounds.size.height))
        let noDataImage = UIImageView(frame: rect)
        noDataImage.contentMode = .scaleAspectFit
        noDataImage.image = UIImage(named: "ic_noData")
        self.collection_wallpapers.backgroundView = noDataImage
        if self.wallpaperArr.count == 0 {
            noDataImage.isHidden = false
        }
        else {
            noDataImage.isHidden = true
        }
        return self.wallpaperArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collection_wallpapers.dequeueReusableCell(withReuseIdentifier: "WallpaperCollectionCell", for: indexPath) as! WallpaperCollectionCell
        cell.backgroundColor = UIColor.init(hex: self.wallpaperArr[indexPath.item]["wallpaper_color"]!)
        cell.imgWallpaper.isHidden = true
        cell.imgWallpaper.sd_setImage(with: URL(string: self.wallpaperArr[indexPath.item]["wallpaper_image"]!)) { (image, error, cache, url) in
            cell.imgWallpaper.isHidden = false
        }
        cell.lblViews.layer.cornerRadius = 10.0
        cell.lblViews.text = "        " + self.wallpaperArr[indexPath.item]["wallpaper_views"]! + "  "
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let urlString = API_URL + "wallpaperview.php"
        let params: NSDictionary = ["wallpaper_id":self.wallpaperArr[indexPath.item]["id"]!]
        self.Webservice_ViewWallpaper(url: urlString, params: params, wallpaperIndex: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == self.wallpaperArr.count - 1 {
            if self.pageIndex != 0 {
                let urlString = API_URL + "getwallpaperbycategory.php"
                let params: NSDictionary = ["pageIndex":"\(self.pageIndex)",
                    "numberOfRecords":numberOfRecords,
                    "category_id":self.categoryId]
                self.Webservice_WallpapersByCategory(url: urlString, params: params)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView,
                        heightForImageAtIndexPath indexPath: IndexPath,
                        withWidth: CGFloat) -> CGFloat {
        let wallpaperHeight = Int(self.wallpaperArr[indexPath.item]["wallpaper_height"]!)
        return CGFloat(wallpaperHeight!)
    }
    
    func collectionView(collectionView: UICollectionView,
                        heightForAnnotationAtIndexPath indexPath: IndexPath,
                        withWidth: CGFloat) -> CGFloat {
        return "".heightForWidth(width: withWidth, font: UIFont.systemFont(ofSize: 0))
    }
}

//MARK: Webservices
extension WallpaperVC
{
    func Webservice_WallpapersByCategory(url:String, params:NSDictionary) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["ResponseCode"].stringValue
                if responseCode == "1" {
                    let responseData = jsonResponse!["ResponseData"].arrayValue
                    if self.pageIndex == 1 {
                        self.wallpaperArr.removeAll()
                    }
                    if responseData.count < numberOfRecords {
                        self.pageIndex = 0
                    }
                    else {
                        self.pageIndex = self.pageIndex + 1
                    }
                    for data in responseData {
                        let wallpaperObj = ["id":data["id"].stringValue,"wallpaper_image":data["wallpaper_image"].stringValue,"wallpaper_height":data["wallpaper_height"].stringValue,"wallpaper_color":data["wallpaper_color"].stringValue,"user_id":data["user_id"].stringValue,"user_image":data["user_image"].stringValue,"user_name":data["user_name"].stringValue,"wallpaper_likes":data["wallpaper_likes"].stringValue,"wallpaper_views":data["wallpaper_views"].stringValue,"category_name":data["category_name"].stringValue,"isFavourite":data["isFavourite"].stringValue]
                        self.wallpaperArr.append(wallpaperObj)
                    }
                    self.collection_wallpapers.reloadData()
                }
                else if responseCode == "0" {
                    if self.pageIndex == 1 {
                        self.wallpaperArr.removeAll()
                    }
                    self.pageIndex = 0
                    self.collection_wallpapers.reloadData()
                }
            }
        }
    }
    
    func Webservice_ViewWallpaper(url:String, params:NSDictionary, wallpaperIndex:IndexPath) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let objVC = self.storyboard?.instantiateViewController(withIdentifier: "WallpaperPreviewVC") as! WallpaperPreviewVC
                objVC.wallpaperArr = self.wallpaperArr
                objVC.wallpaperIndex = wallpaperIndex
                objVC.pageIndex = self.pageIndex
                objVC.Selectedtype = "3"
                objVC.CategoryId = self.categoryId
                self.navigationController?.pushViewController(objVC, animated: true)
            }
        }
    }
}

//MARK: Admob methods
extension WallpaperVC: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        self.bannerView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 50.0)
        self.view_BannerAd.addSubview(self.bannerView)
        self.viewBannerAd_height.constant = 50.0
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        self.viewBannerAd_height.constant = 0.0
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}
