//
//  UserController.swift
//  Archiver
//
//  Created by Joanna Zatorska on 31/05/2017.
//
//

import Vapor
import HTTP

final class UserController: ResourceRepresentable {
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try User.all().makeJSON()
    }

    func create(request: Request) throws -> ResponseRepresentable {
        let user = try request.user()
        if try User.makeQuery().filter("name", user.name).first() == nil {
            try user.save()
            let token = try TokenCreator.token(username: user.name, userPassword: user.password)
            let userToken = AuthToken(token: token, userId: user.id!)
            try userToken.save()
            return userToken
        } else {
            throw Abort.badRequest //change
        }
    }
    
    func show(request: Request, user: User) throws -> ResponseRepresentable {
        guard let token = request.auth.header?.bearer else {
            throw Abort(.networkAuthenticationRequired, metadata: "Not authorized")
        }
        guard let id = user.id else {
            throw Abort(.networkAuthenticationRequired, metadata: "Invalid user")
        }
        if try AuthToken.isValid(token.string, for: id) {
            return user
        }
        
        throw Abort(.networkAuthenticationRequired, metadata: "Token expired")
    }
    
    func delete(request: Request, user: User) throws -> ResponseRepresentable {
        try user.delete()
        return Response(status: .ok)
    }
    
    func clear(request: Request) throws -> ResponseRepresentable {
        try User.makeQuery().delete()
        return Response(status: .ok)
    }
    
    func update(request: Request, user: User) throws -> ResponseRepresentable {
        
        let new = try request.userFromJson()
        user.name = new.name
        user.password = new.password
        try user.save()
        return user
    }

    func replace(request: Request, user: User) throws -> ResponseRepresentable {
        try user.delete()
        return try create(request: request)
    }

    func makeResource() -> Resource<User> {
        return Resource(
            index: index,
            store: create,
            show: show,
            update: update,
            replace: replace,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    func userFromJson() throws -> User {
        guard let json = json else { throw Abort.badRequest }
        return try User(json: json)
    }
}

extension UserController: EmptyInitializable { }
