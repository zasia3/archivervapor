//
//  RequestError.swift
//  Archiver
//
//  Created by Joanna Zatorska on 05/06/2017.
//
//

import Foundation


enum RequestError: Error {
    case notAuthorized
    case invalidUser
    case tokenExpired
    case userExists
    case userNotExisting
    case invalidPassword
    case resourceNotExists
}

final class RequestErrorMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            return try next.respond(to: request)
        } catch RequestError.notAuthorized {
            throw Abort(
                .networkAuthenticationRequired,
                reason: "Not authorized."
            )
        } catch RequestError.invalidUser {
            throw Abort(
                .networkAuthenticationRequired,
                reason: "Invalid user"
            )
        } catch RequestError.tokenExpired {
            throw Abort(
                .networkAuthenticationRequired,
                reason: "Token expired"
            )
        } catch RequestError.userExists {
            throw Abort(
                .conflict,
                reason: "User already exists"
            )
        } catch RequestError.userNotExisting {
            throw Abort(
                .networkAuthenticationRequired,
                reason: "User does not exist"
            )
        } catch RequestError.invalidPassword {
            throw Abort(
                .networkAuthenticationRequired,
                reason: "Invalid password"
            )
        } catch RequestError.resourceNotExists {
            throw Abort(
                .networkAuthenticationRequired,
                reason: "Requested resource does not exist"
            )
        }
    }
}
