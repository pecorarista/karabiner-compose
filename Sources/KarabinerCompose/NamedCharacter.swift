enum NamedCharacter {
    static let latinCapitalLetterTurnedE = "\u{018E}"
    static let latinSmallLetterScriptG = "\u{0261}"
    static let latinSmallLetterTurnedE = "\u{01DD}"

    static func resolve(_ name: String) -> String? {
        switch name {
            case "":
                return nil
            case "latinCapitalLetterTurnedE":
                return latinCapitalLetterTurnedE
            case "latinSmallLetterScriptG":
                return latinSmallLetterScriptG
            case "latinSmallLetterTurnedE":
                return latinSmallLetterTurnedE
            default:
                return nil
        }
    }
}
