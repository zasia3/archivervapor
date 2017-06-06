//
//  ReceiptController.swift
//  Archiver
//
//  Created by Joanna Zatorska on 01/06/2017.
//
//

import Vapor
import HTTP
import Routing

final class ReceiptController: ResourceRepresentable {
    
    func addRoutes(to builder: RouteBuilder) {
        let grouped = builder.grouped("receipts")
        grouped.get(Receipt.parameter, "shop", handler: shop)
        grouped.get(Receipt.parameter,"receiptphoto", handler: receiptphoto)
        grouped.get(Receipt.parameter,"itemphoto", handler: itemphoto)
    }
    
    func shop(request: Request) throws -> ResponseRepresentable {
        let receipt = try request.parameters.next(Receipt.self)
        if let shop = try receipt.shop.get() {
            return shop
        }
        throw RequestError.resourceNotExists
    }
    
    func receiptphoto(request: Request) throws -> ResponseRepresentable {
        
        let receipt = try request.parameters.next(Receipt.self)
        
        if let photo = try receipt.receiptPhoto.get() {
            return photo
        }
        throw RequestError.resourceNotExists
    }
    
    func itemphoto(request: Request) throws -> ResponseRepresentable {
        
        let receipt = try request.parameters.next(Receipt.self)
        
        if let photo = try receipt.itemPhoto.get() {
            return photo
        }
        throw RequestError.resourceNotExists
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Receipt.all().makeJSON()
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        let receipt = try request.receipt()
        try receipt.save()
        return receipt
    }
    
    func show(request: Request, receipt: Receipt) throws -> ResponseRepresentable {
        return receipt
    }
    
    func delete(request: Request, receipt: Receipt) throws -> ResponseRepresentable {
        try receipt.delete()
        return Response(status: .ok)
    }
    
    func clear(request: Request) throws -> ResponseRepresentable {
        try Receipt.makeQuery().delete()
        return Response(status: .ok)
    }
    
    func update(request: Request, receipt: Receipt) throws -> ResponseRepresentable {
        
        let new = try request.receipt()
        receipt.name = new.name
        receipt.date = new.date
        if receipt.receiptPhotoId != new.receiptPhotoId {
            let photo = receipt.receiptPhoto
            try photo.delete()
            receipt.receiptPhotoId = new.receiptPhotoId
        }
        if receipt.itemPhotoId != new.itemPhotoId {
            let photo = receipt.itemPhoto
            try photo.delete()
            receipt.itemPhotoId = new.itemPhotoId
        }
        receipt.shopId = new.shopId
        receipt.userId = new.userId
        try receipt.save()
        return receipt
    }

    
    func makeResource() -> Resource<Receipt> {
        return Resource(
            index: index,
            store: create,
            show: show,
            update: update,
            destroy: delete,
            clear: clear
        )
    }
}



extension ReceiptController: EmptyInitializable { }
