//
// Created by yechentide on 2024/10/04
//

import ArgumentParser
import LvDBWrapper
import CoreBedrock

struct ExtractChunk: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "extract-chunk",
        abstract: "Extracts and saves all LevelDB records belonging to a specific chunk.",
        discussion: """
        Use this subcommand to extract all records associated with a specific chunk from a LevelDB-based world database.
        Specify the dimension and chunk coordinates (X, Z). Output will be saved in a uniquely named subdirectory.
        This is useful for inspecting or debugging individual Minecraft Bedrock chunks.
        """,
        shouldDisplay: true
    )

    @Option(name: .customLong("src"), help: "Path to the source LevelDB directory.")
    var srcDir: String

    @Option(name: .customLong("dst"), help: "Path to the directory where extracted chunk data will be saved.")
    var dstDir: String

    @Option(name: .customShort("d"), help: "Dimension ID of the world. 0 = Overworld, 1 = The Nether, 2 = The End.")
    var dimension: Int32

    @Option(name: .customLong("xindex"), help: "X coordinate of the target chunk.")
    var xIndex: Int32

    @Option(name: .customLong("zindex"), help: "Z coordinate of the target chunk.")
    var zIndex: Int32

    func run() throws {
        guard let dimension = MCDimension(rawValue: dimension) else {
            fatalError("[ExtractChunk] Error: Invalid dimension value \(dimension). Expected 0, 1, or 2.")
        }
        let db = try LvDB(dbPath: srcDir)
        let iterator = try db.makeIterator()
        defer {
            iterator.destroy()
            db.close()
        }

        print("[ExtractChunk] Extracting chunk at \(dimension)(\(xIndex), \(zIndex)) in dimension \(dimension) from \(srcDir)/db")
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
        if let digpData = try? db.get(digp), digpData.count > 0, digpData.count % 8 == 0 {
            for i in 0..<digpData.count/8 {
                let actorprefix = "actorprefix".data(using: .utf8)! + digpData[i*8...i*8+7]
                try outputvalue(db: db, rootDirURL: rootDirURL, key: actorprefix)
                print("[ExtractChunk]     Extract: actorprefix \(digpData[i*8...i*8+7].hexString)")
            }
            try outputvalue(db: db, rootDirURL: rootDirURL, key: digp)
            print("[ExtractChunk]     Extract: digp \(prefix.hexString)")
        }

        print("[ExtractChunk] Done!\n")
    }

    func outputvalue(db: LvDB, rootDirURL: URL, key: Data) throws {
        if let value = try? db.get(key) {
            let dstFileURL = rootDirURL.appendingPathComponent(key.hexString)
            try value.write(to: dstFileURL)
        }
    }
}
