

//
//  ShowPhotoVC.swift
//  WallPaperApp
//
//  Created by Mitesh's MAC on 23/12/19.
//  Copyright © 2019 Mitesh's MAC. All rights reserved.
//

import UIKit
import iOSPhotoEditor
import MBProgressHUD
import SwiftyJSON
import GoogleMobileAds
class PreviewCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imgWallpaper: UIImageView!
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
}

class WallpaperPreviewVC: UIViewController , GADInterstitialDelegate{
    
    // Interstial
    var interstitial: GADInterstitial!
    
    //MARK: Outlets
    @IBOutlet weak var collection_wallpapers: UICollectionView!
    
    //MARK: Variables
    var wallpaperArr = [[String:String]]()
    var wallpaperIndex = IndexPath()
    var isComefrom = 0
    var pageIndex = 0
    var Selectedtype = String()
    var CategoryId = String()
    //MARK: Viewcontroller lifecycle
    var previousIndexSelected: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0..<wallpaperArr.count {
            if i < self.wallpaperArr.count {
                if self.wallpaperArr[i]["wallpaper_image"]!.isEmpty {
                    self.wallpaperArr.remove(at: i)
                }
            }
        }
        interstitial = createAndLoadInterstitial()
        print("Called now")
    }
   
    
    func createAndLoadInterstitial() -> GADInterstitial {
        var interstitial = GADInterstitial(adUnitID: AdInterstitialIdTest)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      interstitial = createAndLoadInterstitial()
    }
    
    
    override func viewWillLayoutSubviews() {
        
        if self.isComefrom == 0 {
            print("Wallpaper Index: \(self.wallpaperIndex.item) \(self.wallpaperIndex.section) \(self.wallpaperIndex.row)")
            collection_wallpapers.isPagingEnabled = false
            collection_wallpapers.scrollToItem(
                at: IndexPath(item: wallpaperIndex.item, section: wallpaperIndex.section),
                at: .centeredHorizontally,
                animated: false
            )
            collection_wallpapers.isPagingEnabled = true
        }
    }
    
}

//MARK: Actions
extension WallpaperPreviewVC {
    @IBAction func btnBack_Clicked(_ sender: UIButton) {
        if interstitial.isReady && PurchaseStatusUserDefualt.value != 1 {
          interstitial.present(fromRootViewController: self)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @objc func btnDownload_Clicked(sender: UIButton) {
        self.isComefrom = 1
        MBProgressHUD.showAdded(to:self.view, animated:true)
        if let url = URL(string: self.wallpaperArr[sender.tag]["wallpaper_image"]!),
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            MBProgressHUD.hide(for:self.view, animated:true)
            showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: "Wallpaper saved successfully to your photo library")
        }
        if interstitial.isReady {
          interstitial.present(fromRootViewController: self)
        }
        if #available( iOS 10.3,*){
        SKStoreReviewController.requestReview()
        }else{
            guard let url = URL(string: About_URL) else { return }
            UIApplication.shared.open(url)
        }
    
    }
    
    @objc func btnShare_Clicked(sender: UIButton) {
        self.isComefrom = 1
        MBProgressHUD.showAdded(to:self.view, animated:true)
        if let url = URL(string: self.wallpaperArr[sender.tag]["wallpaper_image"]!) {
            MBProgressHUD.hide(for:self.view, animated:true)
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            self.present(activityVC, animated: true)
        }
    }

    
    @objc func btnEdit_Clicked(sender: UIButton) {
        self.isComefrom = 1
        MBProgressHUD.showAdded(to:self.view, animated:true)
        if let url = URL(string: self.wallpaperArr[sender.tag]["wallpaper_image"]!),
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data) {
            MBProgressHUD.hide(for:self.view, animated:true)
            let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
            photoEditor.photoEditorDelegate = self
            photoEditor.image = image
            for i in 0...10 {
                photoEditor.stickers.append(UIImage(named: i.description )!)
            }
            photoEditor.modalPresentationStyle = UIModalPresentationStyle.currentContext
            self.present(photoEditor, animated: true, completion: nil)
        }
  
    }
}

//MARK: Collectionview methods
extension WallpaperPreviewVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.wallpaperArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collection_wallpapers.dequeueReusableCell(withReuseIdentifier: "PreviewCollectionCell", for: indexPath) as! PreviewCollectionCell
        cell.btnDownload.layer.cornerRadius = 35.0
        cell.btnShare.layer.cornerRadius = 35.0
        cell.contentView.backgroundColor = UIColor(hex: self.wallpaperArr[indexPath.item]["wallpaper_color"]!)
        cell.imgWallpaper.isHidden = true
        cell.imgWallpaper.sd_setImage(with: URL(string: self.wallpaperArr[indexPath.item]["wallpaper_image"]!)) { (image, error, cache, url) in
            cell.imgWallpaper.isHidden = false
        }
        
        cell.btnDownload.tag = indexPath.item
        cell.btnDownload.addTarget(self, action: #selector(self.btnDownload_Clicked(sender:)), for: .touchUpInside)
        cell.btnShare.tag = indexPath.item
        cell.btnShare.addTarget(self, action: #selector(self.btnShare_Clicked(sender:)), for: .touchUpInside)
        
            //cell.btnEdit.tag = indexPath.item
      //  cell.btnEdit.addTarget(self, action: #selector(self.btnEdit_Clicked(sender:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 20.0)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == self.wallpaperArr.count - 1 {
            self.wallpaperIndex = indexPath
            if self.pageIndex != 0 {
                if self.Selectedtype == "1"
                {
                    let urlString = API_URL + "wallall.php?id_cat="+Categorey_Id
                    let params: NSDictionary = ["pageIndex":"\(self.pageIndex)",
                        "numberOfRecords":numberOfRecords]
                    self.Webservice_WallpapersAllList(url: urlString, params: params)
                }
                else if self.Selectedtype == "2"
                {
                    let urlString = API_URL + "gettrendingwallpapers.php?id_cat="+Categorey_Id
                    let params: NSDictionary = ["pageIndex":"\(self.pageIndex)",
                        "numberOfRecords":numberOfRecords]
                    self.Webservice_WallpapersAllList(url: urlString, params: params)
                }
                else if self.Selectedtype == "3"
                {
                    let urlString = API_URL + "getwallpaperbycategory.php"
                    
                    let params: NSDictionary = ["pageIndex":"\(self.pageIndex)",
                        "numberOfRecords":numberOfRecords,"category_id":self.CategoryId]
                    self.Webservice_WallpapersAllList(url: urlString, params: params)
                }
            }
        }
    }
}

//MARK: Functions
extension WallpaperPreviewVC: PhotoEditorDelegate {
    func doneEditing(image: UIImage) {
        print("DoneEditing")
    }
    
    func canceledEditing() {
        print("CancelledEditing")
    }
    
    func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
    
}

//MARK: Webservices
extension WallpaperPreviewVC {
    func Webservice_FavouriteUnfavouriteWallpaper(url:String, params:NSDictionary, wallpaperIndex:Int, isFavourite:String) -> Void {
        WebServices().CallGlobalAPI(url: url, headers: [:], parameters:params, httpMethod: "POST", progressView:true, uiView:self.view, networkAlert: true) {(_ jsonResponse:JSON? , _ strErrorMessage:String) in
            
            if strErrorMessage.count != 0 {
                showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: strErrorMessage)
            }
            else {
                print(jsonResponse!)
                let responseCode = jsonResponse!["ResponseCode"].stringValue
                if responseCode == "1" {
                    let wallpaperObj = ["id":self.wallpaperArr[wallpaperIndex]["id"]!,"wallpaper_image":self.wallpaperArr[wallpaperIndex]["wallpaper_image"]!,"wallpaper_height":self.wallpaperArr[wallpaperIndex]["wallpaper_height"]!,"wallpaper_color":self.wallpaperArr[wallpaperIndex]["wallpaper_color"]!,"user_id":self.wallpaperArr[wallpaperIndex]["user_id"]!,"user_image":self.wallpaperArr[wallpaperIndex]["user_image"]!,"user_name":self.wallpaperArr[wallpaperIndex]["user_name"]!,"wallpaper_likes":self.wallpaperArr[wallpaperIndex]["wallpaper_likes"]!,"wallpaper_views":self.wallpaperArr[wallpaperIndex]["wallpaper_views"]!,"category_name":self.wallpaperArr[wallpaperIndex]["category_name"]!,"isFavourite":isFavourite]
                    self.wallpaperArr.remove(at: wallpaperIndex)
                    self.wallpaperArr.insert(wallpaperObj, at: wallpaperIndex)
                    self.collection_wallpapers.reloadData()
                }
                else {
                    showAlertMessage(titleStr: Bundle.main.displayName!, messageStr: jsonResponse!["ResponseMessage"].stringValue)
                }
            }
        }
    }
    func Webservice_WallpapersAllList(url:String, params:NSDictionary) -> Void {
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
                    print(self.wallpaperArr.count)
                    self.collection_wallpapers.reloadData()
                    self.collection_wallpapers.scrollToItem(at: self.wallpaperIndex, at: .right, animated: true)
                    
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
}

extension WallpaperPreviewVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for cell in collection_wallpapers.visibleCells {
            let indexPath = collection_wallpapers.indexPath(for: cell)
            print("Index Path: \(indexPath?.row ?? 0), \(self.previousIndexSelected)")
            let index: Int = indexPath?.row ?? 0
            if index - 5 == previousIndexSelected && indexPath?.row ?? 0 != 0 {
                previousIndexSelected = indexPath?.row ?? 0
            }
        }
    }
}
