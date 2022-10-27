//
//  ViewController.swift
//  WallPaperApp
//
//  Created by Mitesh's MAC on 20/12/19.
//  Copyright © 2019 Mitesh's MAC. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class WelcomeVC: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var img_random: UIImageView!
    @IBOutlet weak var btnLogin: UIButton!
    
    //MARK: Variables
    var imageTimer = Timer()
    
    //MARK: Viewcontroller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnLogin.layer.cornerRadius = 8.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.changeImage()
        self.imageTimer.invalidate()
        self.imageTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        self.imageTimer.invalidate()
    }
    
}

//MARK: Functions
extension WelcomeVC {
    @objc func changeImage() {
        let images: [UIImage] = [UIImage(named: "ic_background1")!,UIImage(named: "ic_background2")!,UIImage(named: "ic_background3")!,UIImage(named: "ic_background4")!,UIImage(named: "ic_background5")!]
        self.img_random.image = images.shuffled().randomElement()
    }
}

//MARK: Actions
extension WelcomeVC {
    @IBAction func btnLogin_Clicked(_ sender: UIButton) {
        UserDefaults.standard.set("0", forKey: UD_userId)
//        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        let sidemenuVC = self.storyboard?.instantiateViewController(withIdentifier: "BubbleTabBarController") as! BubbleTabBarController
        let appNavigation: UINavigationController = UINavigationController(rootViewController: sidemenuVC)
        appNavigation.setNavigationBarHidden(true, animated: true)
//        let slideMenuController = SlideMenuController(mainViewController: appNavigation, leftMenuViewController: sidemenuVC)
//        slideMenuController.changeLeftViewWidth(UIScreen.main.bounds.width * 0.8)
//        slideMenuController.removeLeftGestures()
        UIApplication.shared.windows[0].rootViewController = appNavigation
        
//        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
//        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
//    @IBAction func btnRegister_Clicked(_ sender: UIButton) {
//        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
//        self.navigationController?.pushViewController(objVC, animated: true)
//    }
//
//    @IBAction func btnSkip_Clicked(_ sender: UIButton) {
//        UserDefaults.standard.set("0", forKey: UD_userId)
//        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
//        let sidemenuVC = self.storyboard?.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
//        let appNavigation: UINavigationController = UINavigationController(rootViewController: objVC)
//        appNavigation.setNavigationBarHidden(true, animated: true)
//        let slideMenuController = SlideMenuController(mainViewController: appNavigation, leftMenuViewController: sidemenuVC)
//        slideMenuController.changeLeftViewWidth(UIScreen.main.bounds.width * 0.8)
//        slideMenuController.removeLeftGestures()
//        UIApplication.shared.windows[0].rootViewController = slideMenuController
//    }
}
