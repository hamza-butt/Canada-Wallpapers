
import Foundation
import UIKit

//MARK: Domain urls
let API_URL = "https://lnkoshop.com/wallpaper/api/"
let Privacy_URL = "https://lnkoshop.com/wallpaper/privacy_policy.html"
let About_URL = "https://apps.apple.com/us/app/id1616537687"
let term_Of_Service = "https://lnkoshop.com/wallpaper/terms-of-use.html"
let Categorey_Id = "37"
let OneSignalKey = "c60b1995-a067-42b4-9803-72b98b3faca1"



//MARK: Admob variables
//let AdBannerIdTest = "ca-app-pub-7368160219570936/6793589858"
//let AdInterstitialIdTest = "ca-app-pub-7368160219570936/1107230475"


let AdBannerIdTest = "ca-app-pub-7368160219570936/6793589858"
let AdInterstitialIdTest = "ca-app-pub-7368160219570936/1107230475"





//MARK: Other constants
let numberOfRecords = 10
let MESSAGE_ERR_NETWORK = "No internet connection. Try again.."



//MARK: Userdefaults
let UD_userId = "UD_userId"
let UD_isTutorial = "UD_isTutorial"
let UD_FcmToken = "UD_FcmToken"
let PurpleColor = Color_RGBA(0, 0, 0, 1)
let Appcolor = UIColor(hex:"000000")


//MARK: Comman functions & Extensions
func showAlertMessage(titleStr:String, messageStr:String) -> Void {
    DispatchQueue.main.async {
        let alert = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertController.Style.alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        UIApplication.shared.windows[0].rootViewController!.present(alert, animated: true, completion: nil)
    }
}
//MARK:- COLOR RGB
 func Color_RGBA(_ R: Int,_ G: Int,_ B: Int,_ A: Int) -> UIColor
{
    return UIColor(red: CGFloat(R)/255.0, green: CGFloat(G)/255.0, blue: CGFloat(B)/255.0, alpha :CGFloat(A))
}
func randomString(length: Int) -> String {
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    var randomString = ""
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    return randomString
}

enum HttpResponseStatusCode: Int {
    case ok = 200
    case badRequest = 400
    case noAuthorization = 401
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        return nil
    }
}

extension UIImage {
    var averageColor: String {
        guard let inputImage = CIImage(image: self) else { return "" }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return "" }
        guard let outputImage = filter.outputImage else { return "" }
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        let hexValue = "#" + String(format:"%02x", Int(bitmap[0])) + String(format:"%02x", Int(bitmap[1])) + String(format:"%02x", Int(bitmap[2])) +    String(format:"%02x", Int(bitmap[3]))
        return hexValue
    }
}

extension String {
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
        let emailTest  = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
}

extension Bundle {
    var displayName: String? {
        return infoDictionary?["CFBundleName"] as? String
    }
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
