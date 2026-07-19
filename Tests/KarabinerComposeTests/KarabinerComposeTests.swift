import Foundation
import Testing
@testable import KarabinerCompose

@Test func tsvDecodesSequences() throws {
    let sequences = try ComposeSequenceTSV.decode("""
    char1	char2	composed	composedCharName	ordered
    a	e	æ
    a	h	ɑ		true
    "	a	ä
    c	,	ç
    g	.		latinSmallLetterScriptG
    """)

    #expect(sequences.map { $0.keys.map(\.symbol) } == [["a", "e"], ["a", "h"], ["\"", "a"], ["c", ","], ["g", "."]])
    #expect(sequences.map { $0.output.resolvedText } == ["æ", "ɑ", "ä", "ç", "ɡ"])
    #expect(sequences.map(\.ordering) == [.unordered, .fixed, .unordered, .unordered, .unordered])
}

@Test func tsvHandlesCRLFAndPaddedFields() throws {
    let text = "char1\tchar2\tcomposed\tcomposedCharName\tordered\r\n a \t e \t æ \t \t \r\n a \t h \t ɑ \t \t true \r\n"
    let sequences = try ComposeSequenceTSV.decode(text)

    #expect(sequences.map { $0.keys.map(\.symbol) } == [["a", "e"], ["a", "h"]])
    #expect(sequences.map { $0.output.resolvedText } == ["æ", "ɑ"])
    #expect(sequences.map(\.ordering) == [.unordered, .fixed])
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
    }

    let data = try KarabinerJSONEncoder.encode(profile)
    let json = String(decoding: data, as: UTF8.self)

    #expect(json.contains("Test Compose"))
    #expect(json.contains("Compose ' a -> á"))
    #expect(json.contains("Compose a ' -> á"))
    #expect(json.contains("Compose l e -> ɛ"))
    #expect(json.contains("Compose e l -> ɛ"))
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

    #expect(profile.sequences.contains {
        $0.keys.map(\.symbol) == ["e", "e"] && $0.output.resolvedText == "ə" && $0.ordering == .fixed
    })
    #expect(profile.sequences.contains {
        $0.keys.map(\.symbol) == ["a", "e"] && $0.output.resolvedText == "æ" && $0.ordering == .unordered
    })
    #expect(profile.sequences.contains {
        $0.keys.map(\.symbol) == ["t", "e"] && $0.output.resolvedText == "ǝ" && $0.ordering == .fixed
    })
    #expect(profile.sequences.contains {
        $0.keys.map(\.symbol) == [".", "h"] && $0.output.resolvedText == "ḥ" && $0.ordering == .unordered
    })
    #expect(profile.sequences.contains {
        $0.keys.map(\.symbol) == [".", "s"] && $0.output.resolvedText == "ṣ" && $0.ordering == .unordered
    })
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
