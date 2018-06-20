//
//  RegistrationCustomView.swift
//  Orb
//
//  Created by Nikhilesh on 02/05/18.
//  Copyright © 2018 Nikhilesh. All rights reserved.
//

import UIKit
protocol RegistrationCustomViewDelegate {
    func btnRegisterClicked(vw:RegistrationCustomView)
    func btnCitySelClicked(vw:RegistrationCustomView)
}
class RegistrationCustomView: UIView {
    @IBOutlet weak var txtFldCarNo: UITextField!
    @IBOutlet weak var txtFldMobileNo: UITextField!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var txtFldModel: UITextField!
    @IBOutlet weak var txtFldClientNo: UITextField!
    var callBack : RegistrationCustomViewDelegate!
    var deviceID = ""
    @IBAction func btnRegisterClicked(_ sender: UIButton) {
        if callBack != nil{
            callBack.btnRegisterClicked(vw: self)
        }
    }
    @IBAction func btnCitySelClicked(_ sender: UIButton) {
        if callBack != nil{
            callBack.btnCitySelClicked(vw: self)
        }
    }
}

