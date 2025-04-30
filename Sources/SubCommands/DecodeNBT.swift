//
// Created by yechentide on 2024/10/04
//

import Foundation
import ArgumentParser
import CoreBedrock

struct DecodeNBT: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "decode-nbt",
        abstract: "decode nbt data",
        discussion: "Use this subcommand to decode nbt data and save to a file.",
        shouldDisplay: true
    )

    @Option(name: .customLong("src"), help: "Path of a nbt data file.")
    var srcFilePath: String

    @Option(name: .customLong("dst"), help: "Path of the output.")
    var dstFilePath: String? = nil

    @Option(name: .customLong("skip"), help: "Skip a specified number of leading bytes.")
    var skipBytes: Int = 0

    func run() throws {
        print("[DecodeNBT] Decoding nbt file \(srcFilePath)")

        let srcURL = URL(fileURLWithPath: srcFilePath)
        let nbtData = try Data(contentsOf: srcURL)
        let reader = CBTagReader(data: nbtData[skipBytes...])
        let tags = try reader.readAll()

        for rootTag in tags {
            if let dstFilePath {
                let destURL = URL(fileURLWithPath: dstFilePath)
                try rootTag.description.write(toFile: destURL.path, atomically: true, encoding: .utf8)
            } else {
                print(rootTag.description)
            }
        }

        if skipBytes > 0 {
            let bytesString = nbtData[0..<skipBytes].hexString
            print("[DecodeNBT] skip leading bytes: \(bytesString)")
        }
        if reader.remainingByteCount > 0 {
            let offset = nbtData.index(-reader.remainingByteCount, offsetBy: nbtData.endIndex)
            let bytesString = nbtData[offset...].hexString
            print("[DecodeNBT] skip trailing bytes: \(bytesString)")
        }
        print("[DecodeNBT] parsed \(tags.count) root \(tags.count > 1 ? "tags" : "tag")")
        print("[DecodeNBT] done!\n")
    }
}
