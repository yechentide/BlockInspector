// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser

@main
struct BlockInspector: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "block-inspector",
        discussion: "A tool to handle data in Minecraft Bedrock's leveldb",
        version: "0.0.1",
        shouldDisplay: true,
        subcommands: [
            VerifyKeyTypes.self,
            ExtractKey.self,
            ExtractChunk.self,
            ExtractAllKey.self,
            DecodeNBT.self,
            ListBlockPalette.self,
        ]
    )
}
