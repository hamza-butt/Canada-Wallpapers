//
//  CategoryVC.swift
//  WallPaperApp
//
//  Created by iMac on 28/02/20.
//  Copyright © 2020 Mitesh's MAC. All rights reserved.
//

import UIKit
import SwiftyJSON
import GoogleMobileAds
import FSPagerView

class CategoryCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var lbl_Empty: UILabel!
    @IBOutlet weak var imgCategory: UIImageView!
    @IBOutlet weak var lblCategory: UILabel!
}

class CategoryVC: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var collection_category: UICollectionView!
    @IBOutlet weak var view_BannerAd: UIView!
    @IBOutlet weak var viewBannerAd_height: NSLayoutConstraint!
    @IBOutlet weak var Empty_View: UIView!
    
    @IBOutlet weak var pagerView: FSPagerView! {
           didSet {
               self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
//               self.typeIndex = 0
           }
       }
    //MARK: Variables
    var categoryArr = [[String:String]]()
    var wallpaperArr = [[String:String]]()
    
    var bannerView: GADBannerView!
    private let refreshControl = UIRefreshControl()
    
    //MARK: Viewcontroller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collection_category.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(self.refreshWallpaperData(_:)), for: .valueChanged)
        
        let urlString = API_URL + "getcategories.php?id_cat="+Categorey_Id
        self.Webservice_Categories(url: urlString)
        
        self.viewBannerAd_height.constant = 0.0
        self.bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        self.bannerView.adUnitID = AdBannerIdTest
        self.bannerView.rootViewController = self
        self.bannerView.delegate = self
        self.bannerView.load(GADRequest())
        
        
        self.pagerView.delegate = self
        self.pagerView.dataSource = self
        let transform = CGAffineTransform(scaleX: 0.6, y: 0.75)
        self.pagerView.itemSize = self.pagerView.frame.size.applying(transform)
        self.pagerView.decelerationDistance = FSPagerView.automaticDistance
      
        self.pagerView.transformer = FSPagerViewTransformer(type: .overlap)
        self.pagerView.backgroundColor = UIColor.clear
        self.pagerView.alwaysBounceHorizontal = true
//        self.pagerView.interitemSpacing = 10
//        self.pagerView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewBannerAd_height.constant = PurchaseStatusUserDefualt.value == 1 ? 0 : 50.0
    }
    
}

extension CategoryVC : FSPagerViewDelegate,FSPagerViewDataSource
{
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.backgroundColor = UIColor.clear
        cell.backgroundColor?.withAlphaComponent(0.2)
        cell.imageView!.layer.cornerRadius = 8.0
        cell.imageView!.layer.masksToBounds = true
        let imgURL = self.wallpaperArr[index]["wallpaper_image"]!
        print(imgURL)
        cell.imageView?.sd_setImage(with: URL(string:imgURL), completed: { (img, error, cache, url) in
            cell.imageView?.isHidden = false
        })
        return cell
    }
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        if self.wallpaperArr.count == 0
        {
            self.Empty_View.isHidden = false
        }
        else{
           self.Empty_View.isHidden = true
        }
        return self.wallpaperArr.count
    }
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "WallpaperPreviewVC") as! WallpaperPreviewVC
        objVC.wallpaperArr = self.wallpaperArr
        objVC.wallpaperIndex = IndexPath(row: index, section: 0)
        self.navigationController?.pushViewController(objVC, animated: true)
    }
}

//MARK: Functions
extension CategoryVC {
    @objc private func refreshWallpaperData(_ sender: Any) {
        self.refreshControl.endRefreshing()
        let urlString = API_URL + "getcategories.php?id_cat="+Categorey_Id
        self.Webservice_Categories(url: urlString)
    }
}


//MARK: Collectionview methods
extension CategoryVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let rect = CGRect(origin: CGPoint(x: 0,y: 0), size: CGSize(width: self.collection_category.bounds.size.width, height: self.collection_category.bounds.size.height))
        let noDataImage = UIImageView(frame: rect)
        noDataImage.contentMode = .scaleAspectFit
        noDataImage.image = UIImage(named: "ic_noData")
        self.collection_category.backgroundView = noDataImage
        if self.categoryArr.count == 0 {
            noDataImage.isHidden = false
        }
        else {
            noDataImage.isHidden = true
        }
        return self.categoryArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collection_category.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionCell", for: indexPath) as! CategoryCollectionCell
        cell.imgCategory.layer.cornerRadius = 8.0
        cell.lbl_Empty.layer.cornerRadius = 8.0
        cell.lbl_Empty.layer.masksToBounds = true
        cell.imgCategory.layer.masksToBounds = true
        cell.imgCategory.sd_setImage(with: URL(string: self.categoryArr[indexPath.item]["category_image"]!), placeholderImage: UIImage(named: "placeholder_image"))
        cell.lblCategory.text = self.categoryArr[indexPath.item]["category_name"]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return App.isRunningOnIpad ? CGSize(width: 165, height: 165) : CGSize(width: 110, height: 110)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let urlString = API_URL + "getwallpaperbycategory.php"
//        let params: NSDictionary = ["pageIndex":"\(1)",
//            "numberOfRecords":numberOfRecords,
//            "category_id":self.categoryArr[indexPath.item]["id"]!]
//        self.Webservice_WallpapersByCategory(url: urlString, params: params)
        
        let urlString = API_URL + "getwallpaperbycategory.php"
        let params: NSDictionary = [
            "category_id":self.categoryArr[indexPath.item]["id"]!]
        self.Webservice_WallpapersByCategory(url: urlString, params: params)
    }
}

//MARK: Webservices
extension CategoryVC
{
    func Webservice_Categories(url:String) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:[:], httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["ResponseCode"].stringValue
                if responseCode == "1" {
                    let responseData = jsonResponse!["ResponseData"].arrayValue
                    self.categoryArr.removeAll()
                    for data in responseData {
                        let categoryObj = ["id":data["id"].stringValue,"category_image":data["category_image"].stringValue,"category_name":data["category_name"].stringValue]
                        self.categoryArr.append(categoryObj)
                    }
//                    print(self.categoryArr[0]["id"] as! String)
//                    let urlString = API_URL + "getwallpaperbycategory.php"
//                    let params: NSDictionary = ["pageIndex":"\(1)",
//                        "numberOfRecords":numberOfRecords,
//                        "category_id":self.categoryArr[0]["id"]!]
//                    self.Webservice_WallpapersByCategory(url: urlString, params: params)
                    
                    let urlString = API_URL + "getwallpaperbycategory.php"
                                      let params: NSDictionary = [
                                          "category_id":self.categoryArr[0]["id"]!]
                                      self.Webservice_WallpapersByCategory(url: urlString, params: params)
                    
                    self.collection_category.reloadData()
                }
            }
        }
    }
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
                        self.wallpaperArr.removeAll()
                    for data in responseData {
                        let wallpaperObj = ["id":data["id"].stringValue,"wallpaper_image":data["wallpaper_image"].stringValue,"wallpaper_height":data["wallpaper_height"].stringValue,"wallpaper_color":data["wallpaper_color"].stringValue,"user_id":data["user_id"].stringValue,"user_image":data["user_image"].stringValue,"user_name":data["user_name"].stringValue,"wallpaper_likes":data["wallpaper_likes"].stringValue,"wallpaper_views":data["wallpaper_views"].stringValue,"category_name":data["category_name"].stringValue,"isFavourite":data["isFavourite"].stringValue]
                        self.wallpaperArr.append(wallpaperObj)
                    }
                    self.pagerView.delegate = self
                    self.pagerView.dataSource = self
                    let transform = CGAffineTransform(scaleX: 0.6, y: 0.75)
                    self.pagerView.itemSize = self.pagerView.frame.size.applying(transform)
                    self.pagerView.decelerationDistance = FSPagerView.automaticDistance
                    self.pagerView.transformer = FSPagerViewTransformer(type: .overlap)
                    self.pagerView.backgroundColor = UIColor.clear
                    self.pagerView.alwaysBounceHorizontal = true
                    self.pagerView.reloadData()
                }
                else if responseCode == "0" {
//                    if self.pageIndex == 1 {
//
//                    }
//                    self.pageIndex = 0
                    self.wallpaperArr.removeAll()
                    self.pagerView.delegate = self
                    self.pagerView.dataSource = self
                    let transform = CGAffineTransform(scaleX: 0.6, y: 0.75)
                    self.pagerView.itemSize = self.pagerView.frame.size.applying(transform)
                    self.pagerView.decelerationDistance = FSPagerView.automaticDistance
                    self.pagerView.transformer = FSPagerViewTransformer(type: .overlap)
                    self.pagerView.backgroundColor = UIColor.clear
                    self.pagerView.alwaysBounceHorizontal = true
                    self.pagerView.reloadData()
                }
            }
        }
    }
    
}

//MARK: Admob methods
extension CategoryVC: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        self.bannerView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 50.0)
        self.view_BannerAd.addSubview(self.bannerView)
        self.viewBannerAd_height.constant = PurchaseStatusUserDefualt.value == 1 ? 0 : 50.0
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
