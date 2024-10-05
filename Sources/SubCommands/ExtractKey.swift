//
// Created by yechentide on 2024/10/04
//

import ArgumentParser
import LvDBWrapper
import CoreBedrock

struct ExtractKey: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "extract-key",
        abstract: "extract data using a specified key and save to a file",
        discussion: "Use this subcommand to extract data using a specified key.",
        shouldDisplay: true
    )

    @Option(name: .customLong("src"), help: "Path of a db directory.")
    var srcDir: String

    @Option(name: .customLong("dst"), help: "Path where output directory is.")
    var dstDir: String

    @Option(name: .customLong("key"), help: "A leveldb key, hex string.")
    var keyStr: String

    func run() throws {
        guard let keyData = keyStr.hexData else {
            fatalError("[ExtractKey] Error: wrong leveldb key")
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

        print("[DecodeNBT] done!\n")
    }
}
