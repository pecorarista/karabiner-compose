import Foundation
import Testing
@testable import KarabinerCompose

@Test func tsvDecodesSequences() throws {
    let sequences = try ComposeSequenceTSV.decode("""
    sequence	composed	composedCharName	ordered
    ae	æ
    ah	ɑ		true
    "a	ä
    c,	ç
    ^^j	ʲ
    g.		latinSmallLetterScriptG
    """)

    #expect(sequences.map { $0.keys.map(\.symbol) } == [["a", "e"], ["a", "h"], ["\"", "a"], ["c", ","], ["^", "^", "j"], ["g", "."]])
    #expect(sequences.map { $0.output.resolvedText } == ["æ", "ɑ", "ä", "ç", "ʲ", "ɡ"])
    #expect(sequences.map(\.ordering) == [.unordered, .fixed, .unordered, .unordered, .fixed, .unordered])
}

@Test func tsvHandlesCRLFAndPaddedFields() throws {
    let text = "sequence\tcomposed\tcomposedCharName\tordered\r\n ae \t æ \t \t \r\n ah \t ɑ \t \t true \r\n"
    let sequences = try ComposeSequenceTSV.decode(text)

    #expect(sequences.map { $0.keys.map(\.symbol) } == [["a", "e"], ["a", "h"]])
    #expect(sequences.map { $0.output.resolvedText } == ["æ", "ɑ"])
    #expect(sequences.map(\.ordering) == [.unordered, .fixed])
}

@Test func tsvRejectsNonASCIIComposeKeys() {
    #expect(throws: ComposeSequenceTSVError.self) {
        _ = try ComposeSequenceTSV.decode("""
        sequence	composed	composedCharName	ordered
        ˄j	ʲ
        """)
    }
}

@Test func namedCharactersUseCodePoints() {
    #expect(NamedCharacter.resolve("latinSmallLetterScriptG") == "ɡ")
    #expect(NamedCharacter.resolve("latinSmallLetterScriptG") != "g")
    #expect(NamedCharacter.resolve("latinSmallLetterTurnedE") == "ǝ")
    #expect(NamedCharacter.resolve("latinCapitalLetterTurnedE") == "Ǝ")
}

@Test func unicodeNameOutputRemainsAvailable() {
    let output = ComposeOutput.unicodeName("LATIN SMALL LETTER SCRIPT G")
    #expect(output.resolvedText == "ɡ")
}

@Test func generatedJSONContainsKarabinerRule() throws {
    let profile = ComposeProfile(title: "Test Compose") {
        sequence("'", "a", inserts: "á")
        sequence("l", "e", inserts: "ɛ")
        sequence("^", "^", "j", inserts: "ʲ", ordering: .fixed)
    }

    let data = try KarabinerJSONEncoder.encode(profile)
    let json = String(decoding: data, as: UTF8.self)

    #expect(json.contains("Test Compose"))
    #expect(json.contains("Compose ' a -> á"))
    #expect(json.contains("Compose a ' -> á"))
    #expect(json.contains("Compose l e -> ɛ"))
    #expect(json.contains("Compose e l -> ɛ"))
    #expect(json.contains("Compose ^ ^..."))
    #expect(json.contains("Compose ^ ^ j -> ʲ"))
    #expect(json.contains("right_command_compose_state"))
}

@Test func fixedOrderSequenceDoesNotGenerateReverseRule() throws {
    let profile = ComposeProfile(title: "Test Compose") {
        sequence("a", "h", inserts: "ɑ", ordering: .fixed)
    }

    let data = try KarabinerJSONEncoder.encode(profile)
    let json = String(decoding: data, as: UTF8.self)

    #expect(json.contains("Compose a h -> ɑ"))
    #expect(!json.contains("Compose h a -> ɑ"))
}

@Test func defaultProfileLoadsTSV() throws {
    let profile = try DefaultProfile.makeProfile()
    let expectedSequences: [([String], String, ComposeSequence.Ordering)] = [
        (["e", "e"], "ə", .fixed),
        (["a", "e"], "æ", .unordered),
        (["t", "e"], "ǝ", .fixed),
        (["-", ">"], "→", .fixed),
        ([".", "g"], "ġ", .unordered),
        (["g", "g"], "ɡ", .unordered),
        (["r", "r"], "ɹ", .unordered),
        (["h", "h"], "ɥ", .unordered),
        (["c", "c"], "ɕ", .unordered),
        (["z", "z"], "ʑ", .unordered),
        (["r", "h"], "ɤ", .fixed),
        (["^", "^", "j"], "ʲ", .fixed),
        (["^", "^", "w"], "ʷ", .fixed),
        (["^", "^", "h"], "ʰ", .fixed),
        (["^", "^", "H"], "ᶣ", .fixed),
        (["(", "a"], "ă", .unordered),
        (["(", "e"], "ĕ", .unordered),
        (["(", "i"], "ĭ", .unordered),
        (["(", "o"], "ŏ", .unordered),
        (["(", "u"], "ŭ", .unordered),
        (["(", "A"], "Ă", .unordered),
        (["(", "E"], "Ĕ", .unordered),
        (["(", "I"], "Ĭ", .unordered),
        (["(", "O"], "Ŏ", .unordered),
        (["(", "U"], "Ŭ", .unordered),
        (["<", "a"], "ǎ", .unordered),
        (["<", "e"], "ě", .unordered),
        (["<", "i"], "ǐ", .unordered),
        (["<", "o"], "ǒ", .unordered),
        (["<", "u"], "ǔ", .unordered),
        (["<", "c"], "č", .unordered),
        (["<", "s"], "š", .unordered),
        (["<", "z"], "ž", .unordered),
        (["<", "r"], "ř", .unordered),
        (["<", "t"], "ť", .unordered),
        ([".", "h"], "ḥ", .unordered),
        ([".", "s"], "ṣ", .unordered)
    ]

    for (keys, output, ordering) in expectedSequences {
        #expect(profile.sequences.contains {
            $0.keys.map(\.symbol) == keys && $0.output.resolvedText == output && $0.ordering == ordering
        })
    }
}

@Test func defaultProfileStaticProfileRemainsAvailable() {
    #expect(DefaultProfile.profile.sequences.contains {
        $0.keys.map(\.symbol) == ["e", "e"] && $0.output.resolvedText == "ə"
    })
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

@Test func reversedDuplicateSequencesAreRejected() {
    let profile = ComposeProfile {
        sequence("a", "e", inserts: "æ")
        sequence("e", "a", inserts: "ǽ")
    }

    #expect(throws: ComposeGenerationError.self) {
        _ = try KarabinerJSONEncoder.encode(profile)
    }
}

@Test func ambiguousPrefixSequencesAreRejected() {
    let profile = ComposeProfile {
        sequence("^", "^", "h", inserts: "ʰ", ordering: .fixed)
        sequence("^", "^", "h", "h", inserts: "ᶣ", ordering: .fixed)
    }

    #expect(throws: ComposeGenerationError.self) {
        _ = try KarabinerJSONEncoder.encode(profile)
    }
}
