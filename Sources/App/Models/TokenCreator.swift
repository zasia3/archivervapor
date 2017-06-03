//
//  TokenCreator.swift
//  Archiver
//
//  Created by Joanna Zatorska on 31/05/2017.
//
//

import Vapor

class TokenCreator {
    
    static func token(username: String, userPassword: String) throws -> String {
        
        let hash = CryptoHasher(hash: .sha1, encoding: .base64)
        let hashed = try hash.make("\(username)\(userPassword)\(Date())")
        
        return String(bytes: hashed)
    }
}
