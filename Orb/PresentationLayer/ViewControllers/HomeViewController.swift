//
//  HomeViewController.swift
//  Orb
//
//  Created by Nikhilesh on 19/04/18.
//  Copyright © 2018 Nikhilesh. All rights reserved.
//

import UIKit
protocol HomeViewControllerDelegate
{
    func selectedVideoWithURL(strUrl : String)
}
class HomeViewController: BaseViewController {

    @IBOutlet weak var clvwMenu: UICollectionView!
    //Home
    @IBOutlet weak var clvwMixedContent: UICollectionView!
    @IBOutlet weak var clvwTrending: UICollectionView!
    
    //Channels
    @IBOutlet weak var vwChannelsBase: UIView!
    @IBOutlet weak var clvwChannels: UICollectionView!
    @IBOutlet weak var imgChannelsTopBg: UIImageView!
    @IBOutlet weak var vwCarousel: iCarousel!
    
    //Settings
    @IBOutlet weak var vwSettings: UIView!

    enum Menu : Int {
        case Home = 0,Channels,Radio,Cast,CabProfile,Settings
    }
    var selMenu = Menu.Home
    
    var arrMenu = ["Home","Channels","Radio","Cast","Cab Profile","Settings"]
    var arrMenuImages = [#imageLiteral(resourceName: "Menu_home"),#imageLiteral(resourceName: "Menu_channel"),#imageLiteral(resourceName: "Menu_radio"),#imageLiteral(resourceName: "Menu_cast"),#imageLiteral(resourceName: "Menu_cabprofile"),#imageLiteral(resourceName: "Menu_settings")]
    var arrMenuImagesSel = [#imageLiteral(resourceName: "Menu_home_Sel"),#imageLiteral(resourceName: "Menu_channel_Sel"),#imageLiteral(resourceName: "Menu_radio_Sel"),#imageLiteral(resourceName: "Menu_cast_Sel"),#imageLiteral(resourceName: "Menu_cabprofile_Sel"),#imageLiteral(resourceName: "Menu_settings_Sel")]
    var selMenuIndex = 0
    
    var arrLanguages = ["Telugu","Hindi","English","Tamil","Punjabi","Marathi","Kannada","Bhojpuri","Urdu","Arab","Chinese"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.vwSettings.isHidden = true
        self.vwChannelsBase.isHidden = true
        self.vwCarousel.type = .rotary
        self.vwCarousel.delegate = self
        self.vwCarousel.dataSource = self
        // Do any additional setup after loading the view.
    }

    @IBAction func btnCloseMenuClicked(_ sender: UIButton) {
        self.dismiss(animated: true) {
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension HomeViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == clvwMenu
        {
            return arrMenu.count
        }
        else if collectionView == clvwMixedContent
        {
            return 10
        }
        else if collectionView == clvwTrending
        {
            return 10
        }
        else
        {
            return 10
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
            if indexPath.row <= 5
            {
                cell.imgVwTag.isHidden = true
                cell.imgVwContetent.image = #imageLiteral(resourceName: "RadioMirchi")
            }
            else
            {
                cell.imgVwTag.isHidden = false
                cell.imgVwTag.image = #imageLiteral(resourceName: "Tag_Hungama")
                cell.imgVwContetent.image = #imageLiteral(resourceName: "Adv.")

            }
            return cell
        }
        else if collectionView == clvwTrending
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCollectionViewCell", for: indexPath) as! ContentCollectionViewCell
            cell.imgVwTag.image = #imageLiteral(resourceName: "Tag_Hungama")
            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChannelCollectionViewCell", for: indexPath) as! ChannelCollectionViewCell
            return cell
        }


    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == clvwMenu
        {
            selMenuIndex = indexPath.row
            collectionView.reloadData()
            self.vwSettings.isHidden = true
            self.vwChannelsBase.isHidden = true
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
                self.vwSettings.isHidden = false
                break
            case  Menu.CabProfile.rawValue:
                self.vwSettings.isHidden = false
                break
            case  Menu.Settings.rawValue:
                self.vwSettings.isHidden = false
                break
            default:
                break
            }
        }
        else if collectionView == clvwTrending || collectionView == clvwMixedContent
        {
            NotificationCenter.default.post(name: Notification.Name("VideoSelection"), object: nil, userInfo: ["index":indexPath.row])
            self.dismiss(animated: true) {
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if collectionView == clvwMenu
        {
            return CGSize (width: 100, height: (self.view.bounds.size.height-120)/6)
        }
        else if collectionView == clvwMixedContent
        {
            if indexPath.row <= 5
            {
                return CGSize (width: 120, height: 120)
            }
            else
            {
                return CGSize (width: 160, height: 120)
            }
        }
        else if collectionView == clvwTrending
        {
            return CGSize (width: 160, height: 120)
        }
        else
        {
            return CGSize (width: (self.view.bounds.size.width-260)/4, height: (self.view.bounds.size.width-260)/4)
        }

    }

}
extension HomeViewController : iCarouselDelegate,iCarouselDataSource
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
        
    }
    func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        let frontmostViewIndex = carousel.currentItemIndex
        let frontmostView = carousel.itemView(at: frontmostViewIndex)
//        let frontmostView = carousel.currentItemView

        for vw in (frontmostView?.subviews)!
        {
            if vw.isKind(of: UILabel.self)
            {
                let lbl = vw as! UILabel
                print("selected language : \(lbl.text)")

            }
        }
            print("current Index : \(carousel.currentItemIndex)")

    }
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == iCarouselOption.spacing
        {
            return 1
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
