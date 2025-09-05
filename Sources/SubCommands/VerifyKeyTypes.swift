//
// Created by yechentide on 2025/02/22
//

import ArgumentParser
import LvDBWrapper
import CoreBedrock

struct VerifyKeyTypes: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "verify-key-types",
        abstract: "Verify key types in the database",
        discussion: "Use this subcommand to verify key types in the database.",
        shouldDisplay: true
    )

    @Option(name: .customLong("src"), help: "Path of a db directory.")
    var srcDir: String

    func run() throws {
        let db = try LvDB(dbPath: srcDir)
        let iterator = try db.makeIterator()
        defer {
            iterator.destroy()
            db.close()
        }

        iterator.seekToFirst()
        var totalKeys = 0
        var unknownKeysData = [Data]()
        while iterator.valid() {
            guard let keyData = iterator.key() else {
                fatalError("[VerifyKeyTypes] Error: can't extract leveldb key")
            }
            totalKeys += 1
            let keyType = LvDBKeyType.parse(data: keyData)
            if case .unknown(_) = keyType {
                unknownKeysData.append(keyData)
                print(keyData.hexString)
                print()
            }
            iterator.next()
        }

        print("[VerifyKeyTypes] total keys: \(totalKeys)")
        print("[VerifyKeyTypes] unknown keys found: \(unknownKeysData.count)")
        for unknownKeyData in unknownKeysData {
            print(unknownKeyData.hexString)
        }
        print("[VerifyKeyTypes] done!\n")
    }
}
