//
//  Prospect.swift
//  HotProspects
//
//  Created by Reza Enayati on 9/30/24.
//

import SwiftData

@Model
class Prospect {
    var name: String
    var email: String
    var contacted: Bool
    
    init(name: String, email: String, contacted: Bool) {
        self.name = name
        self.email = email
        self.contacted = contacted
    }
}
