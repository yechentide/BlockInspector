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
    var dstFilePath: String

    @Option(name: .customLong("skip"), help: "Skip a specified number of leading bytes.")
    var skipBytes: Int = 0

    func run() throws {
        print("[DecodeNBT] Decoding nbt file \(srcFilePath)")

        let srcURL = URL(fileURLWithPath: srcFilePath)
        let destURL = URL(fileURLWithPath: dstFilePath)

        let nbtData = try Data(contentsOf: srcURL)
        let stream = CBBuffer(nbtData[skipBytes...])
        let reader = CBTagReader(stream)

        let rootTag = try reader.readAsTag() as! CompoundTag
        try rootTag.description.write(toFile: destURL.path, atomically: true, encoding: .utf8)

        if skipBytes > 0 {
            let bytesString = nbtData[0..<skipBytes].hexString
            print("[DecodeNBT] skip leading bytes: \(bytesString)")
        }
        print("[DecodeNBT] done!\n")
    }
}
