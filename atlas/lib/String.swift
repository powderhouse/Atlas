//
//  String.swift
//  atlas
//
//  Created by Jared Cosulich on 12/22/17.
//  Copyright © 2017 Powderhouse Studios. All rights reserved.
//

import Foundation

extension String {
    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
}
