//
//  DataManager.swift
//  to-do-list
//
//  Created by Sain-R Edwards Jr. on 12/24/17.
//  Copyright © 2017 Appybuildmore. All rights reserved.
//

import Foundation

public class DataManager {
    
    // ToDo: Get Document Directory
    /* 'static' is used so we do not have to create an object
     from the DataManager class to be able to access it. Since we
     only need to access it inside of this file, 'fileprivate'
     is being used. */
    static fileprivate func getDocumentDirectory() -> URL {
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Unable to access document directory")
        }
    }
    
    // ToDo: Save any kind of codable objects
    static func save <T:Encodable> (_ object: T, with fileName: String) {
        let url = getDocumentDirectory().appendingPathComponent(fileName, isDirectory: false)
        
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(object)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    
    // ToDo: Load any kind of codable objects
    static func load <T: Decodable> (_ fileName: String, with type: T.Type) -> T {
        let url = getDocumentDirectory().appendingPathComponent(fileName, isDirectory: false)
        if !FileManager.default.fileExists(atPath: url.path) {
            fatalError("File not found at path \(url.path)")
        }
        
        if let data = FileManager.default.contents(atPath: url.path) {
            do {
                let model = try JSONDecoder().decode(type, from: data)
                return model
            } catch {
                fatalError(error.localizedDescription)
            }
        } else {
            fatalError("Data unavailable at patch \(url.path)")
        }
    }
    
    // ToDo: Load data from a file
    static func loadData(_ fileName: String) -> Data? {
        let url = getDocumentDirectory().appendingPathComponent(fileName, isDirectory: false)
        if !FileManager.default.fileExists(atPath: url.path) {
            fatalError("File not found at path \(url.path)")
        }
        
        if let data = FileManager.default.contents(atPath: url.path) {
            return data
        } else {
            fatalError("Data unavailable at patch \(url.path)")
        }
    }
    
    // ToDo: Load all files from a directory
    static func loadAll <T: Decodable> (_ type: T.Type) -> [T] {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: getDocumentDirectory().path)
            
            var modelObjects = [T]()
            
            for fileName in files {
                modelObjects.append(load(fileName, with: type))
            }
            
            return modelObjects
            
        } catch {
            fatalError("Could not load any files")
        }
    }
    
    // ToDo: Delete a file
    static func delete(_ fileName: String) {
        let url = getDocumentDirectory().appendingPathComponent(fileName, isDirectory: false)
        
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}

