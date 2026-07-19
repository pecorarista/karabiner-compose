import Foundation
import Testing
@testable import KarabinerCompose

@Test func accentExpansionBuildsSequences() {
    let sequences = accent("'", bases: "ae", outputs: "áé")
    #expect(sequences.map { $0.output.resolvedText } == ["á", "é"])
}

@Test func unicodeNameOutputResolvesConfusableCharacter() {
    let output = ComposeOutput.unicodeName("LATIN SMALL LETTER SCRIPT G")
    #expect(output.resolvedText == "ɡ")
    #expect(output.resolvedText != "g")
}

@Test func generatedJSONContainsKarabinerRule() throws {
    let profile = ComposeProfile(title: "Test Compose") {
        sequence("'", "a", inserts: "á")
        sequence("l", "e", inserts: .unicodeName("LATIN SMALL LETTER OPEN E"))
    }

    let data = try KarabinerJSONEncoder.encode(profile)
    let json = String(decoding: data, as: UTF8.self)

    #expect(json.contains("Test Compose"))
    #expect(json.contains("Compose ' a -> á"))
    #expect(json.contains("Compose l e -> ɛ"))
    #expect(json.contains("right_command_compose_state"))
}

@Test func duplicateSequencesAreRejected() {
    let profile = ComposeProfile {
        sequence("a", "e", inserts: "æ")
        sequence("a", "e", inserts: "ǽ")
    }

    #expect(throws: ComposeGenerationError.self) {
        _ = try KarabinerJSONEncoder.encode(profile)
    }
}