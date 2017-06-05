//
//  AuthenticationMiddleware.swift
//  Archiver
//
//  Created by Joanna Zatorska on 01/06/2017.
//
//

import HTTP

public protocol BasicTokenAuthenticable {}

public final class AuthenticationMiddleware<U: BasicTokenAuthenticable>: Middleware {
    
    let type: U.Type!
    
    public init(_ type: U.Type = U.self) {
        self.type = type
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        guard type is BasicTokenAuthenticable else {
            return try next.respond(to: request)
            
        }
        
        guard let token = request.auth.header?.bearer else {
            throw Abort(.networkAuthenticationRequired, metadata: "Not authorized")
        }
        
        guard let id = request.json?["user_id"] else {
            throw Abort(.networkAuthenticationRequired, metadata: "Invalid user")
        }
        if try AuthToken.isValid(token.string, for: Identifier(id)) {
            return try next.respond(to: request)
        }
        
        throw Abort(.networkAuthenticationRequired, metadata: "Token expired")
    }
}
