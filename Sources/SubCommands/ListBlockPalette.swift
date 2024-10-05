//
// Created by yechentide on 2024/10/05
//

import Foundation
import ArgumentParser
import CoreBedrock

struct ListBlockPalette: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list-block-palette",
        abstract: "list block palette",
        discussion: "Use this subcommand to list block palette contained in a subChunk.",
        shouldDisplay: true
    )

    @Option(name: .customLong("src"), help: "Path of a subChunk data file.")
    var srcFilePath: String

    func run() throws {
        print("[ListBlockPalette] Decoding subChunk file \(srcFilePath)")

        let srcURL = URL(fileURLWithPath: srcFilePath)
        let subChunkData = try Data(contentsOf: srcURL)

        guard subChunkData.count >= 3 else {
            fatalError("[ListBlockPalette] Error: data is too short. (size = \(subChunkData.count))")
        }

        let storageVersion = subChunkData[0]
        let storageLayerCount = Int(subChunkData[1])
        let yIndex = subChunkData[2].data.int8
        print("[ListBlockPalette] SubChunk Version = \(storageVersion), Layer Count = \(storageLayerCount), Y Index = \(yIndex)")
        assert(storageVersion == 9)

        guard storageLayerCount > 0 else {
            fatalError("[ListBlockPalette] Error: invalid layer count \(storageLayerCount).")
        }
        guard let layers = try BlockDecoder.shared.decodeV9(data: subChunkData, offset: 3, layerCount: storageLayerCount),
              layers.count == storageLayerCount
        else {
            fatalError("[ListBlockPalette] Error: failed to decode block data.")
        }


        for layer in layers {
            print()
            for palette in layer.palettes {
                print(palette.name)
                print(palette.states.description)
                print()
            }
            print("Palette Count: \(layer.palettes.count)")
        }

        print("[ListBlockPalette] done!\n")
    }
}
