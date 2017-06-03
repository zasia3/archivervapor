//
//  AuthToken.swift
//  Archiver
//
//  Created by Joanna Zatorska on 31/05/2017.
//
//

import Vapor
import FluentProvider
import HTTP


final class AuthToken: Model {
    let token: String
    let userId: Identifier
    let expiryDate: Date
    let storage = Storage()
    
    var user: Parent<AuthToken, User> {
        return parent(id: userId)
    }
    
    init(token: String, userId: Identifier) {
        self.token = token
        self.userId = userId
        expiryDate = Date().addingTimeInterval(60 * 60 * 24 * 7)
    }

    init(row: Row) throws {
        token = try row.get("token")
        userId = try row.get("user_id")
        expiryDate = try row.get("expiryDate")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("token", token)
        try row.set("user_id", userId)
        try row.set("expiryDate", expiryDate)
        return row
    }
    
    static func isValid(_ token: String, for userId: Identifier) throws -> Bool {
        guard let authToken = try AuthToken.makeQuery().filter("user_id", userId).first() else {
            return false
        }
        return token == authToken.token && authToken.expiryDate > Date()
    }
}

extension AuthToken: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { token in
            token.id()
            token.string("token")
            token.parent(User.self)
            token.date("expiryDate")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension AuthToken: ResponseRepresentable {
    func makeResponse() throws -> Response {
        var json = JSON()
        try json.set("token", token)
        try json.set("user_id", userId)
        return try json.makeResponse()
    }
}
