//
//  Photo.swift
//  Archiver
//
//  Created by Joanna Zatorska on 01/06/2017.
//
//
import Foundation
import Vapor
import FluentProvider
import HTTP

public final class Photo: Model {
    var path: String
    public let storage = Storage()
    
    public init(path: String) throws {
        self.path = path
    }
    
    public init(row: Row) throws {
        path = try row.get("path")
    }
    
    public func makeRow() throws -> Row {
        var row = Row()
        try row.set("path", path)
        return row
    }
}

extension Photo: Preparation {
    
    public static func prepare(_ database: Database) throws {
        try database.create(self) { photo in
            photo.id()
            photo.string("path")
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Photo: JSONConvertible {
    public convenience init(json: JSON) throws {
        try self.init(
            path: json.get("path")
        )
    }
    
    public func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("path", path)
        return json
    }
}

extension Photo: ResponseRepresentable {
    public func makeResponse() throws -> Response {
        let imageFolder = "Public/images"
        let filePath = URL(fileURLWithPath: Config.workingDirectory()).appendingPathComponent(imageFolder, isDirectory: true).appendingPathComponent(path, isDirectory: false)
        
        let loader = DataFile()
        
        guard let attributes = try? Foundation.FileManager.default.attributesOfItem(atPath: filePath.path),
            let modifiedAt = attributes[.modificationDate] as? Date,
            let fileSize = attributes[.size] as? NSNumber
            else {
                throw Abort.notFound
        }
        
        var headers: [HeaderKey: String] = [:]
        
        // Generate ETag value, "HEX value of last modified date" + "-" + "file size"
        let fileETag = "\(modifiedAt.timeIntervalSince1970)-\(fileSize.intValue)"
        
        headers["ETag"] = fileETag
        
        headers["Content-Type"] = "image/png"
        
        if let fileBody = try? loader.read(at: filePath.path) {
            return Response(status: .ok, headers: headers, body: .data(fileBody))
        } else {
            throw Abort.notFound
        }
    }
}

extension Request {
    func photo() throws -> Photo {
        guard let fileData = body.bytes else {
            throw Abort(.badRequest, metadata: "No file in request")
        }
        
        let fileName = UUID().uuidString + ".png"
        let imageFolder = "Public/images"
        let saveURL = URL(fileURLWithPath: Config.workingDirectory()).appendingPathComponent(imageFolder, isDirectory: true).appendingPathComponent(fileName, isDirectory: false)
        
        do {
            let data = Data(bytes: fileData)
            try data.write(to: saveURL)
        } catch {
            throw Abort(.internalServerError, metadata: "Unable to write multipart form data to file.")
        }
        return try Photo(path: fileName)
    }
}
