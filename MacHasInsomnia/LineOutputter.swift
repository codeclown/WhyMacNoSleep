//
//  LineOutputter.swift
//  MacHasInsomnia
//
//  Created by Martti on 06/02/2020.
//  Copyright © 2020 Codeclown. All rights reserved.
//

import Foundation

class LineOutputter {
    var data: String
    
    init() {
        self.data = ""
    }

    func feed(_ data: String) -> [String] {
        var lines = [] as [String]
        for char in data {
            if char == "\n" {
                lines.append(self.data)
                self.data = ""
            } else {
                self.data.append(char)
            }
        }
        return lines
    }
}
