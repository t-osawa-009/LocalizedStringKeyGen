import Foundation
import Files

enum Sort: String {
    case asc
    case desc
}

enum CreatorError: Error {
    case invalidFormat
}

enum PathExtension: String {
    case swift
}

struct LocalizedStringKeyFileCreator: FileCreatable {
    private let originText: String
    private let enumName: String
    private let outputPath: String
    private let publicAccess: Bool
    private let sort: Sort?
    init(originText: String, enumName: String, outputPath: String, publicAccess: Bool, sort: Sort?) {
        self.originText = originText
        self.enumName = enumName
        self.outputPath = outputPath
        self.publicAccess = publicAccess
        self.sort = sort
    }
    
    func write() throws {
        let urlPath = URL(fileURLWithPath: outputPath)
        let path = urlPath.deletingLastPathComponent().absoluteString
        let _path = path.replacingOccurrences(of: "file://", with: "")
        let folder = try Folder(path: _path)
        let fileName = urlPath.lastPathComponent
        let file = try folder.createFileIfNeeded(at: fileName.replacingOccurrences(of: "file://", with: ""))
        let pathExtension = urlPath.pathExtension
        guard pathExtension == PathExtension.swift.rawValue else {
            print("format is not swift")
            throw CreatorError.invalidFormat
        }
        var keys: [String] = []
        let array = originText.components(separatedBy: "\n").filter({ !$0.isEmpty })
        array.forEach { (text) in
            let result = text.components(separatedBy: "=").first
            if let _text = result?.replacingOccurrences(of: "\"", with: ""), !_text.isEmpty {
                keys.append(_text)
            }
        }
        
        if let _sort = sort {
            keys.sort(by: { value1, value2 in
                switch _sort {
                case .asc:
                    return value1 < value2
                case .desc:
                    return value1 > value2
                }
            })
        }
        let publicAccessText = publicAccess ? "public " : ""
        var strings = [String]()
        strings.insert("""

import SwiftUI

\(publicAccessText)enum \(enumName) {
""",at: 0)
        
        keys.forEach { (_key) in
            strings.append("""
    \(publicAccessText)static var \(_key): LocalizedStringKey { return "\(_key)"}
""")
        }
        strings.append("}")
        
        let results = strings.joined(separator: "\n")
        let oldData = try file.readAsString()
        if oldData == results {
            print("Not writing the file as content is unchanged")
        } else {
            try file.write(results)
        }
    }
}
