//
// Created by yechentide on 2024/10/04
//

import Foundation
import ArgumentParser
import CoreBedrock

struct DecodeNBT: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "decode-nbt",
        abstract: "Decodes NBT (Named Binary Tag) data from a file.",
        discussion: """
        Use this subcommand to decode NBT (Named Binary Tag) data from a binary file.
        You can specify the number of bytes to skip at the beginning, and choose to either print the result to stdout or write it to a file.
        """,
        shouldDisplay: true
    )

    @Option(name: .customLong("src"), help: "Path to the input NBT data file to decode.")
    var inputFilePath: String

    @Option(name: .customLong("dst"), help: "Path where the decoded output will be saved. If omitted, output will be printed to stdout.")
    var outputFilePath: String? = nil

    @Option(name: .customLong("skip"), help: "Number of bytes to skip from the beginning of the input file (useful for skipping headers).")
    var skipBytes: Int = 0

    func run() throws {
        print("[DecodeNBT] Decoding NBT file at: \(inputFilePath)")

        let srcURL = URL(fileURLWithPath: inputFilePath)
        let nbtData = try Data(contentsOf: srcURL)
        let reader = CBTagReader(data: nbtData[skipBytes...])
        let tags = try reader.readAll()

        for rootTag in tags {
            if let outputFilePath {
                let destURL = URL(fileURLWithPath: outputFilePath)
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
        print("[DecodeNBT] Successfully parsed \(tags.count) root \(tags.count > 1 ? "tags" : "tag")")
        print("[DecodeNBT] Done!\n")
    }
}
