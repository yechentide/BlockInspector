//
// Created by yechentide on 2024/10/04
//

import ArgumentParser
import LvDBWrapper
import CoreBedrock

struct ExtractKey: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "extract-key",
        abstract: "Extracts a LevelDB entry by its key and saves the value to a file.",
        discussion: """
        Use this subcommand to extract a single value from a LevelDB database using a raw key.
        The key must be provided as a hexadecimal string.
        The result will be saved to a file in the specified output directory, named after the key.
        """,
        shouldDisplay: true
    )

    @Option(name: .customLong("src"), help: "Path to the source LevelDB directory.")
    var srcDir: String

    @Option(name: .customLong("dst"), help: "Path to the directory where the output file will be saved.")
    var dstDir: String

    @Option(name: .customLong("key"), help: "The LevelDB key (hexadecimal string) to extract.")
    var keyStr: String

    func run() throws {
        guard let keyData = keyStr.hexData else {
            fatalError("[ExtractKey] Error: invalid LevelDB key (must be a valid hex string): \(keyStr)")
        }
        guard let db = LvDB(dbPath: srcDir) else {
            fatalError("[ExtractKey] Error: can't open db \(srcDir)")
        }
        guard let value = db.get(keyData), value.count > 0 else {
            db.close()
            fatalError("[ExtractKey] Error: data not found. key=\(keyStr)")
        }
        defer {
            db.close()
        }

        print("[ExtractKey] Extract data from \(srcDir)")
        print("[ExtractKey]     to \(dstDir)")

        let url = URL(fileURLWithPath: dstDir + "/" + keyStr + ".dat")
        try value.write(to: url)

        print("[ExtractKey] Done!\n")
    }
}
