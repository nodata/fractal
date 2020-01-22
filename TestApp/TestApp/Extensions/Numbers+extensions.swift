//
//  Numbers+extensions.swift
//  ECCBWallet
//
//  Created by Jonathan Bott on 11/1/19.
//  Copyright © 2019 Jon Bott. All rights reserved.
//

import Foundation

extension Double {
    var splitStrings: (left: String?, right: String?) {
        let leftNumber  = floor(self)
        let rightNumber = Int(self * 100) - (Int(leftNumber) * 100)
        let right = String(format: "%02d", rightNumber)
        return (left: "\(Int(leftNumber))", right: "\(right)")
    }
}
