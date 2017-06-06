//
//  AuthenticationMiddleware.swift
//  Archiver
//
//  Created by Joanna Zatorska on 01/06/2017.
//
//

import HTTP

public final class AuthenticationMiddleware: Middleware {

    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {

        guard let token = request.auth.header?.bearer else {
            throw RequestError.notAuthorized
        }
        
        guard let userId = request.headers["X-User-Id"] else {
            throw RequestError.invalidUser
        }
        
        if try AuthToken.isValid(token.string, for: Identifier(userId)) {
            return try next.respond(to: request)
        }
        
        throw RequestError.tokenExpired
    }
}
