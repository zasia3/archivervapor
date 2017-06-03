//
//  ShopController.swift
//  Archiver
//
//  Created by Joanna Zatorska on 01/06/2017.
//
//

import Vapor
import HTTP

final class ShopController: ResourceRepresentable {
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Shop.all().makeJSON()
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        let shop = try request.shop()
        try shop.save()
        return shop
    }
    
    func show(request: Request, shop: Shop) throws -> ResponseRepresentable {
        return shop
    }
    
    func update(request: Request, shop: Shop) throws -> ResponseRepresentable {
        let new = try request.shop()
        let shop = shop
        shop.name = new.name
        shop.address = new.address
        try shop.save()
        return shop
    }
    
    func delete(request: Request, shop: Shop) throws -> ResponseRepresentable {
        try shop.delete()
        return Response(status: .ok)
    }
    
    func makeResource() -> Resource<Shop> {
        return Resource(
            index: index,
            store: create,
            show: show,
            update: update,
            destroy: delete
        )
    }

}
extension ShopController: EmptyInitializable { }
