//
//  SleepCustomView.swift
//  Orb
//
//  Created by Nikhilesh on 25/04/18.
//  Copyright © 2018 Nikhilesh. All rights reserved.
//

import UIKit
protocol SleepCustomViewDelegate
{
    func playVideo()
}
class SleepCustomView: UIView {

    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var imgGif: UIImageView!
    var callBack : SleepCustomViewDelegate!
    @IBAction func btnCloseClicked(_ sender: UIButton) {
        if callBack != nil{
            callBack.playVideo()
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: ScreenHeight)
            self.alpha = 0
        }, completion: { (complete) in
            DispatchQueue.main.async {
                self.frame = CGRect(x: 0, y: -ScreenHeight, width: ScreenWidth, height: ScreenHeight)
            }
        })
        

    }
}
