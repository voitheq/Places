//
//  Place.swift
//  Places
//
//  Created by Wojciech Karaś on 30/01/2019.
//  Copyright © 2019 Wojciech Karaś. All rights reserved.
//

import Foundation
import RealmSwift

class Place: Object {
    @objc dynamic var name: String?
    @objc dynamic var placeDescription: String?
    @objc dynamic var latitude: Float = 0
    @objc dynamic var longitude: Float = 0
    var parentCategory = LinkingObjects(fromType: Category.self, property: "places")
}
