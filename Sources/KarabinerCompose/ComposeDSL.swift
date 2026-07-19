import Foundation

@resultBuilder
public enum ComposeRuleBuilder {
    public static func buildBlock(_ components: [ComposeSequence]...) -> [ComposeSequence] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: ComposeSequence) -> [ComposeSequence] {
        [expression]
    }

    public static func buildExpression(_ expression: [ComposeSequence]) -> [ComposeSequence] {
        expression
    }
}

public struct ComposeProfile: Sendable {
    public var title: String
    public var description: String
    public var composeKey: KarabinerKey
    public var stateName: String
    public var sequences: [ComposeSequence]

    public init(
        title: String = "Right Command Compose",
        description: String = "Right Command compose with common Latin and IPA characters",
        composeKey: KarabinerKey = .plain("right_command"),
        stateName: String = "right_command_compose_state",
        @ComposeRuleBuilder rules: () -> [ComposeSequence]
    ) {
        self.title = title
        self.description = description
        self.composeKey = composeKey
        self.stateName = stateName
        self.sequences = rules()
    }
}

public struct ComposeSequence: Hashable, Sendable {
    public enum Ordering: Hashable, Sendable {
        case unordered
        case fixed
    }

    public var keys: [KarabinerKey]
    public var output: ComposeOutput
    public var note: String?
    public var ordering: Ordering

    public init(
        _ keys: [KarabinerKey],
        inserts output: ComposeOutput,
        note: String? = nil,
        ordering: Ordering = .unordered
    ) {
        self.keys = keys
        self.output = output
        self.note = note
        self.ordering = ordering
    }
}

public enum ComposeOutput: Hashable, Sendable, ExpressibleByStringLiteral {
    case text(String)
    case unicodeName(String)

    public init(stringLiteral value: String) {
        self = .text(value)
    }

    public var resolvedText: String {
        switch self {
            case let .text(text):
                text
            case let .unicodeName(name):
                UnicodeNameCatalog.character(named: name)
        }
    }
}

public func sequence(
    _ keys: String...,
    inserts output: ComposeOutput,
    note: String? = nil,
    ordering: ComposeSequence.Ordering = .unordered
) -> ComposeSequence {
    ComposeSequence(keys.map(KarabinerKey.symbol), inserts: output, note: note, ordering: ordering)
}
