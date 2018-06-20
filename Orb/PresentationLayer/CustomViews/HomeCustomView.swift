//
//  HomeCustomView.swift
//  Orb
//
//  Created by Nikhilesh on 23/04/18.
//  Copyright © 2018 Nikhilesh. All rights reserved.
//

import UIKit
import Kingfisher
protocol HomeCustomViewDelegate
{
    func setCastId()
    func setCabDetail()
}
class HomeCustomView: UIView {

    @IBOutlet weak var clvwMenu: UICollectionView!
    //Home
    @IBOutlet weak var clvwMixedContent: UICollectionView!
    @IBOutlet weak var clvwTrending: UICollectionView!
    @IBOutlet weak var imgBanner: UIImageView!

    var arrTrending = [ContentBO]()
    var arrBanners = [BannerBO]()
    var arrRadio = [RadioBO]()
    var arrContent = [ContentBO]()
    var callBack : HomeCustomViewDelegate!
    
    //Channels
    @IBOutlet weak var vwChannelsBase: UIView!
    @IBOutlet weak var clvwChannels: UICollectionView!
    @IBOutlet weak var imgChannelsTopBg: UIImageView!
    @IBOutlet weak var vwCarousel: iCarousel!
    var arrChannels = [String]()
    var isChannelSel = false
    var arrChannelVideos = [ContentBO]()
    var currentChannel = ""

    //Settings
    @IBOutlet weak var vwSettings: UIView!
    
    //Cast
    @IBOutlet weak var vwCabDetails: UIView!
    @IBOutlet weak var clVwCabDetails: UICollectionView!
    var arrCabDetails = [CabDetailBO]()
    
    
    @IBOutlet weak var VwCast: UIView!
    @IBOutlet weak var lblCastId: UILabel!
    
    enum Menu : Int {
        case Home = 0,Channels,Radio,Cast,CabProfile,Settings
    }
    var selMenu = Menu.Home
    
    var arrMenu = ["Home","Channels","Radio","Cast","Cab Profile","Settings"]
    var arrMenuImages = [#imageLiteral(resourceName: "Menu_home"),#imageLiteral(resourceName: "Menu_channel"),#imageLiteral(resourceName: "Menu_radio"),#imageLiteral(resourceName: "Menu_cast"),#imageLiteral(resourceName: "Menu_cabprofile"),#imageLiteral(resourceName: "Menu_settings")]
    var arrMenuImagesSel = [#imageLiteral(resourceName: "Menu_home_Sel"),#imageLiteral(resourceName: "Menu_channel_Sel"),#imageLiteral(resourceName: "Menu_radio_Sel"),#imageLiteral(resourceName: "Menu_cast_Sel"),#imageLiteral(resourceName: "Menu_cabprofile_Sel"),#imageLiteral(resourceName: "Menu_settings_Sel")]
    var selMenuIndex = 0
    
    var arrLanguages = [String]()
    
     func loadHomeCustomView() {
        self.clvwMenu.register(UINib(nibName: "MenuCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "MenuCollectionViewCell")
        self.clvwTrending.register(UINib(nibName: "ContentCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ContentCollectionViewCell")
        self.clvwMixedContent.register(UINib(nibName: "ContentCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ContentCollectionViewCell")
        self.clvwChannels.register(UINib(nibName: "ChannelCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ChannelCollectionViewCell")
        self.clvwChannels.register(UINib(nibName: "ChannelVideoCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ChannelVideoCollectionViewCell")
        self.clVwCabDetails.register(UINib(nibName: "CabDetailsCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CabDetailsCollectionViewCell")

        arrLanguages = CoreDataAccessLayer().getAllLanguages()

        self.vwSettings.isHidden = true
        self.vwChannelsBase.isHidden = true
        self.vwCarousel.type = .rotary
        self.vwCarousel.delegate = self
        self.vwCarousel.dataSource = self

        self.clvwMenu.delegate = self
        self.clvwMenu.dataSource = self

        self.clvwTrending.delegate = self
        self.clvwTrending.dataSource = self

        self.clvwMixedContent.delegate = self
        self.clvwMixedContent.dataSource = self

        self.clvwChannels.delegate = self
        self.clvwChannels.dataSource = self

    }
    
    @IBAction func btnCloseMenuClicked(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
                self.frame = CGRect(x: 0, y: -ScreenHeight, width: ScreenWidth, height: ScreenHeight)
                self.alpha = 0
        }, completion: { (complete) in
            DispatchQueue.main.async {
            }
        })

    }
    
}
extension HomeCustomView : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == clvwMenu
        {
            return arrMenu.count
        }
        else if collectionView == clvwMixedContent
        {
            return arrRadio.count + arrContent.count
        }
        else if collectionView == clvwTrending
        {
            return arrTrending.count
        }
            else if collectionView == clVwCabDetails
        {
            return arrCabDetails.count
        }
        else
        {
            if isChannelSel
            {
                return arrChannelVideos.count
            }
            else
            {
                return arrChannels.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == clvwMenu
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCollectionViewCell", for: indexPath) as! MenuCollectionViewCell
            if selMenuIndex == indexPath.row
            {
                cell.backgroundColor = UIColor.darkGray
                cell.imgMenu.image = arrMenuImagesSel[indexPath.row]
                cell.lblMenu.textColor = UIColor.white
                
            }
            else
            {
                cell.backgroundColor = UIColor.white
                cell.imgMenu.image = arrMenuImages[indexPath.row]
                cell.lblMenu.textColor = UIColor.darkGray
            }
            cell.lblMenu.text = arrMenu[indexPath.row]
            return cell
        }
        else if collectionView == clvwMixedContent
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCollectionViewCell", for: indexPath) as! ContentCollectionViewCell
            if indexPath.row < arrRadio.count
            {
                cell.imgVwTag.isHidden = true
                let bo = arrRadio[indexPath.row]
                cell.imgVwContetent.kf.setImage(with: URL(string: bo.Thumbnail), placeholder: UIImage(), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                }, completionHandler: { image, error, cacheType, imageURL in
                })
            }
            else
            {
                cell.imgVwTag.isHidden = false
                cell.imgVwTag.image = #imageLiteral(resourceName: "Tag_Hungama")
                let bo = arrContent[indexPath.row - arrRadio.count]
                cell.imgVwContetent.kf.setImage(with: URL(string: bo.Thumbnail), placeholder: UIImage(), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                }, completionHandler: { image, error, cacheType, imageURL in
                })

            }
            return cell
        }
        else if collectionView == clvwTrending
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCollectionViewCell", for: indexPath) as! ContentCollectionViewCell
            cell.imgVwTag.image = #imageLiteral(resourceName: "Tag_Hungama")
            let bo = arrTrending[indexPath.row]
            cell.imgVwContetent.kf.setImage(with: URL(string: bo.Thumbnail), placeholder: UIImage(), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
            }, completionHandler: { image, error, cacheType, imageURL in
                DispatchQueue.main.async {
                    cell.imgVwContetent.layer.cornerRadius = 5
                    cell.imgVwContetent.clipsToBounds = true
                }
            })
            return cell
        }
        else if collectionView == clVwCabDetails
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CabDetailsCollectionViewCell", for: indexPath) as! CabDetailsCollectionViewCell
            let bo = arrCabDetails[indexPath.row]
            cell.lblName.text = bo.fullName
            cell.lblType.text = bo.carType
            cell.lblCity.text = bo.address
            cell.lblRegNo.text = bo.carNo
            cell.lblSpeak.text = bo.languages
            if bo.type == "Owner"
            {
                cell.lblPersonType.text = "Owner Details"
            }
            else
            {
                cell.lblPersonType.text = "Driver Details"
            }
            cell.imgProfile.kf.setImage(with: URL(string: bo.image), placeholder: UIImage(), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
            }, completionHandler: { image, error, cacheType, imageURL in
            })

            return cell
        }
        else
        {
            
            if isChannelSel
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChannelVideoCollectionViewCell", for: indexPath) as! ChannelVideoCollectionViewCell
                cell.imgTag.image = #imageLiteral(resourceName: "Tag_Hungama")
                let bo = arrChannelVideos[indexPath.row]
                cell.lblDuration.text = String(format:"%02d:%02d",Int64(Double(bo.Duration)!/1000.0)/60,Int64(Double(bo.Duration)!/1000.0)%60)
                cell.lblVideoName.text = bo.Title
                cell.imgContent.kf.setImage(with: URL(string: bo.Thumbnail), placeholder: UIImage(), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                }, completionHandler: { image, error, cacheType, imageURL in
                })
                return cell
            }
            else
            {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChannelCollectionViewCell", for: indexPath) as! ChannelCollectionViewCell
                cell.lblCat.text = arrChannels[indexPath.row]
                
                if cell.lblCat.text == "Comedy"
                {
                    cell.imgCat.image = #imageLiteral(resourceName: "chnl_comedy")
                }
                else if cell.lblCat.text == "Health"
                {
                    cell.imgCat.image = #imageLiteral(resourceName: "chnl_healthcare")
                }
                else if cell.lblCat.text == "Interviews"
                {
                    cell.imgCat.image = #imageLiteral(resourceName: "chnl_interviews")
                }
                else if cell.lblCat.text == "Music Videos"
                {
                    cell.imgCat.image = #imageLiteral(resourceName: "chnl_music_videos")
                }
                else if cell.lblCat.text == "Short Films"
                {
                    cell.imgCat.image = #imageLiteral(resourceName: "chnl_shortfilms")
                }
                else if cell.lblCat.text == "sports"
                {
                    cell.imgCat.image = #imageLiteral(resourceName: "chnl_sports")
                }
                else if cell.lblCat.text == "Trailers"
                {
                    cell.imgCat.image = #imageLiteral(resourceName: "chnl_trailers")
                }
                else if cell.lblCat.text == "Trending"
                {
                    cell.imgCat.image = #imageLiteral(resourceName: "chnl_trending")
                }
                else if cell.lblCat.text == "Kids"
                {
                    cell.imgCat.image = #imageLiteral(resourceName: "chnl_kids")
                }
                else
                {
                    
                }
                
                return cell
            }
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == clvwMenu
        {
            selMenuIndex = indexPath.row
            collectionView.reloadData()
            self.vwSettings.isHidden = true
            self.vwChannelsBase.isHidden = true
            self.VwCast.isHidden = true
            self.vwCabDetails.isHidden = true
            switch indexPath.row
            {
            case  Menu.Home.rawValue:
                break
            case  Menu.Channels.rawValue:
                self.vwChannelsBase.isHidden = false
                break
            case  Menu.Radio.rawValue:
                self.vwSettings.isHidden = false
                break
            case  Menu.Cast.rawValue:
                self.VwCast.isHidden = false
                if callBack != nil{
                    callBack.setCastId()
                }
                break
            case  Menu.CabProfile.rawValue:
                self.vwCabDetails.isHidden = false
                if callBack != nil{
                    callBack.setCabDetail()
                }
                break
            case  Menu.Settings.rawValue:
                self.vwSettings.isHidden = false
                break
            default:
                break
            }
        }
        else if collectionView == clvwTrending
        {
            NotificationCenter.default.post(name: Notification.Name("VideoSelection"), object: nil, userInfo: ["data":arrTrending[indexPath.row]])
        }
        else if collectionView == clvwMixedContent
        {
            NotificationCenter.default.post(name: Notification.Name("VideoSelection"), object: nil, userInfo: ["data":arrContent[indexPath.row-arrRadio.count]])
        }
        else if collectionView == clvwChannels
        {
            if isChannelSel
            {
                NotificationCenter.default.post(name: Notification.Name("VideoSelection"), object: nil, userInfo: ["data":arrChannelVideos[indexPath.row]])
            }
            else
            {
                isChannelSel = true
                self.arrChannelVideos = CoreDataAccessLayer().getContentFromLocalDBWith(strChannel: arrChannels[indexPath.row], strLanguage: currentChannel)
                clvwChannels.reloadData()
            }
        }


    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if collectionView == clvwMenu
        {
            return CGSize (width: 100, height: (self.bounds.size.height-100)/6)
        }
        else if collectionView == clvwMixedContent
        {
            if indexPath.row < self.arrRadio.count
            {
                return CGSize (width: 120, height: 120)
            }
            else
            {
                return CGSize (width: 200, height: 120)
            }
        }
        else if collectionView == clvwTrending
        {
            return CGSize (width: 200, height: 120)
        }
        else if collectionView == clVwCabDetails
        {
            return CGSize (width: 783, height: 293)
        }
        else
        {
            return CGSize (width: (self.bounds.size.width-260)/4, height: (self.bounds.size.width-260)/4)
        }
        
    }
    
}
extension HomeCustomView : iCarouselDelegate,iCarouselDataSource
{
    func numberOfItems(in carousel: iCarousel) -> Int {
        return arrLanguages.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let vwBase = UIView(frame: CGRect(x: 0, y: 0, width:(0.7)*carousel.frame.size.width, height: carousel.frame.size.height))
        vwBase.backgroundColor = UIColor.clear
        
        let lblLanguage = UILabel(frame: CGRect(x: 15, y: 0, width:vwBase.frame.size.width - 30, height: 100))
        lblLanguage.backgroundColor = UIColor(red: 23.0/255.0, green: 74.0/255.0, blue: 124.0/255.0, alpha: 1.0)
        lblLanguage.layer.cornerRadius = 5
        lblLanguage.layer.masksToBounds = true
        lblLanguage.text = arrLanguages[index]
        lblLanguage.textAlignment = .center
        lblLanguage.textColor = UIColor.white
        lblLanguage.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lblLanguage.layer.shadowColor = UIColor.black.cgColor
        lblLanguage.layer.shadowOpacity = 1
        lblLanguage.layer.shadowOffset = CGSize.zero
        lblLanguage.layer.shadowRadius = 20
        vwBase.addSubview(lblLanguage)
        return vwBase
    }
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        isChannelSel = false
        let frontmostViewIndex = carousel.currentItemIndex
        let frontmostView = carousel.itemView(at: frontmostViewIndex)
        //        let frontmostView = carousel.currentItemView
        
        for vw in (frontmostView?.subviews)!
        {
            if vw.isKind(of: UILabel.self)
            {
                let lbl = vw as! UILabel
                currentChannel = lbl.text!
                arrChannels = CoreDataAccessLayer().getAllChannelsWith(strLang: lbl.text!)
                clvwChannels.reloadData()
            }
        }
        print("current Index : \(carousel.currentItemIndex)")
    }
    func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        isChannelSel = false
        let frontmostViewIndex = carousel.currentItemIndex
        let frontmostView = carousel.itemView(at: frontmostViewIndex)
        //        let frontmostView = carousel.currentItemView
        
        for vw in (frontmostView?.subviews)!
        {
            if vw.isKind(of: UILabel.self)
            {
                let lbl = vw as! UILabel
                currentChannel = lbl.text!
                arrChannels = CoreDataAccessLayer().getAllChannelsWith(strLang: lbl.text!)
                clvwChannels.reloadData()
            }
        }
        print("current Index : \(carousel.currentItemIndex)")
        
    }
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == iCarouselOption.spacing
        {
            return 2
        }
        else if option == iCarouselOption.showBackfaces
        {
            return 0
        }
        else if option == iCarouselOption.visibleItems
        {
            return 3
        }
        else
        {
            return value
        }
    }
    
    
}

