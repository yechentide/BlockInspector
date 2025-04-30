//
// Created by yechentide on 2024/10/04
//

import ArgumentParser
import LvDBWrapper
import CoreBedrock

struct ExtractChunk: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "extract-chunk",
        abstract: "extract and save data in a chunk",
        discussion: "Use this subcommand to extract data from a chunk.",
        shouldDisplay: true
    )

    @Option(name: .customLong("src"), help: "Path of a db directory.")
    var srcDir: String

    @Option(name: .customLong("dst"), help: "Path where output directory is.")
    var dstDir: String

    @Option(name: .customShort("d"), help: "World dimension. overworld = 0, theNether = 1, theEnd = 2")
    var dimension: Int32

    @Option(name: .customLong("xindex"), help: "X index of a chunk.")
    var xIndex: Int32

    @Option(name: .customLong("zindex"), help: "Z index of a chunk.")
    var zIndex: Int32

    func run() throws {
        guard let dimension = MCDimension(rawValue: dimension) else {
            fatalError("[ExtractChunk] Error: wrong dimension")
        }
        guard let db = LvDB(dbPath: srcDir),
              let iterator = db.makeIterator()
        else {
            fatalError("[ExtractChunk] Error: can't open db \(srcDir)")
        }
        defer {
            iterator.destroy()
            db.close()
        }

        print("[ExtractChunk] Extract chunk \(dimension)(\(xIndex), \(zIndex)) from \(srcDir)/db")
        print("[ExtractChunk]     to \(dstDir)")

        let prefix = (dimension == .overworld) ? xIndex.data + zIndex.data : xIndex.data + zIndex.data + dimension.rawValue.data
        let start = prefix + Data([LvDBChunkKeyType.keyTypeStartWith])

        let rootDirURL = URL(fileURLWithPath: dstDir + "/" + prefix.hexString)
        if FileManager.default.fileExists(atPath: rootDirURL.path) {
            try FileManager.default.removeItem(atPath: rootDirURL.path)
        }
        try FileManager.default.createDirectory(at: rootDirURL, withIntermediateDirectories: true)

        iterator.seek(start)
        while iterator.valid() {
            guard let key = iterator.key(), key[0..<prefix.count] == prefix else { break }
            try outputvalue(db: db, rootDirURL: rootDirURL, key: key)
            print("[ExtractChunk]     Extract key: \(key.hexString)")
            iterator.next()
        }

        let digp = "digp".data(using: .utf8)! + prefix
        if let digpData = db.get(digp), digpData.count > 0, digpData.count % 8 == 0 {
            for i in 0..<digpData.count/8 {
                let actorprefix = "actorprefix".data(using: .utf8)! + digpData[i*8...i*8+7]
                try outputvalue(db: db, rootDirURL: rootDirURL, key: actorprefix)
                print("[ExtractChunk]     Extract: actorprefix \(digpData[i*8...i*8+7].hexString)")
            }
            try outputvalue(db: db, rootDirURL: rootDirURL, key: digp)
            print("[ExtractChunk]     Extract: digp \(prefix.hexString)")
        }

        print("[ExtractChunk] done!\n")
    }

    func outputvalue(db: LvDB, rootDirURL: URL, key: Data) throws {
        if let value = db.get(key) {
            let dstFileURL = rootDirURL.appendingPathComponent(key.hexString)
            try value.write(to: dstFileURL)
        }
    }
}
