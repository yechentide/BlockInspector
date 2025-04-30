//
// Created by yechentide on 2025/04/21
//

import ArgumentParser
import LvDBWrapper
import CoreBedrock

extension LvDBKeyType {
    func outputURL(in dirURL: URL) throws -> URL {
        let chunksDir           = dirURL.appendingPathComponent("chunks", conformingTo: .directory)
        let playersDir          = dirURL.appendingPathComponent("players", conformingTo: .directory)
        let mapsDir             = dirURL.appendingPathComponent("maps", conformingTo: .directory)
        let villagesDir         = dirURL.appendingPathComponent("villages", conformingTo: .directory)
        let structuresDir       = dirURL.appendingPathComponent("structures", conformingTo: .directory)
        let actorsDir           = dirURL.appendingPathComponent("actors", conformingTo: .directory)
        let realmsStoriesData   = dirURL.appendingPathComponent("realmsStoriesData", conformingTo: .directory)
        let otherDir            = dirURL.appendingPathComponent("other", conformingTo: .directory)
        let unknowDir           = dirURL.appendingPathComponent("unknown", conformingTo: .directory)

        switch self {
            case .subChunk(let x, let z, let dimension, let type, let y):
                let dirName = "@\(dimension).\(x).\(z)"
                var fileName = type == .subChunkPrefix ? "\(x).\(y!).\(z)" : "\(x).\(z).\(type)"
                if "\(type)".hasPrefix("unknown") {
                    fileName = "@\(dimension).\(x).\(z).\(type)"
                }
                let chunkDir = chunksDir.appendingPathComponent(dirName, conformingTo: .directory)
                let filePath = chunkDir.appendingPathComponent(fileName, isDirectory: false)
                try FileManager.default.createDirectoryIfMissing(at: chunkDir)
                return filePath
            case .string(let type):
                if type == .localPlayer {
                    return playersDir.appendingPathComponent(type.rawValue, conformingTo: .directory)
                }
                return otherDir.appendingPathComponent(type.rawValue, conformingTo: .directory)
            case .player(let keyData):
                let keyString = String(data: keyData, encoding: .utf8)!
                return playersDir.appendingPathComponent(keyString, conformingTo: .directory)
            case .map(let idData):
                let id = String(data: idData, encoding: .utf8)!
                return mapsDir.appendingPathComponent(id, conformingTo: .directory)
            case .village(let keyNameData):
                let keyName = String(data: keyNameData, encoding: .utf8)!
                return villagesDir.appendingPathComponent(keyName, conformingTo: .directory)
            case .structure(let keyNameData):
                let keyName = String(data: keyNameData, encoding: .utf8)!
                return structuresDir.appendingPathComponent(keyName, conformingTo: .directory)
            case .actorprefix(let idData):
                return actorsDir.appendingPathComponent(idData.hexString, conformingTo: .directory)
            case .digp(let x, let z, let dimension):
                let dirName = "@\(dimension).\(x).\(z)"
                let fileName = "digp.txt"
                let chunkDir = chunksDir.appendingPathComponent(dirName, conformingTo: .directory)
                let filePath = chunkDir.appendingPathComponent(fileName, isDirectory: false)
                try FileManager.default.createDirectoryIfMissing(at: chunkDir)
                return filePath
            case .realmsStoriesData(let idData):
                return realmsStoriesData.appendingPathComponent(idData.hexString, conformingTo: .directory)
            case .unknown(let data):
                return unknowDir.appendingPathComponent(data.hexString, conformingTo: .directory)
        }
    }
}

struct ExtractAllKey: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "extract-all-key",
        abstract: "Extracts all entries from a LevelDB database and saves them to categorized files.",
        discussion: """
        Use this subcommand to extract all entries from a LevelDB-based database (such as Minecraft Bedrock's world data).
        Each entry is saved into a categorized subdirectory (e.g., chunks, players, maps).
        If the destination directory already exists, use --override to delete and recreate it.
        """,
        shouldDisplay: true
    )

    @Option(name: .customLong("src"), help: "Path to the source LevelDB directory.")
    var srcDir: String

    @Option(name: .customLong("dst"), help: "Path to the directory where extracted files will be saved.")
    var dstDir: String

    @Flag(name: .customLong("override"), help: "If set, deletes the destination directory before writing new files.")
    var overrideDir = false

    func createSubDirectories(in baseDirURL: URL) throws {
        print("[ExtractAllKey] creating sub-directorys ...")
        let names = ["chunks", "players", "maps", "villages", "structures", "actors", "realmsStoriesData", "other", "unknown"]
        for subDirName in names {
            let subDirURL = baseDirURL.appendingPathComponent(subDirName, conformingTo: .directory)
            try FileManager.default.createDirectoryIfMissing(at: subDirURL)
        }
        print("[ExtractAllKey] sub-directorys creation done!")
    }

    func run() throws {
        guard let db = LvDB(dbPath: srcDir),
              let iterator = db.makeIterator()
        else {
            fatalError("[ExtractAllKey] Error: can't open db \(srcDir)")
        }
        defer {
            iterator.destroy()
            db.close()
        }

        print("[ExtractAllKey] Extract from \(srcDir)/db")
        print("[ExtractAllKey]     to \(dstDir)")

        let rootDirURL = URL(fileURLWithPath: dstDir)
        if FileManager.default.fileExists(atPath: rootDirURL.path) {
            if overrideDir {
                try FileManager.default.removeItem(at: rootDirURL)
            } else {
                fatalError("[ExtractAllKey] Error: output directory exists and --override is not set.")
            }
        }
        try FileManager.default.createDirectory(at: rootDirURL, withIntermediateDirectories: true)
        try createSubDirectories(in: rootDirURL)

        iterator.seekToFirst()
        while iterator.valid() {
            defer {
                iterator.next()
            }
            guard let keyData = iterator.key(),
                  let valueData = iterator.value()
            else {
                print("===> skipped: \(iterator.key()?.hexString ?? "bad leveldb key")")
                continue
            }
            let key = LvDBKeyType.parse(data: keyData)
            let url = try key.outputURL(in: rootDirURL)
            if case .unknown(let data) = key {
                print("WARNING: unknown key \(data.hexString)")
            }
            try valueData.write(to: url)
        }

        print("[ExtractAllKey] Done!\n")
    }
}
