//
//  User.swift
//  Archiver
//
//  Created by Joanna Zatorska on 30/05/2017.
//
//

import Vapor
import FluentProvider
import HTTP
import AuthProvider
import BCrypt

final class User: Model {
    var name: String
    var password: String
    let storage = Storage()
    
    init(name: String, password: String) throws {
        self.name = name
        let hash = try User.hasher().make(password.bytes)
        self.password = String(bytes: hash)
    }
    
    init(row: Row) throws {
        name = try row.get("name")
        password = try row.get("password")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("password", password)
        return row
    }
    
    static func hasher() -> BCryptHasher {
        return BCryptHasher(cost: 8)
    }
}


extension User: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { user in
            user.id()
            user.string("name")
            user.string("password")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            
            name: json.get("name"),
            password: json.get("password")
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        return json
    }
}

extension User: ResponseRepresentable { }

extension User: TokenAuthenticatable {
    public typealias TokenType = AuthToken
}

extension Request {
    func user() throws -> User {
        guard let json = json else { throw Abort.badRequest }
        return try User(json: json)
    }
}
