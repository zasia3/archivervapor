//
//  Receipt.swift
//  Archiver
//
//  Created by Joanna Zatorska on 01/06/2017.
//
//

import Vapor
import FluentProvider
import HTTP

final class Receipt: Model {
    var name: String
    var date: Double
    var receiptPhotoId: Identifier
    var itemPhotoId: Identifier?
    var shopId: Identifier?
    var userId: Identifier
    let storage = Storage()
    
    init(name: String, date: Double, receiptPhotoId: Identifier, itemPhotoId: Identifier?, shopId: Identifier?, userId: Identifier) throws {
        self.name = name
        self.date = date
        self.receiptPhotoId = receiptPhotoId
        self.itemPhotoId = itemPhotoId
        self.shopId = shopId
        self.userId = userId
    }
    
    init(row: Row) throws {
        name = try row.get("name")
        date = try row.get("date")
        receiptPhotoId = try row.get("receiptphoto_id")
        itemPhotoId = try row.get("itemphoto_id")
        shopId = try row.get("shop_id")
        userId = try row.get("user_id")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("date", date)
        try row.set("receiptphoto_id", receiptPhotoId)
        try row.set("itemphoto_id", itemPhotoId)
        try row.set("shop_id", shopId)
        try row.set("user_id", userId)
        return row
    }
}

extension Receipt: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { receipt in
            receipt.id()
            receipt.string("name")
            receipt.double("date")
            receipt.parent(Photo.self, foreignIdKey: "receiptphoto_id")
            receipt.parent(Photo.self, optional: true, foreignIdKey: "itemphoto_id")
            receipt.parent(User.self)
            receipt.parent(Shop.self, optional: true)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Receipt: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get("name"),
            date: json.get("date"),
            receiptPhotoId: json.get("receiptphoto_id"),
            itemPhotoId: json.get("itemphoto_id"),
            shopId: json.get("shop_id"),
            userId: json.get("user_id")
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("date", date)
        try json.set("receiptphoto_id", receiptPhotoId)
        try json.set("itemphoto_id", itemPhotoId)
        try json.set("shop_id", shopId)
        try json.set("user_id", userId)
        return json
    }
}

extension Receipt: ResponseRepresentable {}

extension Request {
    func receipt() throws -> Receipt {
        guard let json = json else { throw Abort.badRequest }
        return try Receipt(json: json)
    }
}

extension Receipt {
    var receiptPhoto: Parent<Receipt, Photo> {
        return parent(id: receiptPhotoId)
    }
    
    var itemPhoto: Parent<Receipt, Photo> {
        return parent(id: itemPhotoId)
    }
    
    var shop: Parent<Receipt, Shop> {
        return parent(id: shopId)
    }
}
