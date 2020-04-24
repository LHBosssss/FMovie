//
//  FshareAccount.swift
//  FMovie
//
//  Created by Ho Duy Luong on 4/20/20.
//  Copyright © 2020 Ho Duy Luong. All rights reserved.
//
import RealmSwift

class FshareAccount: Object {
    @objc dynamic var sessionID = ""
    @objc dynamic var token = ""
}
