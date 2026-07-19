import Foundation

public enum UnicodeNameCatalog {
    private static let names: [String: String] = [
        "GREEK SMALL LETTER THETA": "θ",
        "LATIN LETTER GLOTTAL STOP": "ʔ",
        "LATIN SMALL LETTER ALPHA": "ɑ",
        "LATIN SMALL LETTER B WITH HOOK": "ɓ",
        "LATIN SMALL LETTER C WITH CEDILLA": "ç",
        "LATIN SMALL LETTER CLOSED REVERSED OPEN E": "ɞ",
        "LATIN SMALL LETTER D WITH HOOK": "ɗ",
        "LATIN SMALL LETTER D WITH TAIL": "ɖ",
        "LATIN SMALL LETTER ENG": "ŋ",
        "LATIN SMALL LETTER ESH": "ʃ",
        "LATIN SMALL LETTER ETH": "ð",
        "LATIN SMALL LETTER EZH": "ʒ",
        "LATIN SMALL LETTER G WITH HOOK": "ɠ",
        "LATIN SMALL LETTER GAMMA": "ɣ",
        "LATIN SMALL LETTER H WITH HOOK": "ɦ",
        "LATIN SMALL LETTER I WITH STROKE": "ɨ",
        "LATIN SMALL LETTER IOTA": "ɩ",
        "LATIN SMALL LETTER J WITH CROSSED-TAIL": "ʝ",
        "LATIN SMALL LETTER L WITH RETROFLEX HOOK": "ɭ",
        "LATIN SMALL LETTER N WITH RETROFLEX HOOK": "ɳ",
        "LATIN SMALL LETTER OPEN E": "ɛ",
        "LATIN SMALL LETTER OPEN O": "ɔ",
        "LATIN SMALL LETTER PHI": "ɸ",
        "LATIN SMALL LETTER R WITH FISHHOOK": "ɾ",
        "LATIN SMALL LETTER RAMS HORN": "ɤ",
        "LATIN SMALL LETTER REVERSED OPEN E": "ɜ",
        "LATIN SMALL LETTER SCHWA": "ə",
        "LATIN SMALL LETTER SCRIPT G": "ɡ",
        "LATIN SMALL LETTER S WITH HOOK": "ʂ",
        "LATIN SMALL LETTER T WITH RETROFLEX HOOK": "ʈ",
        "LATIN SMALL LETTER TURNED A": "ɐ",
        "LATIN SMALL LETTER TURNED ALPHA": "ɒ",
        "LATIN SMALL LETTER TURNED E": "ǝ",
        "LATIN SMALL LETTER TURNED H": "ɥ",
        "LATIN SMALL LETTER TURNED M": "ɯ",
        "LATIN SMALL LETTER TURNED M WITH LONG LEG": "ɰ",
        "LATIN SMALL LETTER TURNED R": "ɹ",
        "LATIN SMALL LETTER TURNED V": "ʌ",
        "LATIN SMALL LETTER TURNED W": "ʍ",
        "LATIN SMALL LETTER TURNED Y": "ʎ",
        "LATIN SMALL LETTER UPSILON": "ʊ",
        "LATIN SMALL LETTER V WITH RIGHT HOOK": "ⱱ",
        "LATIN SMALL LETTER Z WITH RETROFLEX HOOK": "ʐ",
        "MODIFIER LETTER LOW VERTICAL LINE": "ˌ",
        "MODIFIER LETTER TRIANGULAR COLON": "ː",
        "MODIFIER LETTER VERTICAL LINE": "ˈ"
    ]

    public static func character(named name: String) -> String {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard let character = names[normalizedName] else {
            fatalError("Unknown Unicode name: \(name)")
        }
        return character
    }
}
