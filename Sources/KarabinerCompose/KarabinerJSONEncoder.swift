import Foundation

public enum KarabinerJSONEncoder {
    public static func encode(_ profile: ComposeProfile) throws -> Data {
        let document = KarabinerDocument(
            title: profile.title,
            rules: [
                .init(
                    description: profile.description,
                    manipulators: try manipulators(for: profile)
                )
            ]
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(document)
    }

    private static func manipulators(for profile: ComposeProfile) throws -> [Manipulator] {
        try validate(profile.sequences)
        let sequences = profile.sequences.flatMap(variants(for:))
        var manipulators: [Manipulator] = [composeKeyManipulator(profile)]
        var seenIntermediateTransitions: Set<IntermediateTransition> = []

        for sequence in sequences {
            for index in sequence.keys.indices {
                let fromState = state(for: sequence.keys.prefix(index))
                let key = sequence.keys[index]
                let keys = Array(sequence.keys.prefix(index + 1))

                if index == sequence.keys.index(before: sequence.keys.endIndex) {
                    let output = sequence.output.resolvedText
                    manipulators.append(
                        Manipulator(
                            description: "Compose \(keySymbols(in: sequence.keys)) -> \(output)",
                            from: key.event,
                            to: pasteText(output, stateName: profile.stateName),
                            conditions: [.variableIf(profile.stateName, fromState)]
                        )
                    )
                } else {
                    let transition = IntermediateTransition(fromState: fromState, key: key)
                    guard seenIntermediateTransitions.insert(transition).inserted else {
                        continue
                    }

                    manipulators.append(
                        Manipulator(
                            description: "Compose \(keySymbols(in: keys))...",
                            from: key.event,
                            to: [.setVariable(profile.stateName, state(for: keys))],
                            conditions: [.variableIf(profile.stateName, fromState)]
                        )
                    )
                }
            }
        }

        manipulators.append(
            Manipulator(
                description: "Cancel compose mode with escape",
                from: KarabinerEvent(keyCode: "escape", modifiers: .init(mandatory: nil, optional: ["any"])),
                to: [.setVariable(profile.stateName, .int(0))],
                conditions: [.variableUnless(profile.stateName, .int(0))]
            )
        )
        return manipulators
    }

    private static func state(for keys: ArraySlice<KarabinerKey>) -> VariableValue {
        state(for: Array(keys))
    }

    private static func state(for keys: [KarabinerKey]) -> VariableValue {
        guard !keys.isEmpty else {
            return .string("start")
        }
        return .string("compose_\(keySymbols(in: keys, separator: "_"))")
    }

    private static func keySymbols(in keys: [KarabinerKey], separator: String = " ") -> String {
        keys.map(\.symbol).joined(separator: separator)
    }

    private struct IntermediateTransition: Hashable {
        var fromState: VariableValue
        var key: KarabinerKey
    }

    private static func validate(_ sequences: [ComposeSequence]) throws {
        var seen: Set<[KarabinerKey]> = []
        let sequences = sequences.flatMap(variants(for:))
        for sequence in sequences {
            guard sequence.keys.count >= 2 else {
                throw ComposeGenerationError.unsupportedSequenceLength(sequence.keys.map(\.symbol))
            }
            guard seen.insert(sequence.keys).inserted else {
                throw ComposeGenerationError.duplicateSequence(sequence.keys.map(\.symbol))
            }
        }

        for sequence in sequences {
            for other in sequences where sequence.keys.count < other.keys.count && other.keys.starts(with: sequence.keys) {
                throw ComposeGenerationError.ambiguousSequencePrefix(
                    sequence.keys.map(\.symbol),
                    other.keys.map(\.symbol)
                )
            }
        }
    }

    private static func composeKeyManipulator(_ profile: ComposeProfile) -> Manipulator {
        Manipulator(
            description: "Tap \(profile.composeKey.keyCode) to enter compose mode; hold it to use it normally",
            from: KarabinerEvent(keyCode: profile.composeKey.keyCode, modifiers: .init(mandatory: nil, optional: ["any"])),
            to: [.keyCode(profile.composeKey.keyCode, lazy: true)],
            toIfAlone: [.setVariable(profile.stateName, .string("start"))],
            toIfHeldDown: [.keyCode(profile.composeKey.keyCode)],
            parameters: [
                "basic.to_if_alone_timeout_milliseconds": 300,
                "basic.to_if_held_down_threshold_milliseconds": 300
            ]
        )
    }

    private static func pasteText(_ text: String, stateName: String) -> [ToEvent] {
        [
            .shellCommand("/usr/bin/printf '\(shellQuoteSingle(text))' | LANG=en_US.UTF-8 /usr/bin/pbcopy", holdDownMilliseconds: 200),
            .keyCode("v", modifiers: ["left_command"]),
            .setVariable(stateName, .int(0))
        ]
    }

    private static func variants(for sequence: ComposeSequence) -> [ComposeSequence] {
        guard sequence.ordering == .unordered, sequence.keys.count == 2, sequence.keys[0] != sequence.keys[1] else {
            return [sequence]
        }
        return [
            sequence,
            ComposeSequence(
                [sequence.keys[1], sequence.keys[0]],
                inserts: sequence.output,
                note: sequence.note,
                ordering: sequence.ordering
            )
        ]
    }

    private static func shellQuoteSingle(_ text: String) -> String {
        text.replacingOccurrences(of: "'", with: "'\\\\''")
    }
}

public enum ComposeGenerationError: Error, CustomStringConvertible {
    case duplicateSequence([String])
    case ambiguousSequencePrefix([String], [String])
    case unsupportedSequenceLength([String])

    public var description: String {
        switch self {
            case let .duplicateSequence(keys):
                "Duplicate compose sequence: \(keys.joined(separator: " "))"
            case let .ambiguousSequencePrefix(prefix, sequence):
                "Ambiguous compose sequence prefix: \(prefix.joined(separator: " ")) is also a prefix of \(sequence.joined(separator: " "))"
            case let .unsupportedSequenceLength(keys):
                "Compose sequences must contain at least two keys: \(keys.joined(separator: " "))"
        }
    }
}

private extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var seen: Set<Element> = []
        return filter { seen.insert($0).inserted }
    }
}

private struct KarabinerDocument: Encodable {
    var title: String
    var rules: [Rule]
}

private struct Rule: Encodable {
    var description: String
    var manipulators: [Manipulator]
}

private struct Manipulator: Encodable {
    var type = "basic"
    var description: String
    var from: KarabinerEvent
    var to: [ToEvent]?
    var toIfAlone: [ToEvent]?
    var toIfHeldDown: [ToEvent]?
    var conditions: [Condition]?
    var parameters: [String: Int]?

    enum CodingKeys: String, CodingKey {
        case type
        case description
        case from
        case to
        case toIfAlone = "to_if_alone"
        case toIfHeldDown = "to_if_held_down"
        case conditions
        case parameters
    }

    init(
        description: String,
        from: KarabinerEvent,
        to: [ToEvent]? = nil,
        toIfAlone: [ToEvent]? = nil,
        toIfHeldDown: [ToEvent]? = nil,
        conditions: [Condition]? = nil,
        parameters: [String: Int]? = nil
    ) {
        self.description = description
        self.from = from
        self.to = to
        self.toIfAlone = toIfAlone
        self.toIfHeldDown = toIfHeldDown
        self.conditions = conditions
        self.parameters = parameters
    }
}

private enum ToEvent: Encodable {
    case keyCode(String, modifiers: [String]? = nil, lazy: Bool? = nil)
    case shellCommand(String, holdDownMilliseconds: Int? = nil)
    case setVariable(String, VariableValue)

    enum CodingKeys: String, CodingKey {
        case keyCode = "key_code"
        case modifiers
        case lazy
        case shellCommand = "shell_command"
        case holdDownMilliseconds = "hold_down_milliseconds"
        case setVariable = "set_variable"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case let .keyCode(keyCode, modifiers, lazy):
                try container.encode(keyCode, forKey: .keyCode)
                try container.encodeIfPresent(modifiers, forKey: .modifiers)
                try container.encodeIfPresent(lazy, forKey: .lazy)
            case let .shellCommand(command, holdDownMilliseconds):
                try container.encode(command, forKey: .shellCommand)
                try container.encodeIfPresent(holdDownMilliseconds, forKey: .holdDownMilliseconds)
            case let .setVariable(name, value):
                try container.encode(SetVariable(name: name, value: value), forKey: .setVariable)
        }
    }

    private struct SetVariable: Encodable {
        var name: String
        var value: VariableValue
    }
}

private enum Condition: Encodable {
    case variableIf(String, VariableValue)
    case variableUnless(String, VariableValue)

    enum CodingKeys: String, CodingKey {
        case type
        case name
        case value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case let .variableIf(name, value):
                try container.encode("variable_if", forKey: .type)
                try container.encode(name, forKey: .name)
                try container.encode(value, forKey: .value)
            case let .variableUnless(name, value):
                try container.encode("variable_unless", forKey: .type)
                try container.encode(name, forKey: .name)
                try container.encode(value, forKey: .value)
        }
    }
}

private enum VariableValue: Encodable, Hashable {
    case int(Int)
    case string(String)

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case let .int(value):
                try container.encode(value)
            case let .string(value):
                try container.encode(value)
        }
    }
}
