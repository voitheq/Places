//
//  Category.swift
//  Places
//
//  Created by Wojciech Karaś on 30/01/2019.
//  Copyright © 2019 Wojciech Karaś. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name = ""
    @objc dynamic var categoryDescription = ""
    let places = List<Place>()
}
