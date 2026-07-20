import Foundation

public enum ComposeSequenceTSV {
    public static func loadResource(named name: String) throws -> [ComposeSequence] {
        guard let url = Bundle.module.url(forResource: name, withExtension: "tsv") else {
            throw ComposeSequenceTSVError.missingResource("\(name).tsv")
        }
        return try load(from: url)
    }

    public static func load(from url: URL) throws -> [ComposeSequence] {
        let text = try String(contentsOf: url, encoding: .utf8)
        return try decode(text)
    }

    public static func decode(_ text: String) throws -> [ComposeSequence] {
        var rows = text.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline).enumerated().makeIterator()

        guard let (_, headerLine) = nextNonEmptyLine(from: &rows) else {
            return []
        }

        let header = fields(in: headerLine)
        guard header == ["sequence", "composed", "composedCharName", "ordered"] else {
            throw ComposeSequenceTSVError.invalidHeader(header)
        }

        var sequences: [ComposeSequence] = []
        while let (offset, line) = rows.next() {
            guard !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                continue
            }

            var fields = fields(in: line)
            if fields.count == 2 {
                fields.append("")
                fields.append("")
            }
            if fields.count == 3 {
                fields.append("")
            }
            guard fields.count == 4 else {
                throw ComposeSequenceTSVError.invalidFieldCount(offset + 1, fields.count)
            }

            sequences.append(
                try ComposeSequenceDefinition(
                    sequence: fields[0],
                    composed: fields[1],
                    composedCharName: fields[2],
                    ordered: fields[3],
                    lineNumber: offset + 1
                ).sequence
            )
        }

        return sequences
    }

    private static func nextNonEmptyLine(
        from rows: inout EnumeratedSequence<[Substring]>.Iterator
    ) -> (offset: Int, element: Substring)? {
        while let row = rows.next() {
            guard !row.element.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                continue
            }
            return row
        }
        return nil
    }

    private static func fields(in line: Substring) -> [String] {
        line.split(separator: "\t", omittingEmptySubsequences: false).map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}

public enum ComposeSequenceTSVError: Error, CustomStringConvertible {
    case invalidFieldCount(Int, Int)
    case invalidHeader([String])
    case invalidComposedCharName(Int, String)
    case invalidOrderedValue(Int, String)
    case invalidSequenceKey(Int, String)
    case missingResource(String)

    public var description: String {
        switch self {
            case let .invalidFieldCount(lineNumber, count):
                "Invalid compose sequence TSV at line \(lineNumber): expected 5 fields, got \(count)"
            case let .invalidHeader(header):
                "Invalid compose sequence TSV header: \(header.joined(separator: "\t"))"
            case let .invalidComposedCharName(lineNumber, name):
                "Invalid composed character name at line \(lineNumber): \(name)"
            case let .invalidOrderedValue(lineNumber, value):
                "Invalid ordered value at line \(lineNumber): \(value)"
            case let .invalidSequenceKey(lineNumber, value):
                "Invalid compose sequence key at line \(lineNumber): expected non-empty ASCII, got \(value)"
            case let .missingResource(name):
                "Missing compose sequence resource: \(name)"
        }
    }
}

private struct ComposeSequenceDefinition {
    var keys: [KarabinerKey]
    var composed: String
    var composedCharName: String
    var ordered: Bool

    init(
        sequence: String,
        composed: String,
        composedCharName: String,
        ordered: String,
        lineNumber: Int
    ) throws {
        self.keys = try Self.keys(in: sequence, lineNumber: lineNumber)
        self.composed = composed
        self.composedCharName = composedCharName

        if !composedCharName.isEmpty, NamedCharacter.resolve(composedCharName) == nil {
            throw ComposeSequenceTSVError.invalidComposedCharName(lineNumber, composedCharName)
        }

        switch ordered.lowercased() {
            case "":
                self.ordered = false
            case "true":
                self.ordered = true
            case "false":
                self.ordered = false
            default:
                throw ComposeSequenceTSVError.invalidOrderedValue(lineNumber, ordered)
        }
    }

    var sequence: ComposeSequence {
        let sequenceOrdering: ComposeSequence.Ordering = keys.count == 2 && !ordered ? .unordered : .fixed
        return ComposeSequence(
            keys,
            inserts: .text(resolvedComposed),
            ordering: sequenceOrdering
        )
    }

    private var resolvedComposed: String {
        NamedCharacter.resolve(composedCharName) ?? composed
    }

    private static func keys(in value: String, lineNumber: Int) throws -> [KarabinerKey] {
        guard !value.isEmpty, value.unicodeScalars.allSatisfy(\.isASCII) else {
            throw ComposeSequenceTSVError.invalidSequenceKey(lineNumber, value)
        }

        return value.unicodeScalars.map { KarabinerKey.symbol(String($0)) }
    }
}
