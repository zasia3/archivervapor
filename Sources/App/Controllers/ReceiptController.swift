//
//  ReceiptController.swift
//  Archiver
//
//  Created by Joanna Zatorska on 01/06/2017.
//
//

import Vapor
import HTTP

final class ReceiptController: ResourceRepresentable {
    
    func addRoutes(to builder: RouteBuilder) {
        builder.get("shop", handler: shop)
        builder.get("receiptphoto", handler: receiptphoto)
        builder.get("itemphoto", handler: itemphoto)
    }
    
    func shop(request: Request) throws -> ResponseRepresentable {
        
        let receipt = try request.receipt()

        if let shop = try receipt.shop.get() {
            return shop
        }
        return Response(status: .notFound)
    }
    
    func receiptphoto(request: Request) throws -> ResponseRepresentable {
        
        let receipt = try request.receipt()
        
        if let shop = try receipt.shop.get() {
            return shop
        }
        return Response(status: .notFound)
    }
    
    func itemphoto(request: Request) throws -> ResponseRepresentable {
        
        let receipt = try request.receipt()
        
        if let shop = try receipt.shop.get() {
            return shop
        }
        return Response(status: .notFound)
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
