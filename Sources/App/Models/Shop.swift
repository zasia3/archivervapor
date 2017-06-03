//
//  Shop.swift
//  Archiver
//
//  Created by Joanna Zatorska on 01/06/2017.
//
//

import Vapor
import FluentProvider
import HTTP

final class Shop: Model {
    var name: String
    var address: String
    var userId: Identifier
    let storage = Storage()
    
    init(name: String, address: String, userId: Identifier) throws {
        self.name = name
        self.address = address
        self.userId = userId
    }
    
    init(row: Row) throws {
        name = try row.get("name")
        address = try row.get("address")
        userId = try row.get("user_id")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("address", address)
        try row.set("user_id", userId)
        return row
    }
}

extension Shop: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { shop in
            shop.id()
            shop.string("name")
            shop.string("address")
            shop.parent(User.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Shop: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get("name"),
            address: json.get("address"),
            userId: json.get("user_id")
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("address", address)
        try json.set("user_id", userId)
        return json
    }
}

extension Shop: ResponseRepresentable { }
extension Shop: BasicTokenAuthenticable {}

extension Request {
    func shop() throws -> Shop {
        guard let json = json else { throw Abort.badRequest }
        return try Shop(json: json)
    }
}
