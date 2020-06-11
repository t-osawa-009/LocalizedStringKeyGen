import Foundation
import Yams
import Files

struct Yaml {
    let jsons: [[String: Any]]
    init(path: String) throws {
        let folder = try Folder(path: path)
        let file = try folder.file(named: ".LocalizedStringKeyGen.yml")
        let string = try file.readAsString()
        var items = try Yams.load_all(yaml: string)
        var _result: [[String: Any]] = []
        while let item = items.next() {
            if let _item = item as? [String: Any] {
                _result.append(_item)
            }
        }
        self.jsons = _result
    }
}

struct YamlStringsParser {
    struct Output {
        let output: String
        let enumName: String
        let publicAccess: Bool
        let sort: Sort?
    }
    
    var outputs: [Output]
    init?(jsons: [[String: Any]]) {
        var _outputs: [Output] = []
        jsons.forEach { (json) in
            guard let outputs = json["outputs"] as? [[String: Any]] else {
                return
            }
            outputs.forEach { (dic) in
                guard let output = dic["output"] as? String else {
                    return
                }
                
                guard let enumName = dic["enumName"] as? String else {
                    return
                }
                let publicAccess = dic["publicAccess"] as? Bool ?? false
                let sortValue = dic["sort"] as? String
                let sort = Sort(rawValue: sortValue ?? "")
                let value = Output(output: output,
                                   enumName: enumName,
                                   publicAccess: publicAccess,
                                   sort: sort)
                _outputs.append(value)
            }
        }
        if _outputs.isEmpty {
            return nil
        } else {
            self.outputs = _outputs
        }
    }
}
