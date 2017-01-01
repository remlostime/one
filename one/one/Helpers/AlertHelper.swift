//
//  AlertHelper.swift
//  one
//
//  Created by Kai Chen on 12/31/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit

protocol AlertHelperDelegate {
    func show(_ alertViewController: UIAlertController)
}

class AlertHelper {
    
    var delegate: AlertHelperDelegate?
    var alertVC: UIAlertController?
    
    init(_ title: String?, message: String?, delegate: AlertHelperDelegate?) {
        alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertVC?.addAction(okAction)
        
        self.delegate = delegate
    }
    
    func show() {
        delegate?.show(alertVC!)
    }
}
