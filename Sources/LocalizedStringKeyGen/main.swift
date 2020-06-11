import Foundation
import Commander
import Files

let main = command(
    Option<String>("localize_path", default: ".", description: "parse localize files"),
    Option<String>("config_path", default: ".", description: "Manage and run configuration files")
) { (jsonPath, config_path) in
    guard let folder = try? File(path: jsonPath), let text = try? folder.readAsString() else {
        print("not found localize file")
        return
    }
    
    do {
        let yaml = try Yaml(path: config_path)
        guard let strings = YamlStringsParser(jsons: yaml.jsons) else {
            print("failure parse yml file")
            return
        }
        strings.outputs.forEach { (output) in
            let writer = LocalizedStringKeyFileCreator(originText: text,
                                                       enumName: output.enumName,
                                                       outputPath: output.output,
                                                       publicAccess: output.publicAccess,
                                                       sort: output.sort)
            do {
                try writer.write()
                print("Generate Success!!!")
            } catch {
                print(error.localizedDescription)
            }
        }
    } catch {
        print(error.localizedDescription)
    }
}
main.run()
