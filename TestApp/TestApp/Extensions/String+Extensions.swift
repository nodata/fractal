//
//  String+Extensions.swift
//  ECCBWallet
//
//  Created by Jonathan Bott on 10/31/19.
//  Copyright © 2019 Jon Bott. All rights reserved.
//

import UIKit

extension String{
    var htmlAttributedString: NSMutableAttributedString? {
        let data = Data(self.utf8)
        return try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
    }
}
