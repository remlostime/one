//
//  ProfileUserImageViewCell.swift
//  one
//
//  Created by Kai Chen on 12/30/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit

protocol ProfileUserImageViewCellDelegate {
    func showImagePicker(_ prfileImageCell: ProfileUserImageViewCell)
}

class ProfileUserImageViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    
    var delegate: ProfileUserImageViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let profileImageTap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(profileImageTap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func changedProfileImageButtonTapped(_ sender: UIButton) {
        profileImageTapped()
    }

    func profileImageTapped() {
        if let delegate = delegate {
            delegate.showImagePicker(self)
        }
    }
}
