//
// Created by yechentide on 2024/10/05
//

import Foundation
import ArgumentParser
import CoreBedrock

struct ListBlockPalette: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list-block-palette",
        abstract: "Displays the block and water palettes from a sub-chunk binary file.",
        discussion: """
        Parses a Minecraft Bedrock Edition sub-chunk binary file and displays its block and water palettes.
        Optionally, use --show-blocks to print all block placements in the chunk.
        """,
        shouldDisplay: true
    )

    @Option(name: .customLong("src"), help: "Path to the sub-chunk binary data file.")
    var subChunkFilePath: String

    @Flag(name: .customLong("show-blocks"), help: "Also display the 3D block layout within the sub-chunk.")
    var showBlocks = false

    func run() throws {
        print("[ListBlockPalette] Decoding sub-chunk file \(subChunkFilePath)")

//        let srcURL = URL(fileURLWithPath: subChunkFilePath)
//        let subChunkData = try Data(contentsOf: srcURL)
//
//        guard subChunkData.count >= 3 else {
//            fatalError("[ListBlockPalette] Error: sub-chunk data is too short. size = \(subChunkData.count) byte(s)")
//        }
//
//        let storageVersion = subChunkData[0]
//        let storageLayerCount = Int(subChunkData[1])
//        let chunkY = subChunkData[2].data.int8
//        print("[ListBlockPalette] SubChunk Version = \(storageVersion), Layer Count = \(storageLayerCount), Y Index = \(chunkY)")
//        guard [8, 9].contains(storageVersion) else {
//            fatalError("[ListBlockPalette] Error: Unsupported storage version \(storageVersion). Expected version 9.")
//        }
//
//        guard storageLayerCount > 0 else {
//            fatalError("[ListBlockPalette] Error: invalid storage layer count \(storageLayerCount).")
//        }
//        let parser = BlockDataParser(data: subChunkData, chunkY: chunkY)
//        guard let subChunk = try parser.parse() else {
//            fatalError("[ListBlockPalette] Error: failed to decode block data from sub-chunk.")
//        }
//
//        print("========== Info ==========")
//        print("Storage Version: \(storageVersion)")
//        print("Layer Count    : \(storageLayerCount)")
//        print("Chunk Y Index  : \(chunkY)")
//        print()
//
//        print("========== Block Palette ==========")
//        for palette in subChunk.blockPalette {
//            print(palette.type)
//            print(palette.states)
//            print()
//        }
//
//        print("========== Water Palette ==========")
//        for palette in subChunk.waterPalette {
//            print(palette.type)
//            print(palette.states)
//            print()
//        }
//
//        if showBlocks {
//            print("========== ========== ==========")
//            for index in 0..<MCSubChunk.totalBlockCount {
//                let x = index / (MCSubChunk.sideLength * MCSubChunk.sideLength)
//                let z = (index / MCSubChunk.sideLength) % MCSubChunk.sideLength
//                let y = index % MCSubChunk.sideLength
//
//                if let block = subChunk.block(atLocalX: x, localY: y, localZ: z) {
//                    print(String(format: "(%2d,%2d,%2d): %@", x, y, z, String(describing: block.type)))
//                } else {
//                    print(String(format: "!!!!!! (%2d,%2d,%2d): Block data missing or corrupted", x, y, z))
//                }
//            }
//        }
//
//        print()
//        print("[ListBlockPalette] Done!\n")
    }
}
