//
//  CabDetailsCollectionViewCell.swift
//  Orb
//
//  Created by Nikhilesh on 11/05/18.
//  Copyright © 2018 Nikhilesh. All rights reserved.
//

import UIKit

class CabDetailsCollectionViewCell: UICollectionViewCell {
    //Cab Details - Owner
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblRegNo: UILabel!
    @IBOutlet weak var lblSpeak: UILabel!
    @IBOutlet weak var lblPersonType: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
