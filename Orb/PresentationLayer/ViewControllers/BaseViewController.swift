//
//  BaseViewController.swift
//  Orb
//
//  Created by Nikhilesh on 19/04/18.
//  Copyright © 2018 Nikhilesh. All rights reserved.
//

import UIKit
let app_Delegate = UIApplication.shared.delegate as! AppDelegate
let ScreenWidth =  UIScreen.main.bounds.size.width
let ScreenHeight = UIScreen.main.bounds.size.height

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func showAlertWith(title : String,message : String)
    {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
