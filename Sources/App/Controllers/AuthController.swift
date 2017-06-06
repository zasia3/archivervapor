//
//  AuthController.swift
//  Archiver
//
//  Created by Joanna Zatorska on 31/05/2017.
//
//

import Vapor
import HTTP

final class AuthController {
    
    func addRoutes(to builder: RouteBuilder) {
        builder.post("login", handler: loginUser)
        builder.post("register", handler: registerUser)
        builder.post("logout", handler: logout)
    }

    
    func registerUser(_ request: Request) throws -> ResponseRepresentable {
        let user = try request.user()
        if try User.makeQuery().filter("name", user.name).first() == nil {
            try user.save()
            let token = try userToken(username: user.name, password: user.password, id: user.id!)
            try token.save()
            return token
        } else {
            throw RequestError.userExists
        }
    }
    
    func loginUser(_ request: Request) throws -> ResponseRepresentable {

        guard let password = request.json?["password"]?.string,
            let name = request.json?["name"]?.string else {
            throw Abort(.badRequest)
        }
        guard let existingUser = try User.makeQuery().filter("name", name).first() else {
            throw RequestError.userNotExisting
        }
        if try User.hasher().verify(password: password, matches: existingUser.password) {
            let authToken = try AuthToken.makeQuery().filter("user_id", existingUser.id).first()
            
            let token = try userToken(username: existingUser.name, password: existingUser.password, id: existingUser.id!)
            try token.save()
            try authToken?.delete()
            return token
        }
        
        throw RequestError.invalidPassword
    }
    
    func logout(_ request: Request) throws -> ResponseRepresentable {
        guard let name = request.json?["name"]?.string else {
                throw Abort(.badRequest)
        }

        guard let existingUser = try User.makeQuery().filter("name", name).first() else {
            throw RequestError.userNotExisting
        }
        
        let userToken = try AuthToken.makeQuery().filter("user_id", existingUser.id!)
        try userToken.delete()
        return "Logged out"
    }
    
    private func userToken(username: String, password: String, id: Identifier) throws -> AuthToken {
        let token = try TokenCreator.token(username: username, userPassword: password)
        let userToken = AuthToken(token: token, userId: id)
        return userToken
    }
    
}
