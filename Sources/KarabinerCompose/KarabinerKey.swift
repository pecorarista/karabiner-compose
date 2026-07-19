import Foundation

public struct KarabinerKey: Hashable, Sendable, ExpressibleByStringLiteral {
    public var symbol: String
    public var keyCode: String
    public var mandatoryModifiers: [String]

    public init(symbol: String, keyCode: String, mandatoryModifiers: [String] = []) {
        self.symbol = symbol
        self.keyCode = keyCode
        self.mandatoryModifiers = mandatoryModifiers
    }

    public init(stringLiteral value: String) {
        self = .symbol(value)
    }

    public static func plain(_ keyCode: String, symbol: String? = nil) -> KarabinerKey {
        KarabinerKey(symbol: symbol ?? keyCode, keyCode: keyCode)
    }

    public static func modified(_ symbol: String, keyCode: String, mandatoryModifiers: [String]) -> KarabinerKey {
        KarabinerKey(symbol: symbol, keyCode: keyCode, mandatoryModifiers: mandatoryModifiers)
    }

    public static func symbol(_ symbol: String) -> KarabinerKey {
        guard let key = symbolMap[symbol] else {
            fatalError("Unsupported compose key symbol: \(symbol)")
        }
        return key
    }

    public var event: KarabinerEvent {
        KarabinerEvent(
            keyCode: keyCode,
            modifiers: .init(
                mandatory: mandatoryModifiers.isEmpty ? nil : mandatoryModifiers,
                optional: ["caps_lock"]
            )
        )
    }

    private static let symbolMap: [String: KarabinerKey] = {
        var map: [String: KarabinerKey] = [:]
        for letter in "abcdefghijklmnopqrstuvwxyz" {
            let symbol = String(letter)
            map[symbol] = .plain(symbol)
        }
        for digit in "0123456789" {
            let symbol = String(digit)
            map[symbol] = .plain(symbol)
        }
        map["-"] = .plain("hyphen", symbol: "-")
        map["="] = .plain("equal_sign", symbol: "=")
        map["["] = .plain("open_bracket", symbol: "[")
        map["]"] = .plain("close_bracket", symbol: "]")
        map["\\"] = .plain("backslash", symbol: "\\")
        map[";"] = .plain("semicolon", symbol: ";")
        map["'"] = .plain("quote", symbol: "'")
        map["`"] = .plain("grave_accent_and_tilde", symbol: "`")
        map[","] = .plain("comma", symbol: ",")
        map["."] = .plain("period", symbol: ".")
        map["/"] = .plain("slash", symbol: "/")
        map["^"] = .modified("^", keyCode: "6", mandatoryModifiers: ["left_shift"])
        map["\""] = .modified("\"", keyCode: "quote", mandatoryModifiers: ["left_shift"])
        map["?"] = .modified("?", keyCode: "slash", mandatoryModifiers: ["left_shift"])
        map[":"] = .modified(":", keyCode: "semicolon", mandatoryModifiers: ["left_shift"])
        map["+"] = .modified("+", keyCode: "equal_sign", mandatoryModifiers: ["left_shift"])
        map["|"] = .modified("|", keyCode: "backslash", mandatoryModifiers: ["left_shift"])
        return map
    }()
}

public struct KarabinerEvent: Encodable, Hashable, Sendable {
    public var keyCode: String
    public var modifiers: Modifiers?

    enum CodingKeys: String, CodingKey {
        case keyCode = "key_code"
        case modifiers
    }

    public init(keyCode: String, modifiers: Modifiers? = nil) {
        self.keyCode = keyCode
        self.modifiers = modifiers
    }

    public struct Modifiers: Encodable, Hashable, Sendable {
        public var mandatory: [String]?
        public var optional: [String]?
    }
}