//
//  Validation.swift
//  one
//
//  Created by Kai Chen on 12/31/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: self)
    }

    func isValidWebsite() -> Bool {
        let websiteRegEx = "www.+[A-Z0-9a-z._%+-]+.[A-Za-z]{2}"
        let range = websiteRegEx.range(of: websiteRegEx, options: .regularExpression)
        
        return range == nil ? false : true
    }
}
