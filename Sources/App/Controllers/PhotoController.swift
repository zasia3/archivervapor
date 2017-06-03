//
//  PhotoController.swift
//  Archiver
//
//  Created by Joanna Zatorska on 01/06/2017.
//
//

import Vapor
import HTTP

final class PhotoController: ResourceRepresentable {

    func create(request: Request) throws -> ResponseRepresentable {
        let photo = try request.photo()
        try photo.save()
        return photo
    }
    
    func makeResource() -> Resource<Photo> {
        return Resource(
            store: create
        )
    }
}

extension PhotoController: EmptyInitializable { }
