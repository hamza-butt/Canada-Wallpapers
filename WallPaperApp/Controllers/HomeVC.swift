
//
//  HomeVC.swift
//  WallPaperApp
//
//  Created by Mitesh's MAC on 20/12/19.
//  Copyright © 2019 Mitesh's MAC. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SwiftyJSON
import PinterestLayout
import SDWebImage

class LatestCollectionCell: UICollectionViewCell {
    
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
class TrendingCollectionCell: UICollectionViewCell {
    
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


class HomeVC: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var view_BannerAd: UIView!
    @IBOutlet weak var viewBannerAd_height: NSLayoutConstraint!
    @IBOutlet weak var btn_Latest: UIButton!
    @IBOutlet var Trending_view: UIView!
    
    @IBOutlet weak var Main_view: UIView!
    @IBOutlet var Latest_view: UIView!
    @IBOutlet weak var btn_Trending: UIButton!
    
    //MARK: Variables
    var tabs = [ViewPagerTab(title: "LATEST", image: UIImage(named: "")),
                ViewPagerTab(title: "TRENDING", image: UIImage(named: ""))]
    var viewPager:ViewPagerController!
    var options:ViewPagerOptions!
    var bannerView: GADBannerView!
    
    //MARK: Outlets
    @IBOutlet weak var collection_latestwallpapers: UICollectionView!
    @IBOutlet weak var collection_trendingwallpapers: UICollectionView!
    
    
    //MARK: Variables
    var latestWallpaperArr = [[String:String]]()
    var trendingWallpaperArr = [[String:String]]()
    var pageIndex = 1
    var TrandingpageIndex = 1
    private let refreshControlLatest = UIRefreshControl()
    private let refreshControlTranding = UIRefreshControl()
    
    let adRowStep = 7
    
    // MARK: - Native Ads Properties
    /// The height constraint applied to the ad view, where necessary.
    var heightConstraint: NSLayoutConstraint?

    /// The ad loader. You must keep a strong reference to the GADAdLoader during the ad loading
    /// process.
    var adLoader: GADAdLoader!
    
    /// The native ad view that is being presented.
    var nativeAdView = [GADUnifiedNativeAdView]()
    
    /// The ad unit ID.
    let adUnitID = "ca-app-pub-7368160219570936/4854903797"
    
    /// The number of native ads to load (max 5).
    let numAdsToLoad = 5
    
    /// The number of cell to show ads
    let adsToLoadToAfter = 5
    
    /// The native ads.
    var nativeAds = [GADUnifiedNativeAd]()
    
    /// Add native ads to the  list.
    func addNativeAds() {
        if nativeAds.count <= 0 {
            print("Ads not dispalying ")
            return
        }
        
        let adInterval = (latestWallpaperArr.count / nativeAds.count) + 1
        var index = 0
        for nativeAd in nativeAds {
            if index <= collectionObject.count {
                collectionObject.insert(nativeAd, at: index)
                index += 1
                
                guard
                    let nibObjects = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil),
                    let adView = nibObjects.first as? GADUnifiedNativeAdView
                else {
                    assert(false, "Could not load nib file for adView")
                    return
                }
                
                nativeAd.rootViewController = self
                let nativeView: GADUnifiedNativeAdView!
                nativeView = adView
                // Populate the native ad view with the native ad assets.
                // The headline and mediaContent are guaranteed to be present in every native ad.
                (nativeView.headlineView as? UILabel)?.text = nativeAd.headline
                nativeView.mediaView?.mediaContent = nativeAd.mediaContent
                
                // Some native ads will include a video asset, while others do not. Apps can use the
                // GADVideoController's hasVideoContent property to determine if one is present, and adjust their
                // UI accordingly.
                let mediaContent = nativeAd.mediaContent
                if mediaContent.hasVideoContent {
                    // By acting as the delegate to the GADVideoController, this ViewController receives messages
                    // about events in the video lifecycle.
                    mediaContent.videoController.delegate = self
                    //          videoStatusLabel.text = "Ad contains a video asset."
                } else {
                    //          videoStatusLabel.text = "Ad does not contain a video."
                }
                
                // This app uses a fixed width for the GADMediaView and changes its height to match the aspect
                // ratio of the media it displays.
                if let mediaView = nativeView.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
                    heightConstraint = NSLayoutConstraint(
                        item: mediaView,
                        attribute: .height,
                        relatedBy: .equal,
                        toItem: mediaView,
                        attribute: .width,
                        multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
                        constant: 0)
                    heightConstraint?.isActive = true
                }
                
                // These assets are not guaranteed to be present. Check that they are before
                // showing or hiding them.
                (nativeView.bodyView as? UILabel)?.text = nativeAd.body
                nativeView.bodyView?.isHidden = nativeAd.body == nil
                
                (nativeView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
                nativeView.callToActionView?.isHidden = nativeAd.callToAction == nil
                
                (nativeView.iconView as? UIImageView)?.image = nativeAd.icon?.image
                nativeView.iconView?.isHidden = nativeAd.icon == nil
                
                (nativeView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
                nativeView.starRatingView?.isHidden = nativeAd.starRating == nil
                
                (nativeView.storeView as? UILabel)?.text = nativeAd.store
                nativeView.storeView?.isHidden = nativeAd.store == nil
                
                (nativeView.priceView as? UILabel)?.text = nativeAd.price
                nativeView.priceView?.isHidden = nativeAd.price == nil
                
                (nativeView.advertiserView as? UILabel)?.text = nativeAd.advertiser
                nativeView.advertiserView?.isHidden = nativeAd.advertiser == nil
                
                // In order for the SDK to process touch events properly, user interaction should be disabled.
                nativeView.callToActionView?.isUserInteractionEnabled = false
                
                // Associate the native ad view with the native ad object. This is
                // required to make the ad clickable.
                // Note: this should always be done after populating the ad views.
                nativeView.nativeAd = nativeAd
                
                nativeAdView.append(nativeView)
            } else {
                print("Not what I want")
                break
            }
        }
        
        if collectionObject.count > 0 {
            self.collection_latestwallpapers.reloadData()
        }
    }
    
    var collectionObject = [AnyObject]()
    
    //MARK: Viewcontroller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collection_latestwallpapers.register(UINib(nibName: "NativeAdCell", bundle: nil), forCellWithReuseIdentifier: "UnifiedNativeAdCell")
        self.collection_latestwallpapers.register(UINib(nibName: "NativeAdsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NativeAdsCollectionViewCell")
        
        addNativeAds()
        
        self.viewBannerAd_height.constant = 0.0
        self.bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        self.bannerView.adUnitID = AdBannerIdTest
        self.bannerView.rootViewController = self
        self.bannerView.delegate = self
        self.bannerView.load(GADRequest())
        
        
        self.btn_Latest.layer.cornerRadius = 6.0
        self.btn_Latest.backgroundColor = PurpleColor
        self.btn_Trending.backgroundColor = UIColor.clear
        
        self.btn_Trending.setTitleColor(PurpleColor, for: .normal)
        self.btn_Latest.setTitleColor(.white, for: .normal)
        
        
        self.Trending_view.removeFromSuperview()
        self.addViewDynamically(subview: self.Latest_view)
        
        
//        let layout1 = PinterestLayout()
//        self.collection_latestwallpapers.collectionViewLayout = layout1
//        layout1.numberOfColumns = 1
//        //layout1.delegate = self
//        
//        let layout2 = PinterestLayout()
//        self.collection_trendingwallpapers.collectionViewLayout = layout2
//        layout2.numberOfColumns = 2
//        layout2.delegate = self
        
        self.collection_latestwallpapers.refreshControl = self.refreshControlLatest
        self.refreshControlLatest.addTarget(self, action: #selector(self.refreshWallpaperData(_:)), for: .valueChanged)
        
        self.collection_trendingwallpapers.refreshControl = self.refreshControlTranding
        self.refreshControlTranding.addTarget(self, action: #selector(self.refreshWallpapertrandingData(_:)), for: .valueChanged)
        
        let urlString = API_URL + "wallall.php?id_cat="+Categorey_Id
        let params: NSDictionary = ["pageIndex":"\(self.pageIndex)",
            "numberOfRecords":numberOfRecords]
        self.Webservice_LatestWallpapers(url: urlString, params: params)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewBannerAd_height.constant = PurchaseStatusUserDefualt.value == 1 ? 0 : 50.0
        self.tabBarController?.tabBar.isHidden = false
        
        let options = GADMultipleAdsAdLoaderOptions()
        options.numberOfAds = numAdsToLoad
        
        // Prepare the ad loader and start loading ads.
        adLoader = GADAdLoader(adUnitID: adUnitID,
                               rootViewController: self,
                               adTypes: [.unifiedNative],
                               options: [options])
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    /// Returns a `UIImage` representing the number of stars from the given star rating; returns `nil`
    /// if the star rating is less than 3.5 stars.
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
      guard let rating = starRating?.doubleValue else {
        return nil
      }
      if rating >= 5 {
        return UIImage(named: "stars_5")
      } else if rating >= 4.5 {
        return UIImage(named: "stars_4_5")
      } else if rating >= 4 {
        return UIImage(named: "stars_4")
      } else if rating >= 3.5 {
        return UIImage(named: "stars_3_5")
      } else {
        return nil
      }
    }
    
    @IBAction func btnTap_Latest(_ sender: UIButton) {
        self.btn_Latest.layer.cornerRadius = 6.0
        self.btn_Latest.backgroundColor = PurpleColor
        self.btn_Trending.backgroundColor = UIColor.clear
        
        self.btn_Trending.setTitleColor(PurpleColor, for: .normal)
        self.btn_Latest.setTitleColor(.white, for: .normal)
        
        self.Trending_view.removeFromSuperview()
        self.addViewDynamically(subview: self.Latest_view)
        
        let urlString = API_URL + "wallall.php?id_cat="+Categorey_Id
        let params: NSDictionary = ["pageIndex":"\(self.pageIndex)",
            "numberOfRecords":numberOfRecords]
        self.Webservice_LatestWallpapers(url: urlString, params: params)
        
    }
    
    @IBAction func btnTap_Trending(_ sender: UIButton) {
        self.btn_Trending.layer.cornerRadius = 6.0
        self.btn_Trending.backgroundColor = PurpleColor
        self.btn_Latest.backgroundColor = UIColor.clear
        self.btn_Trending.setTitleColor(.white, for: .normal)
        self.btn_Latest.setTitleColor(PurpleColor, for: .normal)
        self.Latest_view.removeFromSuperview()
        self.addViewDynamically(subview: self.Trending_view)
        
        
        
        let urlString = API_URL + "gettrendingwallpapers.php?id_cat="+Categorey_Id
        let params: NSDictionary = ["pageIndex":"\(self.TrandingpageIndex)",
            "numberOfRecords":numberOfRecords]
        self.Webservice_TrendingWallpapers(url: urlString, params: params)
        
    }
}

//MARK: Functions
extension HomeVC {
    @objc private func refreshWallpaperData(_ sender: Any) {
        
        self.refreshControlLatest.endRefreshing()
        self.pageIndex = 1
        let urlString = API_URL + "wallall.php?id_cat="+Categorey_Id
        let params: NSDictionary = ["pageIndex":"\(self.pageIndex)",
            "numberOfRecords":numberOfRecords]
        self.Webservice_LatestWallpapers(url: urlString, params: params)
    }
    @objc private func refreshWallpapertrandingData(_ sender: Any) {
        self.refreshControlTranding.endRefreshing()
        self.TrandingpageIndex = 1
        let urlString = API_URL + "gettrendingwallpapers.php"
        let params: NSDictionary = ["pageIndex":"\(self.TrandingpageIndex)",
            "numberOfRecords":numberOfRecords]
        self.Webservice_TrendingWallpapers(url: urlString, params: params)
    }
}
//MARK: Pagerview methods
extension HomeVC {
    func addViewDynamically(subview : UIView)
    {
        subview.translatesAutoresizingMaskIntoConstraints = false;
        self.Main_view.addSubview(subview)
        self.Main_view.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.Main_view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0.0))
        self.Main_view.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.Main_view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0.0))
        self.Main_view.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.Main_view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0.0))
        self.Main_view.addConstraint(NSLayoutConstraint(item: subview
            , attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.Main_view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0.0))
        self.Main_view.layoutIfNeeded()
    }
}

extension HomeVC: GADVideoControllerDelegate {

  func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
//    videoStatusLabel.text = "Video playback has ended."
  }
}

// MARK: - GADAdLoaderDelegate
extension HomeVC: GADUnifiedNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        // Set ourselves as the native ad delegate to be notified of native ad events.
        nativeAd.delegate = self
        
        nativeAds.append(nativeAd)
    }
    
    func adLoader(_ adLoader: GADAdLoader,
                  didFailToReceiveAdWithError error: GADRequestError) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        //        enableMenuButton()
        print("ad loaded")
        addNativeAds()
    }
}
// MARK: - GADUnifiedNativeAdDelegate implementation
extension HomeVC : GADUnifiedNativeAdDelegate {

  func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }

  func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }

  func nativeAdWillPresentScreen(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }

  func nativeAdWillDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }

  func nativeAdDidDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }

  func nativeAdWillLeaveApplication(_ nativeAd: GADUnifiedNativeAd) {
    print("\(#function) called")
  }
}

//MARK: Colletionview methods
extension HomeVC: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if collectionView == self.collection_latestwallpapers
        {
            return 2
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.collection_latestwallpapers{
            
            if (((indexPath.row+1) % adsToLoadToAfter) == 0) && collectionObject.count > 0 {
                return CGSize(width: collectionView.frame.width, height: 300)
            } else {
                
                // Use tableData[indexPath.row - Int(indexPath.row / adRowStep)] to get the row this would have normally been without the ad
                if indexPath.row > self.latestWallpaperArr.count{
                    return CGSize(width: 0, height: 0)
                }
                let wallpaperHeight = Int(self.latestWallpaperArr[indexPath.row - Int(indexPath.row / adRowStep)]["wallpaper_height"]!)
                
                
                if App.isRunningOnIpad {
                    return CGSize(width: collectionView.frame.width / 3 - 2, height: collectionView.frame.height / 3)
                }else{
                    return CGSize(width: collectionView.frame.width / 2, height: CGFloat(wallpaperHeight!))
                }
                
            }
        }
        else{
            let wallpaperHeight = Int(self.trendingWallpaperArr[indexPath.item]["wallpaper_height"]!)
            
            if App.isRunningOnIpad {
                return CGSize(width: collectionView.frame.width / 3 - 2, height: collectionView.frame.height / 3)
            }else{
                return CGSize(width: collectionView.frame.width / 2, height: CGFloat(wallpaperHeight!))
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.collection_latestwallpapers
        {
            let rect = CGRect(origin: CGPoint(x: 0,y: 0), size: CGSize(width: self.collection_latestwallpapers.bounds.size.width, height: self.collection_latestwallpapers.bounds.size.height))
            let noDataImage = UIImageView(frame: rect)
            noDataImage.contentMode = .scaleAspectFit
            noDataImage.image = UIImage(named: "ic_noData")
            self.collection_latestwallpapers.backgroundView = noDataImage
            if self.latestWallpaperArr.count == 0 {
                noDataImage.isHidden = false
            }
            else {
                noDataImage.isHidden = true
            }
            
            if (section == 0) {
                return self.latestWallpaperArr.count
            } else {
                return self.collectionObject.count > 0 ? collectionObject.count : 0
            }
            
        }
        else
        {
            let rect = CGRect(origin: CGPoint(x: 0,y: 0), size: CGSize(width: self.collection_trendingwallpapers.bounds.size.width, height: self.collection_trendingwallpapers.bounds.size.height))
            let noDataImage = UIImageView(frame: rect)
            noDataImage.contentMode = .scaleAspectFit
            noDataImage.image = UIImage(named: "ic_noData")
            self.collection_trendingwallpapers.backgroundView = noDataImage
            if self.trendingWallpaperArr.count == 0 {
                noDataImage.isHidden = false
            }
            else {
                noDataImage.isHidden = true
            }
            return self.trendingWallpaperArr.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collection_latestwallpapers
        {
            
            if (((indexPath.row+1) % adsToLoadToAfter) == 0) && collectionObject.count > 0 {
                let number = Int.random(in: 0..<(collectionObject.count))
                print("indexvalue: ", number)
                let cell = self.collection_latestwallpapers.dequeueReusableCell(withReuseIdentifier: "NativeAdsCollectionViewCell", for: indexPath) as! NativeAdsCollectionViewCell
                
                let nativeAdV = nativeAdView[number]
                
                nativeAdV.translatesAutoresizingMaskIntoConstraints = false
                cell.nativeAdPlaceholder.addSubview(nativeAdV)
                
                NSLayoutConstraint.activate([
                    nativeAdV.widthAnchor.constraint(equalToConstant: collectionView.frame.width),
                    nativeAdV.heightAnchor.constraint(equalToConstant: 300)
                ])
                
                return cell
            } else {
                // Return a normal cell
                // Use tableData[indexPath.row - Int(indexPath.row / adRowStep)] to get the row this would have normally been without the ad
                let cell = self.collection_latestwallpapers.dequeueReusableCell(withReuseIdentifier: "LatestCollectionCell", for: indexPath) as! LatestCollectionCell
                if indexPath.row > self.latestWallpaperArr.count{
                    return cell
                }
                cell.contentView.backgroundColor = UIColor(hex: self.latestWallpaperArr[indexPath.row - Int(indexPath.row / adRowStep)]["wallpaper_color"]!)
                cell.imgWallpaper.isHidden = true
                cell.imgWallpaper.sd_setImage(with: URL(string: self.latestWallpaperArr[indexPath.row - Int(indexPath.row / adRowStep)]["wallpaper_image"]!)) { (image, error, cache, url) in
                    cell.imgWallpaper.isHidden = false
                }
                cell.lblViews.layer.cornerRadius = 6.0
                cell.lblViews.text = "        " + self.latestWallpaperArr[indexPath.row - Int(indexPath.row / adRowStep)]["wallpaper_views"]! + "  "
                return cell
            }
        }
        else{
            let cell = self.collection_trendingwallpapers.dequeueReusableCell(withReuseIdentifier: "TrendingCollectionCell", for: indexPath) as! TrendingCollectionCell
            cell.backgroundColor = UIColor.init(hex: self.trendingWallpaperArr[indexPath.item]["wallpaper_color"]!)
            cell.imgWallpaper.isHidden = true
            cell.imgWallpaper.sd_setImage(with: URL(string: self.trendingWallpaperArr[indexPath.item]["wallpaper_image"]!)) { (image, error, cache, url) in
                cell.imgWallpaper.isHidden = false
            }
            cell.lblViews.layer.cornerRadius = 6.0
            cell.lblViews.text = "        " + self.trendingWallpaperArr[indexPath.item]["wallpaper_views"]! + "  "
            return cell
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collection_latestwallpapers
        {
//            if self.adsCellProvider != nil && self.adsCellProvider.isAdCell(at: indexPath, forStride: UInt(adRowStep)) {
//                let ad = adsManager.nextNativeAd
//                if let url = ad?.adChoicesLinkURL {
//                    UIApplication.shared.open(url)
//                }
//            }
            if (((indexPath.row+1) % adsToLoadToAfter) == 0) {
                print("ad clicked")
            } else {
                // Return a normal cell
                // Use tableData[indexPath.row - Int(indexPath.row / adRowStep)] to get the row this would have normally been without the ad
                let urlString = API_URL + "wallpaperview.php"
                print("Item ID: \(self.latestWallpaperArr[indexPath.row - Int(indexPath.row / adRowStep)]["id"]!)")
                let params: NSDictionary = ["wallpaper_id":self.latestWallpaperArr[indexPath.row - Int(indexPath.row / adRowStep)]["id"]!]
                let newIndexPath = IndexPath(row: indexPath.row - Int(indexPath.row / adRowStep), section: 0)
                self.Webservice_ViewWallpaper(url: urlString, params: params, wallpaperIndex: newIndexPath)
            }
        }
        else{
            let urlString = API_URL + "wallpaperview.php"
            let params: NSDictionary = ["wallpaper_id":self.trendingWallpaperArr[indexPath.item]["id"]!]
            self.Webservice_ViewWallpaperTranding(url: urlString, params: params, wallpaperIndex: indexPath)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if collectionView == self.collection_latestwallpapers
        {
            if indexPath.item == self.latestWallpaperArr.count - 1 {
                if self.pageIndex != 0 {
                    let urlString = API_URL + "wallall.php?id_cat="+Categorey_Id
                    let params: NSDictionary = ["pageIndex":"\(self.pageIndex)",
                        "numberOfRecords":numberOfRecords]
                    self.Webservice_LatestWallpapers(url: urlString, params: params)
                }
            }
        }
        else{
            if indexPath.item == self.trendingWallpaperArr.count - 1 {
                if self.TrandingpageIndex != 0 {
                    let urlString = API_URL + "gettrendingwallpapers.php?id_cat="+Categorey_Id
                    let params: NSDictionary = ["pageIndex":"\(self.TrandingpageIndex)",
                        "numberOfRecords":numberOfRecords]
                    self.Webservice_TrendingWallpapers(url: urlString, params: params)
                }
            }
        }
        
    }

}
//MARK: Webservices
extension HomeVC
{
    func Webservice_LatestWallpapers(url:String, params:NSDictionary) -> Void {
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
                        self.latestWallpaperArr.removeAll()
                    }
                    if responseData.count < numberOfRecords {
                        self.pageIndex = 0
                    }
                    else {
                        self.pageIndex = self.pageIndex + 1
                    }
                    var adIndex: Int = 0
                    for data in responseData {
//                        if adIndex < 2 {
//                            adIndex+=1
//                        }
//                        else {
//                            adIndex = 1
//                            let wallpaperObj = ["id":"", "wallpaper_image":"","wallpaper_height":"","wallpaper_color":"","user_id":"","user_image":"","user_name":"","wallpaper_likes":"","wallpaper_views":"","category_name":"","isFavourite":""]
//                            self.latestWallpaperArr.append(wallpaperObj)
//                        }
                        let wallpaperObj = ["id":data["id"].stringValue,"wallpaper_image":data["wallpaper_image"].stringValue,"wallpaper_height":data["wallpaper_height"].stringValue,"wallpaper_color":data["wallpaper_color"].stringValue,"user_id":data["user_id"].stringValue,"user_image":data["user_image"].stringValue,"user_name":data["user_name"].stringValue,"wallpaper_likes":data["wallpaper_likes"].stringValue,"wallpaper_views":data["wallpaper_views"].stringValue,"category_name":data["category_name"].stringValue,"isFavourite":data["isFavourite"].stringValue]
                        self.latestWallpaperArr.append(wallpaperObj)
                    }
                    self.collection_latestwallpapers.delegate = self
                    self.collection_latestwallpapers.dataSource = self
                    self.collection_latestwallpapers.reloadData()
                }
                else if responseCode == "0" {
                    if self.pageIndex == 1 {
                        self.latestWallpaperArr.removeAll()
                    }
                    self.pageIndex = 0
                    self.collection_latestwallpapers.delegate = self
                    self.collection_latestwallpapers.dataSource = self
                    self.collection_latestwallpapers.reloadData()
                }
            }
        }
    }
    
    func Webservice_TrendingWallpapers(url:String, params:NSDictionary) -> Void {
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
                        self.trendingWallpaperArr.removeAll()
                    }
                    if responseData.count < numberOfRecords {
                        self.TrandingpageIndex = 0
                    }
                    else {
                        self.TrandingpageIndex = self.TrandingpageIndex + 1
                    }
                    for data in responseData {
                        let wallpaperObj = ["id":data["id"].stringValue,"wallpaper_image":data["wallpaper_image"].stringValue,"wallpaper_height":data["wallpaper_height"].stringValue,"wallpaper_color":data["wallpaper_color"].stringValue,"user_id":data["user_id"].stringValue,"user_image":data["user_image"].stringValue,"user_name":data["user_name"].stringValue,"wallpaper_likes":data["wallpaper_likes"].stringValue,"wallpaper_views":data["wallpaper_views"].stringValue,"category_name":data["category_name"].stringValue,"isFavourite":data["isFavourite"].stringValue]
                        self.trendingWallpaperArr.append(wallpaperObj)
                    }
                    self.collection_trendingwallpapers.delegate = self
                    self.collection_trendingwallpapers.dataSource = self
                    self.collection_trendingwallpapers.reloadData()
                }
                else if responseCode == "0" {
                    if self.TrandingpageIndex == 1 {
                        self.trendingWallpaperArr.removeAll()
                    }
                    self.TrandingpageIndex = 0
                    self.collection_trendingwallpapers.delegate = self
                    self.collection_trendingwallpapers.dataSource = self
                    self.collection_trendingwallpapers.reloadData()
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
                objVC.wallpaperArr = self.latestWallpaperArr
                objVC.wallpaperIndex = wallpaperIndex
                objVC.pageIndex = self.pageIndex
                objVC.Selectedtype = "1"
                self.navigationController?.pushViewController(objVC, animated: true)
            }
        }
    }
    func Webservice_ViewWallpaperTranding(url:String, params:NSDictionary, wallpaperIndex:IndexPath) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let objVC = self.storyboard?.instantiateViewController(withIdentifier: "WallpaperPreviewVC") as! WallpaperPreviewVC
                objVC.wallpaperArr = self.trendingWallpaperArr
                objVC.wallpaperIndex = wallpaperIndex
                objVC.pageIndex = self.pageIndex
                objVC.Selectedtype = "2"
                self.navigationController?.pushViewController(objVC, animated: true)
            }
        }
    }
}
//MARK: Admob methods
extension HomeVC: GADBannerViewDelegate {
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
