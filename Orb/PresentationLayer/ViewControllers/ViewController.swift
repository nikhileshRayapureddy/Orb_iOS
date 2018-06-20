//
//  ViewController.swift
//  Orb
//
//  Created by Nikhilesh on 18/04/18.
//  Copyright © 2018 Nikhilesh. All rights reserved.
//

import UIKit
import AVKit
import Kingfisher
import CoreLocation

let BANNERTYPE_LEFT_L = "LEFT L-Banner";
let BANNERTYPE_LEFT_L_GIF = "LEFT L-Banner Gif";
let BANNERTYPE_RIGHT_L = "RIGHT L-Banner";
let BANNERTYPE_RIGHT_L_GIF = "RIGHT L-Banner Gif";
let BANNERTYPE_U = "U-Banner";
let BANNERTYPE_U_GIF = "U-Banner Gif";
let BANNERTYPE_IMAGE_AD_GIF = "IMAGE AD GIF";
let BANNERTYPE_PLAIN = "Plain Banner";
let BANNERTYPE_WEB_VIEW = "Web View";
let BANNERTYPE_VERTICAL = "Vertical Banner";
let BANNERTYPE_VERTICAL_GIF = "Vertical Banner Gif";

protocol ViewControllerDelegate
{
    func selectedVideoWithURL(strUrl : String)
}
class ViewController: BaseViewController {
    @IBOutlet weak var lblLoading: UILabel!
    var playerLayer : AVPlayerLayer!
    var player : AVQueuePlayer!
    var slider : UISlider!
    var btnPlay:UIButton?
    var btnPrev:UIButton?
    var btnNext:UIButton?
    var btnHome:UIButton?
    var btnVolume:UIButton?
    var playbackSlider : UISlider!
    var delegate:ViewControllerDelegate!
    var prevItem:AVPlayerItem!
    var vwHome : HomeCustomView!
    var vwSleep : SleepCustomView!
    var arrAdBanners = [BannerBO]()
    var arrBanners = [BannerBO]()
    var arrTrending = [ContentBO]()
    var currentBanner = 0
    var arrRadio = [RadioBO]()
    var arrContent = [ContentBO]()
    var currentIndex = 0
    var currentPlayingIndex = 0
    var arrLocalURL = [String]()
    var isControlViewHidden = false
    var volumeSlider : UISlider!
    let locationManager = CLLocationManager()
    var arrBannerURLS = [""]
    var UDID = ""
    var isLocationAccessed = false
    var batterLevel:Float = 0.0
    var freeSpace:Int64 = 0
    var isFirstTime = false
    var coordinate = CLLocationCoordinate2D()
    var isHomeCVLoaded = false

    let picker = UIPickerView()
    var selectedPickerRow = 0
    var vwSep = UIView()
    var arrCities = ["Hyderabad","Delhi","Mumbai"]
    var vwRegistration :RegistrationCustomView!
    var isContentDownloaded = false
    var adBannerIndex = 0
    var imgAdBanner : UIImageView!
    var imgAdPlainBanner : UIImageView!
    var adBannerTimer : Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Keychain.removeUDID(service: "Orb", account: "OrbAccount")
        if let str = Keychain.loadUDID(service: "Orb", account: "OrbAccount")
        {
            UDID = str
        }
        else
        {
            UDID = self.randomAlphaNumericString(length: 16)
            Keychain.saveUDID(service: "Orb", account: "OrbAccount", data: UDID)
        }
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        batterLevel = UIDevice.current.batteryLevel
        
        if let bytes = deviceRemainingFreeSpaceInBytes() {
            print("free space: \(bytes)")
            print("free space in MB: \(bytes/1024/1024)")
            print("free space in GB: \(bytes/1024/1024/1024)")
            freeSpace = bytes/1024/1024
        } else {
            print("failed")
        }
        if UIScreen.main.brightness == 0.0
        {
            print("Locked")
        }
        else
        {
            print("Unlocked")
        }
        
        
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(not:)), name: Notification.Name("ServerActive"), object: nil)

    }
    @objc func reloadData(not : NSNotification)
    {
        DispatchQueue.main.async {
            NotificationCenter.default.addObserver(self, selector: #selector(self.selectedVideo(not:)), name: Notification.Name("VideoSelection"), object: nil)
            self.lblLoading.isHidden = false
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                // process files
                if fileURLs.count > 0
                {
                    for url in fileURLs
                    {
                        self.arrLocalURL.append(url.absoluteString)
                        if self.currentIndex == 0
                        {
                            DispatchQueue.main.async {
                                self.downloadComplete()
                                self.lblLoading.isHidden = true
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                let playerItem:AVPlayerItem = AVPlayerItem(asset: AVAsset(url: url))
                                self.player.insert(playerItem, after: self.prevItem)
                                self.prevItem = playerItem
                            }
                        }
                        self.currentIndex = self.currentIndex + 1
                    }
                }
                
            } catch {
                print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
            }
        }
        self.getContentFromServer()
    }
    func deleteVideoFromDocuments()
    {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            // process files
            var arrVideos = [String]()
            for url in fileURLs
            {
                arrVideos.append(url.absoluteString.components(separatedBy: "Documents/")[1])
            }
            print("fileURLs : \(arrVideos)")
            
            for video in arrVideos
            {
                let arrFiltered = self.arrContent.filter({ (bo) -> Bool in
                    return bo.FileKey + ".mp4" == video
                })
                if arrFiltered.count <= 0
                {
                    if video != ".DS_Store"
                    {
                        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
                        let destinationFileUrl = documentsUrl.appendingPathComponent(video)
                        if FileManager.default.fileExists(atPath: destinationFileUrl.path) {
                            try! FileManager.default.removeItem(at: destinationFileUrl)
                        }
                    }
                }
            }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
    func getRadio()
    {
        let lat = String(coordinate.latitude)
        let long = String(coordinate.longitude)
        let layer = ServiceLayer()
        layer.getRadioContent(lat:lat,long:long,successMessage: { (response) in
            DispatchQueue.main.async {
                self.vwHome.arrRadio = response as! [RadioBO]
                self.vwHome.clvwMixedContent.reloadData()
            }
        }) { (error) in
            DispatchQueue.main.async {
                
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    @objc func selectedVideo(not : NSNotification)
    {
        if let content = not.userInfo?["data"] as? ContentBO {
            let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
            let destinationFileUrl = documentsUrl.appendingPathComponent("\(content.FileKey).mp4")
            if FileManager.default.fileExists(atPath: destinationFileUrl.path) {
                print("file already exist at \(destinationFileUrl)")
                let indexedItem = AVPlayerItem(asset: AVAsset(url: destinationFileUrl))
                self.player.remove(indexedItem)
                self.player.insert(indexedItem, after: self.player.currentItem)
                self.player.advanceToNextItem()
                self.vwHome.btnCloseMenuClicked(UIButton())
            }
        }
        
    }
    func downloadBanners()
    {
        let imgVwBanner = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        imgVwBanner.backgroundColor = UIColor.clear
        self.view.addSubview(imgVwBanner)
        
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        let destinationFileUrl = documentsUrl.appendingPathComponent("Banner.jpg")
        let fileURL = URL(string: arrBannerURLS[0])
        if FileManager.default.fileExists(atPath: destinationFileUrl.path) {
            print("file already exist at \(destinationFileUrl)")
            imgVwBanner.image = UIImage(contentsOfFile: destinationFileUrl.path)
            return
        }
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request = URLRequest(url:fileURL!)
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                    DispatchQueue.main.async {
                        imgVwBanner.image = UIImage(contentsOfFile: destinationFileUrl.path)
                    }
                    print("File downloaded")
                    
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }
                
            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription ?? "");
            }
        }
        task.resume()
        
    }
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider)
    {
        
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(seconds, 1)
        
        player!.seek(to: targetTime)
        
        if player!.rate == 0
        {
            player?.play()
        }
    }
    
    
    @objc func btnPlayTapped(_ sender:UIButton)
    {
        if player?.rate == 0
        {
            player!.play()
            //playButton!.setImage(UIImage(named: "player_control_pause_50px.png"), forState: UIControlState.Normal)
            btnPlay?.isSelected = true
        } else {
            player!.pause()
            //playButton!.setImage(UIImage(named: "player_control_play_50px.png"), forState: UIControlState.Normal)
            btnPlay?.isSelected = false
        }
    }
    @objc func btnPrevTapped(_ sender:UIButton)
    {
        let targetTime:CMTime = CMTimeMake(Int64(player.currentTime().seconds)-5,1)
        player!.seek(to: targetTime)
        
        if player!.rate == 0
        {
            player?.play()
        }
    }
    @objc func btnNextTapped(_ sender:UIButton)
    {
        let targetTime:CMTime = CMTimeMake(Int64(player.currentTime().seconds) + 5, 1)
        let duration = CMTimeGetSeconds((player.currentItem?.asset.duration)!)
        let currentTime = Float64(player.currentTime().seconds) + 5
        print("duration : \(duration)")
        print("currentTime : \(currentTime)")

        if currentTime >= duration
        {
            let index = player.items().index(of: player.currentItem!)! + 1
            let nextItem = player.items()[index]
            let duration : CMTime = nextItem.asset.duration
            let seconds : Float64 = CMTimeGetSeconds(duration)
            self.playbackSlider.maximumValue = Float(seconds)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nextItem)
            player.advanceToNextItem()
        }
        else
        {
            player!.seek(to: targetTime)
            
            if player!.rate == 0
            {
                player?.play()
            }
        }
    }
    @objc func playerDidFinishPlaying(note: NSNotification) {
        
        currentPlayingIndex = currentPlayingIndex + 1
        if currentPlayingIndex >= arrLocalURL.count
        {
            currentPlayingIndex = 0
            self.downloadComplete()
            return
        }
        let index = player.items().index(of: player.currentItem!)! + 1
        let nextItem = player.items()[index]
        let duration : CMTime = nextItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        self.playbackSlider.maximumValue = Float(seconds)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nextItem)
        
        print("Video Finished : \(seconds)")
    }
    
    
    func showFullScreen()
    {
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { (timer) in
                UIView.animate(withDuration: 0.8) {
                    self.playerLayer.frame = self.view.bounds
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    @objc func showAdBanner()
    {
        if Thread.current != Thread.main
        {
            DispatchQueue.main.async {
                self.showAdBanner()
                return
            }
        }
        if arrAdBanners.count <= 0 || self.imgAdBanner == nil || self.imgAdPlainBanner == nil
        {
            return
        }
        if adBannerIndex >= arrAdBanners.count
        {
            adBannerIndex = 0
        }
        let bo = arrAdBanners[adBannerIndex]
        let bannerBo = CoreDataAccessLayer.sharedInstance.getBannersFromLocalDBWith(fileKey: bo.FileKey)
        if bannerBo.showCount >= bannerBo.count
        {
            arrAdBanners.remove(at: arrAdBanners.index(of: bo)!)
            self.showAdBanner()
            return
        }
        print("AdFileType : \(bo.AdFileType)")
        self.imgAdBanner.isHidden = true
        self.imgAdPlainBanner.isHidden = true
        self.btnVolume?.frame = CGRect(x: 864, y: (self.btnVolume?.frame.origin.y)!, width: 50, height: 50)
        self.btnHome?.frame = CGRect(x: 944, y: (self.btnVolume?.frame.origin.y)!, width: 50, height: 50)
        if let vw = self.view.viewWithTag(8050)
        {
            vw.frame = CGRect(x:self.view.bounds.size.width - 160, y: 100, width: 56, height: self.view.bounds.size.height - 355)
        }

        if bo.AdFileType == BANNERTYPE_U
        {
            self.imgAdBanner.image = #imageLiteral(resourceName: "U_Banner")
            self.imgAdBanner.isHidden = false
            self.btnVolume?.frame = CGRect(x: 764, y: (self.btnVolume?.frame.origin.y)!, width: 50, height: 50)
            self.btnHome?.frame = CGRect(x: 834, y: (self.btnVolume?.frame.origin.y)!, width: 50, height: 50)
            if let vw = self.view.viewWithTag(8050)
            {
                vw.frame = CGRect(x:ScreenWidth - 258, y: 100, width: 56, height: self.view.bounds.size.height - 355)
            }

        }
        else if bo.AdFileType == BANNERTYPE_U_GIF
        {
            self.imgAdBanner.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
            self.imgAdBanner.image = #imageLiteral(resourceName: "U_Banner")
            self.imgAdBanner.isHidden = false
            self.btnVolume?.frame = CGRect(x: 764, y: (self.btnVolume?.frame.origin.y)!, width: 50, height: 50)
            self.btnHome?.frame = CGRect(x: 834, y: (self.btnVolume?.frame.origin.y)!, width: 50, height: 50)
            if let vw = self.view.viewWithTag(8050)
            {
                vw.frame = CGRect(x:ScreenWidth - 258, y: 100, width: 56, height: self.view.bounds.size.height - 355)
            }

        }
        else if bo.AdFileType == BANNERTYPE_LEFT_L
        {
            self.imgAdBanner.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
            self.imgAdBanner.image = #imageLiteral(resourceName: "LBanner_Left")
            self.imgAdBanner.isHidden = false
        }
        else if bo.AdFileType == BANNERTYPE_RIGHT_L
        {
            self.imgAdBanner.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
            self.imgAdBanner.image = #imageLiteral(resourceName: "LBanner_Right")
            self.imgAdBanner.isHidden = false
        }
        else if bo.AdFileType == BANNERTYPE_VERTICAL
        {
            self.imgAdBanner.frame = CGRect(x: 0, y: 0, width: 120, height: ScreenHeight)
            self.imgAdBanner.image = #imageLiteral(resourceName: "Vertical_Banner")
            self.imgAdBanner.isHidden = false
        }
        else if bo.AdFileType == BANNERTYPE_LEFT_L_GIF
        {
            self.imgAdBanner.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
            self.imgAdBanner.image = #imageLiteral(resourceName: "LBanner_Left")
            self.imgAdBanner.isHidden = false
        }
        else if bo.AdFileType == BANNERTYPE_RIGHT_L_GIF
        {
            self.imgAdBanner.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
            self.imgAdBanner.image = #imageLiteral(resourceName: "LBanner_Right")
            self.imgAdBanner.isHidden = false
        }
        else if bo.AdFileType == BANNERTYPE_VERTICAL_GIF
        {
            self.imgAdBanner.frame = CGRect(x: 0, y: 0, width: 120, height: ScreenHeight)
            self.imgAdBanner.image = #imageLiteral(resourceName: "Vertical_Banner")
            self.imgAdBanner.isHidden = false
        }
        else if bo.AdFileType == BANNERTYPE_IMAGE_AD_GIF
        {
            self.imgAdPlainBanner.frame = CGRect(x: 110, y: ScreenHeight - 200, width: 804, height: 140)
            self.imgAdPlainBanner.image = #imageLiteral(resourceName: "Plain_Banner")
            self.imgAdPlainBanner.isHidden = false
        }
        else if bo.AdFileType == BANNERTYPE_PLAIN
        {
            self.imgAdPlainBanner.frame = CGRect(x: 110, y: ScreenHeight - 200, width: 804, height: 140)
            self.imgAdPlainBanner.image = #imageLiteral(resourceName: "Plain_Banner")
            self.imgAdPlainBanner.isHidden = false
        }
        else if bo.AdFileType == BANNERTYPE_WEB_VIEW
        {
            self.imgAdPlainBanner.frame = CGRect(x: 110, y: ScreenHeight - 200, width: 804, height: 140)
            self.imgAdPlainBanner.image = #imageLiteral(resourceName: "Plain_Banner")
            self.imgAdPlainBanner.isHidden = false
        }
        self.adBannerIndex = self.adBannerIndex + 1
        bannerBo.showCount = bannerBo.showCount + 1
        CoreDataAccessLayer.sharedInstance.updateBannerItemWith(tmpItem: bannerBo)
        UIView.animate(withDuration: 0.8) {
            self.imgAdBanner.sendSubview(toBack: self.view)
            if bo.AdFileType == BANNERTYPE_U
            {
                self.playerLayer.frame = CGRect(x: 120, y: 0, width: ScreenWidth - 240, height: ScreenHeight - 120)
            }
            else if bo.AdFileType == BANNERTYPE_U_GIF
            {
                self.playerLayer.frame = CGRect(x: 120, y: 0, width: ScreenWidth - 240, height: ScreenHeight - 120)
            }
            else if bo.AdFileType == BANNERTYPE_LEFT_L
            {
                self.playerLayer.frame = CGRect(x: 120, y: 0, width: ScreenWidth - 120, height: ScreenHeight - 120)
            }
            else if bo.AdFileType == BANNERTYPE_RIGHT_L
            {
                self.playerLayer.frame = CGRect(x: 0, y: 0, width: ScreenWidth - 120, height: ScreenHeight - 120)
            }
            else if bo.AdFileType == BANNERTYPE_VERTICAL
            {
                self.playerLayer.frame = CGRect(x: 120, y: 0, width: ScreenWidth - 120, height: ScreenHeight)
            }
            else if bo.AdFileType == BANNERTYPE_LEFT_L_GIF
            {
                self.playerLayer.frame = CGRect(x: 120, y: 0, width: ScreenWidth - 120, height: ScreenHeight - 120)
            }
            else if bo.AdFileType == BANNERTYPE_RIGHT_L_GIF
            {
                self.playerLayer.frame = CGRect(x: 0, y: 0, width: ScreenWidth - 120, height: ScreenHeight - 120)
            }
            else if bo.AdFileType == BANNERTYPE_VERTICAL_GIF
            {
                self.playerLayer.frame = CGRect(x: 120, y: 0, width: ScreenWidth - 120, height: ScreenHeight)
            }
            else if bo.AdFileType == BANNERTYPE_IMAGE_AD_GIF
            {
                self.playerLayer.frame = CGRect(x: 0, y: 0, width: ScreenWidth , height: ScreenHeight)
            }
            else if bo.AdFileType == BANNERTYPE_PLAIN
            {
                self.playerLayer.frame = CGRect(x: 0, y: 0, width: ScreenWidth , height: ScreenHeight)
            }
            else if bo.AdFileType == BANNERTYPE_WEB_VIEW
            {
                self.playerLayer.frame = CGRect(x: 0, y: 0, width: ScreenWidth , height: ScreenHeight)
            }

        }

//        self.imgAdBanner.kf.setImage(with: URL(string: bo.FileUrl), placeholder: UIImage(), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
//        }, completionHandler: { image, error, cacheType, imageURL in
//            DispatchQueue.main.async {
//                self.adBannerIndex = self.adBannerIndex + 1
//            }
//        })


    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func download() {
        if currentIndex >= arrContent.count
        {
            currentIndex = 0
            isContentDownloaded = true
            return
        }
        let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
        let destinationFileUrl = documentsUrl.appendingPathComponent("\(arrContent[currentIndex].FileKey).mp4")
        let fileURL = URL(string: arrContent[currentIndex].FileUrl)
        
        if FileManager.default.fileExists(atPath: destinationFileUrl.path) {
            print("file already exist at \(destinationFileUrl)")
            self.currentIndex = self.currentIndex + 1
            self.download()
            return
        }
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request = URLRequest(url:fileURL!)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                    self.arrLocalURL.append(destinationFileUrl.absoluteString)
                    if self.currentIndex < self.arrContent.count
                    {
                        if self.currentIndex == 0
                        {
                            DispatchQueue.main.async {
                                self.downloadComplete()
                                self.lblLoading.isHidden = true
                            }
                            
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                let playerItem:AVPlayerItem = AVPlayerItem(asset: AVAsset(url: destinationFileUrl))
                                self.player.insert(playerItem, after: self.prevItem)
                                self.prevItem = playerItem
                            }
                            
                        }
                        self.currentIndex = self.currentIndex + 1
                        self.download()
                    }
                    
                    print("File downloaded")
                    
                } catch (let writeError) {
                    if self.currentIndex < self.arrContent.count
                    {
                        self.currentIndex = self.currentIndex + 1
                        self.download()
                    }
                    
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }
                
            } else {
                if self.currentIndex < self.arrContent.count
                {
                    self.currentIndex = self.currentIndex + 1
                    self.download()
                }
                
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription ?? "");
            }
        }
        task.resume()
    }

    
    func downloadComplete()
    {
        if self.imgAdBanner == nil{
            imgAdBanner = UIImageView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
            imgAdBanner.backgroundColor = UIColor.clear
            imgAdBanner.contentMode = .scaleAspectFit
            self.view.addSubview(imgAdBanner)
        }

        let playerItem:AVPlayerItem = AVPlayerItem(asset: AVAsset(url: URL(string: arrLocalURL[0])!))
        self.player = AVQueuePlayer(playerItem: playerItem)
        self.player.volume = 0.5
        
        self.playerLayer = AVPlayerLayer(player: self.player)
        self.playerLayer.videoGravity = .resizeAspectFill
        self.playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(self.playerLayer)
        self.player?.play()
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
        
        let vwBase = UIView(frame: CGRect(x: 0, y: 0, width: 450, height: 250))
        vwBase.backgroundColor = UIColor.clear
        vwBase.tag = 9050
        vwBase.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
        self.view.addSubview(vwBase)
        
        btnPrev = UIButton(type: UIButtonType.custom)
        btnPrev?.frame = CGRect(x:0, y:0, width:100, height:100)
        btnPrev?.backgroundColor = UIColor.clear
        btnPrev?.setImage(#imageLiteral(resourceName: "rewind_h"), for: .normal)
        btnPrev?.addTarget(self, action: #selector(self.btnPrevTapped(_:)), for: .touchUpInside)
        vwBase.addSubview(btnPrev!)
        
        btnPlay = UIButton(type: UIButtonType.custom)
        btnPlay?.frame = CGRect(x:175, y:0, width:100, height:100)
        btnPlay?.backgroundColor = UIColor.clear
        btnPlay?.setImage(#imageLiteral(resourceName: "play_h"), for: .normal)
        btnPlay?.setImage(#imageLiteral(resourceName: "pause_h"), for: .selected)
        btnPlay?.isSelected = true
        btnPlay?.addTarget(self, action: #selector(self.btnPlayTapped(_:)), for: .touchUpInside)
        vwBase.addSubview(btnPlay!)
        
        btnNext = UIButton(type: UIButtonType.custom)
        btnNext?.frame = CGRect(x:350, y:0, width:100, height:100)
        btnNext?.backgroundColor = UIColor.clear
        btnNext?.setImage(#imageLiteral(resourceName: "forward_h"), for: .normal)
        btnNext?.addTarget(self, action: #selector(self.btnNextTapped(_:)), for: .touchUpInside)
        vwBase.addSubview(btnNext!)
        
        
        // Add playback slider
        let vwSliderBase = UIView(frame: CGRect(x: 0, y: 170, width: vwBase.frame.size.width, height: 80))
        vwSliderBase.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        vwSliderBase.layer.cornerRadius = 5
        vwSliderBase.layer.masksToBounds = true
        vwBase.addSubview(vwSliderBase)

        
        playbackSlider = UISlider(frame:CGRect(x:10, y:15, width:vwBase.frame.size.width - 20, height:20))
        playbackSlider.minimumValue = 0
        playbackSlider.isContinuous = true
        playbackSlider.tintColor = UIColor.black
        playbackSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
        // playbackSlider.addTarget(self, action: "playbackSliderValueChanged:", forControlEvents: .ValueChanged)
        vwSliderBase.addSubview(playbackSlider)
        
        let lblTime = UILabel(frame: CGRect(x: 0, y: 40, width: vwSliderBase.frame.size.width, height: 30))
        lblTime.backgroundColor = UIColor.clear
        lblTime.textColor = UIColor.black
        lblTime.text = "00:00/00:00"
        lblTime.textAlignment = .center
        vwSliderBase.addSubview(lblTime)

        
        if #available(iOS 10.0, *) {
            do {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                    DispatchQueue.main.async {
                        
                        if let cTime = self.player.currentItem?.currentTime().seconds ,let dur = self.player.currentItem?.duration.seconds
                        {
                            if !cTime.isNaN && !dur.isNaN
                            {
                                let strCT = String(format:"%02d:%02d",Int64(cTime)/60,Int64(cTime)%60)
                                let strDur = String(format:"%02d:%02d",Int64(dur)/60,Int64(dur)%60)
                                lblTime.text = "\(strCT) / \(strDur) "
                            }
                        }
                    }
                })
            }
            
        } else {
            Timer.scheduledTimer(timeInterval: 1,
                                 target: self,
                                 selector: #selector(self.updateTime(timer:)),
                                 userInfo: ["label":lblTime],
                                 repeats: true)
            
        }
        

        btnHome = UIButton(type: UIButtonType.custom)
        btnHome?.frame = CGRect(x:self.view.bounds.size.width - 80, y:20, width:50, height:50)
        btnHome?.backgroundColor = UIColor.clear
        btnHome?.setImage(#imageLiteral(resourceName: "home"), for: .normal)
        if isHomeCVLoaded == false
        {
            btnHome?.isHidden = true
        }
        btnHome?.addTarget(self, action: #selector(self.btnHomeClicked(_:)), for: .touchUpInside)
        self.view.addSubview(btnHome!)
        
        btnVolume = UIButton(type: UIButtonType.custom)
        btnVolume?.frame = CGRect(x:(btnHome?.frame.origin.x)! - 80, y:20, width:50, height:50)
        if isHomeCVLoaded == false
        {
            btnVolume?.isHidden = true
        }
        btnVolume?.backgroundColor = UIColor.clear
        btnVolume?.setImage(#imageLiteral(resourceName: "Volume"), for: .normal)
        btnVolume?.addTarget(self, action: #selector(self.btnVolumeClicked(_:)), for: .touchUpInside)
        self.view.addSubview(btnVolume!)
        

        let duration : CMTime = playerItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        self.playbackSlider.maximumValue = Float(seconds)
        self.player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player!.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                self.playbackSlider.value = Float ( time );
            }
        }
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureRecognised(sender:)))
        gesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(gesture)
        if self.imgAdPlainBanner == nil{
            imgAdPlainBanner = UIImageView(frame: CGRect(x: (ScreenWidth-800)/2, y: ScreenHeight-180, width: 800, height: 120))
            imgAdPlainBanner.backgroundColor = UIColor.clear
            imgAdPlainBanner.contentMode = .scaleAspectFit
            self.view.addSubview(imgAdPlainBanner)
            self.imgAdPlainBanner.isHidden = true
        }

//        self.showAdBanner()
        
    }
    @objc func updateTime(timer:Timer)
    {
        if let cTime = self.player.currentItem?.currentTime().seconds ,let dur = self.player.currentItem?.duration.seconds
        {
            if !cTime.isNaN && !dur.isNaN
            {
                let formatter = NumberFormatter()
                formatter.minimumIntegerDigits = 2

                let strCT = "\(formatter.string(from: NSNumber(value: Int(cTime)/60)) ?? "00"):\(formatter.string(from: NSNumber(value: Int(cTime)%60)) ?? "00")"
                let strDur = "\(formatter.string(from: NSNumber(value: Int(dur)/60)) ?? "00"):\(formatter.string(from: NSNumber(value: Int(dur)%60)) ?? "00")"
                let dict = timer.userInfo as! [String:UILabel]
                if let lblTime = dict["label"]
                {
                    DispatchQueue.main.async {
                        lblTime.text = "\(strCT) / \(strDur) "
                    }
                }
            }
        }

    }
    @objc func tapGestureRecognised(sender:UITapGestureRecognizer)
    {
        let vwBase = self.view.viewWithTag(9050)
        let vwVolBase = self.view.viewWithTag(8050)
        vwVolBase?.isHidden = true
        
        if isControlViewHidden
        {
            print("show view")
            vwBase?.isHidden = false
        }
        else
        {
            print("Hide view")
            vwBase?.isHidden = true
        }
        isControlViewHidden = !isControlViewHidden
    }
    @objc func btnVolumeClicked(_ sender:UIButton)
    {
        
        let vwBase = self.view.viewWithTag(8050)
        if vwBase == nil
        {
            let vwVolBase = UIView(frame: CGRect(x:self.view.bounds.size.width - 160, y: 100, width: 56, height: self.view.bounds.size.height - 355))
            vwVolBase.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            vwVolBase.layer.cornerRadius = 5.0
            vwVolBase.layer.masksToBounds = true
            vwVolBase.tag = 8050
            self.view.addSubview(vwVolBase)
            
            
            volumeSlider = UISlider(frame:CGRect(x:-(self.view.bounds.size.height - 505)/2, y:150, width:self.view.bounds.size.height - 450, height:40))
            volumeSlider.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
            volumeSlider.minimumValue = 0
            volumeSlider.value = 0.5
            volumeSlider.isContinuous = true
            volumeSlider.tintColor = UIColor.black
            volumeSlider.addTarget(self, action: #selector(self.volumeSliderValueChanged(_:)), for: .valueChanged)
            vwVolBase.addSubview(volumeSlider)
            
            let btnSleep = UIButton(type:UIButtonType.custom)
            btnSleep.frame = CGRect(x: 0, y: vwVolBase.frame.size.height - 80, width: 56, height: 80)
            btnSleep.backgroundColor = UIColor.clear
            btnSleep.contentMode = .scaleAspectFit
            btnSleep.setImage(#imageLiteral(resourceName: "Sleep"), for: .normal)
            btnSleep.addTarget(self, action: #selector(self.btnSleepClicked(_:)), for: .touchUpInside)
            vwVolBase.addSubview(btnSleep)
        }
        else
        {
            vwBase?.bringSubview(toFront: self.view)
            vwBase?.isHidden = false
        }
    }
    @objc func btnSleepClicked(_ sender:UIButton)
    {
        self.tapGestureRecognised(sender: UITapGestureRecognizer())
        if vwSleep != nil
        {
            vwSleep.bringSubview(toFront: self.view.window!)
            self.player.pause()
            UIView.animate(withDuration: 0.3, animations: {
                self.vwSleep.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
                self.vwSleep.alpha = 1
                self.view.layoutIfNeeded()
            })
            
        }
    }
    
    @objc func volumeSliderValueChanged(_ playbackSlider:UISlider)
    {
        player!.volume = playbackSlider.value
    }
    
    
    @objc func btnHomeClicked(_ sender:UIButton)
    {
        if self.vwHome != nil
        {
            if arrBanners.count > 0
            {
                currentBanner = currentBanner + 1
                if currentBanner >= arrBanners.count
                {
                    currentBanner = 0
                }
                let banner = arrBanners[currentBanner]
                self.vwHome.imgBanner.kf.setImage(with: URL(string: banner.link), placeholder: UIImage(), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                }, completionHandler: { image, error, cacheType, imageURL in
                })
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                self.vwHome.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
                self.vwHome.alpha = 1
                self.view.layoutIfNeeded()
            })
        }
        
    }
    @objc func setContentOffset()
    {
        self.vwHome.clvwTrending.setContentOffset(CGPoint(x: self.vwHome.clvwTrending.contentOffset.x, y: self.vwHome.clvwTrending.contentOffset.y+50), animated: true)
    }
    func deviceRemainingFreeSpaceInBytes() -> Int64? {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        guard
            let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectory),
            let freeSize = systemAttributes[.systemFreeSize] as? NSNumber
            else {
                // something failed
                return nil
        }
        return freeSize.int64Value
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        player.pause()
        player.removeAllItems()        
    }
    func randomAlphaNumericString(length: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""
        
        for _ in 0..<length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        return randomString
    }

    
}
extension ViewController : CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
        if isLocationAccessed == false{
            isLocationAccessed = true
            coordinate = locValue
            if app_Delegate.isServerReachable
            {
                    NotificationCenter.default.addObserver(self, selector: #selector(self.selectedVideo(not:)), name: Notification.Name("VideoSelection"), object: nil)
                    self.lblLoading.isHidden = false
                    let fileManager = FileManager.default
                    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    do {
                        let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                        // process files
                        if fileURLs.count > 0
                        {
                            for url in fileURLs
                            {
                                if self.currentIndex == 0
                                {
                                    DispatchQueue.main.async {
                                        self.arrLocalURL.append(url.absoluteString)
                                        self.lblLoading.isHidden = true
                                        self.arrContent = CoreDataAccessLayer.sharedInstance.getAllContentFromLocalDB()
                                        self.downloadComplete()
                                        self.loadHomeAndSleepCustomViews()
                                    }
                                }
                                else
                                {
                                    DispatchQueue.main.async {
                                        self.arrLocalURL.append(url.absoluteString)
                                        let playerItem:AVPlayerItem = AVPlayerItem(asset: AVAsset(url: url))
                                        self.player.insert(playerItem, after: self.prevItem)
                                        self.prevItem = playerItem
                                    }
                                }
                                self.currentIndex = self.currentIndex + 1
                            }
                        }
                        
                    } catch {
                        print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
                    }
                self.trackDevice()
                if #available(iOS 10.0, *) {
                    do {
                        Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: { (timer) in
                            self.trackDevice()
                        })
                    }

                } else {
                    Timer.scheduledTimer(timeInterval: 15,
                                         target: self,
                                         selector: #selector(self.trackDevice),
                                         userInfo: nil,
                                         repeats: true)

                }
            }
            else
            {
                DispatchQueue.main.async {
                    NotificationCenter.default.addObserver(self, selector: #selector(self.selectedVideo(not:)), name: Notification.Name("VideoSelection"), object: nil)
                    let fileManager = FileManager.default
                    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    do {
                        let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                        // process files
                        if fileURLs.count > 0
                        {
                            for url in fileURLs
                            {
                                self.arrLocalURL.append(url.absoluteString)
                                if self.currentIndex == 0
                                {
                                    DispatchQueue.main.async {
                                        self.lblLoading.isHidden = true
                                        self.arrContent = CoreDataAccessLayer.sharedInstance.getAllContentFromLocalDB()
                                        self.arrTrending = CoreDataAccessLayer.sharedInstance.getAllrendingContent()
                                        self.arrBanners = CoreDataAccessLayer.sharedInstance.getAllBannersFromLocalDB()
                                        self.downloadComplete()
                                        self.loadHomeAndSleepCustomViews()
                                    }
                                }
                                else
                                {
                                    DispatchQueue.main.async {
                                        let playerItem:AVPlayerItem = AVPlayerItem(asset: AVAsset(url: url))
                                        self.player.insert(playerItem, after: self.prevItem)
                                        self.prevItem = playerItem
                                    }
                                }
                                self.currentIndex = self.currentIndex + 1
                            }
                        }
                        
                    } catch {
                        print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
                    }
                }
            }
        }
        
    }
    @objc func trackDevice()
    {
        let lat = String(coordinate.latitude)
        let long = String(coordinate.longitude)
        let layer = ServiceLayer()
        layer.trackDeviceStatus(lat: lat, long: long, UDID: UDID,BLevel :String(batterLevel), freeSpace: String(freeSpace) ,successMessage: { (response) in
            if self.isFirstTime == false
            {
                self.isFirstTime = true
       /*         DispatchQueue.main.async {
                    NotificationCenter.default.addObserver(self, selector: #selector(self.selectedVideo(not:)), name: Notification.Name("VideoSelection"), object: nil)
                    self.lblLoading.isHidden = false
                    let fileManager = FileManager.default
                    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    do {
                        let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                        // process files
                        if fileURLs.count > 0
                        {
                            for url in fileURLs
                            {
                                self.arrLocalURL.append(url.absoluteString)
                                if self.currentIndex == 0
                                {
                                    DispatchQueue.main.async {
                                        self.lblLoading.isHidden = true
                                        self.downloadComplete()
                                        self.arrContent = CoreDataAccessLayer.sharedInstance.getAllContentFromLocalDB()
                                        self.loadHomeAndSleepCustomViews()
                                    }
                                }
                                else
                                {
                                    DispatchQueue.main.async {
                                        let playerItem:AVPlayerItem = AVPlayerItem(asset: AVAsset(url: url))
                                        self.player.insert(playerItem, after: self.prevItem)
                                        self.prevItem = playerItem
                                    }
                                }
                                self.currentIndex = self.currentIndex + 1
                            }
                        }
                        
                    } catch {
                        print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
                    }
                }*/
                self.getContentFromServer()
            }
            
        }) { (error) in
            if error as! String == "Unauthorised Access, device doesn't found"
            {
                if self.isFirstTime == false
                {
                    self.isFirstTime = true
                    
                    DispatchQueue.main.async {
                        if let vw = Bundle.main.loadNibNamed("RegistrationCustomView", owner: nil, options: nil)![0] as? RegistrationCustomView
                        {
                            vw.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
                            vw.callBack = self
                            self.vwRegistration = vw
                            self.vwRegistration.deviceID = self.UDID
                            self.view.addSubview(vw)
                        }
                    }
                    
                    //Show registration page
                    if UIScreen.main.brightness == 0.0
                    {
                        print("Locked")
                    }
                    else
                    {
                        print("Unlocked")
                    }
                }
            }
            
        }
    }
    func getContentFromServer()
    {
        let lat = String(coordinate.latitude)
        let long = String(coordinate.longitude)
        let layer = ServiceLayer()
        layer.getContent(lat:lat,long:long,successMessage: { (response) in
            let dict = response as! [String:AnyObject]
            self.arrContent = dict["content"] as! [ContentBO]
            self.arrAdBanners = dict["banner"] as! [BannerBO]
           /* if self.arrAdBanners.count > 0
            {
                DispatchQueue.main.async {
                    self.getBannerCountFromServer()
                    if #available(iOS 10.0, *) {
                        Timer.scheduledTimer(timeInterval: 3600, target: self, selector: #selector(self.getBannerCountFromServer), userInfo: nil, repeats: true)
                        
                    } else {
                        Timer.scheduledTimer(timeInterval: 3600,
                                             target: self,
                                             selector: #selector(self.getBannerCountFromServer),
                                             userInfo: nil,
                                             repeats: true)
                    }
                }
            }*/
            DispatchQueue.main.async {
                self.deleteVideoFromDocuments()
                layer.getTrendingAndBanners(successMessage: { (res) in
                    DispatchQueue.main.async {
                        let dictTemp = res as! [String:AnyObject]
//                        let arrTrendTemp = dictTemp["Trending"] as! [ContentBO]
                        self.arrBanners = dictTemp["Banners"] as! [BannerBO]
                        self.arrTrending = CoreDataAccessLayer.sharedInstance.getAllrendingContent()
                        self.loadHomeAndSleepCustomViews()
                        self.getRadio()
                    }
                }, failureMessage: { (error) in
                    DispatchQueue.main.async {
                    }
                })
            }
            self.download()

        }) { (error) in
            DispatchQueue.main.async {
                self.lblLoading.text = error as? String
            }
        }
    }
    @objc func getBannerCountFromServer()
    {
        let layer = ServiceLayer()
        let lat = String(self.coordinate.latitude)
        let long = String(self.coordinate.longitude)
        layer.getBannerCount(lat: lat, long: long, successMessage: { (reponse) in
            DispatchQueue.main.async {
                if #available(iOS 10.0, *) {
                    if self.adBannerTimer != nil{
                        if self.adBannerTimer.isValid
                        {
                            self.adBannerTimer.invalidate()
                        }
                    }
                    self.adBannerTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.showAdBanner), userInfo: nil, repeats: true)
                    
                } else {
                    if self.adBannerTimer != nil{
                        if self.adBannerTimer.isValid
                        {
                            self.adBannerTimer.invalidate()
                        }
                    }
                    self.adBannerTimer = Timer.scheduledTimer(timeInterval: 10,
                                         target: self,
                                         selector: #selector(self.showAdBanner),
                                         userInfo: nil,
                                         repeats: true)
                    
                }
            }
        }, failureMessage: { (error) in
            DispatchQueue.main.async {
                
            }
            
        })
    }
    func loadHomeAndSleepCustomViews()
    {
        if self.vwHome == nil
        {
            if let vw = Bundle.main.loadNibNamed("HomeCustomView", owner: nil, options: nil)![0] as? HomeCustomView
            {
                self.vwHome = vw
                self.vwHome.arrTrending = self.arrTrending
                self.vwHome.arrContent = self.arrContent
                self.vwHome.loadHomeCustomView()
                self.vwHome.callBack = self
                self.vwHome.frame = CGRect(x: 0, y: -ScreenHeight, width: ScreenWidth, height: ScreenHeight)
                self.vwHome.alpha = 0
                self.view.window?.addSubview(self.vwHome)
                self.btnHome?.isHidden = false
                isHomeCVLoaded = true

            }
        }
        else
        {
            self.vwHome.arrTrending = self.arrTrending
            self.vwHome.arrContent = self.arrContent
            self.vwHome.clvwTrending.reloadData()
            self.vwHome.clvwMixedContent.reloadData()

        }
        if self.vwSleep == nil
        {
            if let vw = Bundle.main.loadNibNamed("SleepCustomView", owner: nil, options: nil)![0] as? SleepCustomView
            {
                self.vwSleep = vw
                self.vwSleep.callBack = self
                self.vwSleep.frame = CGRect(x: 0, y: -ScreenHeight, width: ScreenWidth, height: ScreenHeight)
//                self.vwSleep.imgGif.image = UIImage.gifImageWithName("sleep")
                self.vwSleep.alpha = 0
                self.btnVolume?.isHidden = false
                isHomeCVLoaded = true
                self.view.window?.addSubview(self.vwSleep)
            }
        }
    }
}

extension ViewController:RegistrationCustomViewDelegate
{
    func btnCitySelClicked(vw:RegistrationCustomView)
    {
        self.showPicker()
        self.view.endEditing(true)
    }
    func btnRegisterClicked(vw:RegistrationCustomView)
    {
        
        if vw.txtFldCarNo.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please fill your Car Number.")
        }
        else if vw.txtFldMobileNo.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please fill your Mobile Number.")
        }
        else if vw.txtFldModel.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please fill Device Model (Ex: iPad2).")
        }
        else if vw.lblCity.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please Select City.")
        }
        else if vw.txtFldClientNo.text == ""
        {
            self.showAlertWith(title: "Alert!", message: "Please select client.")
        }
        else
        {
            let layer = ServiceLayer()
            layer.registerDeviceWith(deviceid: vw.deviceID, city: vw.lblCity.text!.lowercased(), model: vw.txtFldModel.text!, mobile: vw.txtFldMobileNo.text!, vendor: vw.txtFldClientNo.text!, carNo: vw.txtFldCarNo.text!, successMessage: { (response) in
                DispatchQueue.main.async {
                    self.vwRegistration.removeFromSuperview()
                    NotificationCenter.default.addObserver(self, selector: #selector(self.selectedVideo(not:)), name: Notification.Name("VideoSelection"), object: nil)
                    self.lblLoading.isHidden = false
                    let fileManager = FileManager.default
                    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    do {
                        let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                        // process files
                        if fileURLs.count > 0
                        {
                            for url in fileURLs
                            {
                                self.arrLocalURL.append(url.absoluteString)
                                if self.currentIndex == 0
                                {
                                    DispatchQueue.main.async {
                                        self.downloadComplete()
                                        self.lblLoading.isHidden = true
                                    }
                                }
                                else
                                {
                                    DispatchQueue.main.async {
                                        let playerItem:AVPlayerItem = AVPlayerItem(asset: AVAsset(url: url))
                                        self.player.insert(playerItem, after: self.prevItem)
                                        self.prevItem = playerItem
                                    }
                                }
                                self.currentIndex = self.currentIndex + 1
                            }
                        }
                        
                    } catch {
                        print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
                    }
                    self.getContentFromServer()
                    
                }
            }) { (error) in
                DispatchQueue.main.async {
                    self.showAlertWith(title: "Alert!", message: (error as? String)!)
                    print("Failed to register Device.")
                }
            }
        }
    }
}
extension ViewController : UITextFieldDelegate
{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func showPicker() {
        picker.backgroundColor = UIColor.white
        picker.delegate = self
        picker.frame = CGRect(x: 0, y: ScreenHeight - 250, width: ScreenWidth, height: 250)
        self.view.addSubview(picker)
        
        let btnDone = UIButton(type: .custom)
        btnDone.frame = CGRect(x: 0, y: picker.frame.origin.y - 31, width: ScreenWidth, height: 30)
        btnDone.backgroundColor = UIColor.white
        btnDone.setTitleColor(.black, for: .normal)
        btnDone.contentVerticalAlignment = .center
        btnDone.contentHorizontalAlignment = .left
        btnDone.titleLabel?.font = UIFont(name: "Roboto", size: 14.0)
        btnDone.setTitle("  Done", for: .normal)
        btnDone.addTarget(self, action: #selector(self.btnPickerDoneClicked(sender:)), for: .touchUpInside)
        self.view.addSubview(btnDone)
        
        vwSep = UIView(frame: CGRect(x: 0, y: picker.frame.origin.y - 1, width: ScreenWidth, height: 1))
        vwSep.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        self.view.addSubview(vwSep)
        
    }
    @objc func btnPickerDoneClicked(sender:UIButton)
    {
        vwRegistration.lblCity.text = arrCities[selectedPickerRow]
        picker.removeFromSuperview()
        vwSep.removeFromSuperview()
        sender.removeFromSuperview()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == vwRegistration.txtFldMobileNo
        {
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 10
            
        }
        return true
    }
    

}
extension ViewController : UIPickerViewDelegate, UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return arrCities.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(arrCities[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedPickerRow = row
    }
}
extension ViewController : SleepCustomViewDelegate
{
    func playVideo()
    {
        self.player.play()
    }
}
extension ViewController:HomeCustomViewDelegate
{
    func setCabDetail() {
        let layer = ServiceLayer()
        layer.getCabDetails(successMessage: { (response) in
            DispatchQueue.main.async {
                self.vwHome.arrCabDetails = response as! [CabDetailBO]
                self.vwHome.clVwCabDetails.reloadData()
            }
        }) { (error) in
            DispatchQueue.main.async {
                
            }
        }

    }
    func setCastId() {
        self.vwHome.lblCastId.text = "----"
        let layer = ServiceLayer()
        layer.getCastId(successMessage: { (id) in
            DispatchQueue.main.async {
                self.vwHome.lblCastId.text = String(format: "%d", arguments: [id as! Int])
            }
        }, failureMessage: { (error) in
            DispatchQueue.main.async {
            }
        })
    }
    

}
