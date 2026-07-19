import Foundation

public enum DefaultProfile {
    public static let profile = ComposeProfile(
        title: "Right Command Compose",
        description: "Right Command compose with common Latin and IPA characters"
    ) {
        sequence("a", "e", inserts: "æ")
        sequence("o", "e", inserts: "œ")
        sequence("u", "h", inserts: .unicodeName("LATIN SMALL LETTER UPSILON"))

        accent("-", bases: "aeiou", outputs: "āēīōū")
        accent("^", bases: "aeiou", outputs: "âêîôû")
        accent("`", bases: "aeiou", outputs: "àèìòù")
        accent("'", bases: "aeiou", outputs: "áéíóú")
        accent("\"", bases: "aeiou", outputs: "äëïöü")
        accent(".", bases: "aeiou", outputs: "ạẹịọụ")

        sequence(",", "c", inserts: "ç")
        sequence(",", "s", inserts: "ş")
        sequence(",", "t", inserts: "ţ")
        sequence(";", "s", inserts: "ș")
        sequence(";", "t", inserts: "ț")

        sequence("e", "e", inserts: .unicodeName("LATIN SMALL LETTER SCHWA"))
        sequence("/", "i", inserts: .unicodeName("LATIN SMALL LETTER I WITH STROKE"))
        sequence("/", "o", inserts: "ø")

        sequence("l", "a", inserts: .unicodeName("LATIN SMALL LETTER ALPHA"))
        sequence("l", "e", inserts: .unicodeName("LATIN SMALL LETTER OPEN E"))
        sequence("l", "f", inserts: .unicodeName("LATIN SMALL LETTER PHI"))
        sequence("l", "g", inserts: .unicodeName("LATIN SMALL LETTER SCRIPT G"))
        sequence("l", "i", inserts: .unicodeName("LATIN SMALL LETTER IOTA"))
        sequence("l", "j", inserts: .unicodeName("LATIN SMALL LETTER GAMMA"))
        sequence("l", "m", inserts: .unicodeName("LATIN SMALL LETTER TURNED M WITH LONG LEG"))
        sequence("l", "o", inserts: .unicodeName("LATIN SMALL LETTER OPEN O"))
        sequence("l", "s", inserts: .unicodeName("LATIN SMALL LETTER ESH"))
        sequence("l", "u", inserts: .unicodeName("LATIN SMALL LETTER UPSILON"))
        sequence("l", "?", inserts: .unicodeName("LATIN LETTER GLOTTAL STOP"))

        sequence("r", "a", inserts: .unicodeName("LATIN SMALL LETTER TURNED A"))
        sequence("r", "b", inserts: .unicodeName("LATIN SMALL LETTER REVERSED OPEN E"))
        sequence("r", "c", inserts: .unicodeName("LATIN SMALL LETTER CLOSED REVERSED OPEN E"))
        sequence("r", "e", inserts: .unicodeName("LATIN SMALL LETTER TURNED E"))
        sequence("r", "h", inserts: .unicodeName("LATIN SMALL LETTER TURNED H"))
        sequence("r", "m", inserts: .unicodeName("LATIN SMALL LETTER TURNED M"))
        sequence("r", "o", inserts: .unicodeName("LATIN SMALL LETTER RAMS HORN"))
        sequence("r", "q", inserts: .unicodeName("LATIN SMALL LETTER TURNED ALPHA"))
        sequence("r", "r", inserts: .unicodeName("LATIN SMALL LETTER TURNED R"))
        sequence("r", "v", inserts: .unicodeName("LATIN SMALL LETTER TURNED V"))
        sequence("r", "w", inserts: .unicodeName("LATIN SMALL LETTER TURNED W"))
        sequence("r", "y", inserts: .unicodeName("LATIN SMALL LETTER TURNED Y"))
        sequence("r", "d", inserts: .unicodeName("LATIN SMALL LETTER R WITH FISHHOOK"))

        sequence("f", "t", inserts: .unicodeName("LATIN SMALL LETTER T WITH RETROFLEX HOOK"))
        sequence("f", "v", inserts: .unicodeName("LATIN SMALL LETTER V WITH RIGHT HOOK"))
        sequence("f", "z", inserts: .unicodeName("LATIN SMALL LETTER Z WITH RETROFLEX HOOK"))

        sequence("n", "g", inserts: .unicodeName("LATIN SMALL LETTER ENG"))
        sequence("t", "h", inserts: .unicodeName("GREEK SMALL LETTER THETA"))
        sequence("d", "h", inserts: .unicodeName("LATIN SMALL LETTER ETH"))
        sequence("z", "h", inserts: .unicodeName("LATIN SMALL LETTER EZH"))
        sequence("c", "h", inserts: .unicodeName("LATIN SMALL LETTER C WITH CEDILLA"))
        sequence("j", "h", inserts: .unicodeName("LATIN SMALL LETTER J WITH CROSSED-TAIL"))

        sequence("d", ",", inserts: .unicodeName("LATIN SMALL LETTER D WITH TAIL"))
        sequence("l", ",", inserts: .unicodeName("LATIN SMALL LETTER L WITH RETROFLEX HOOK"))
        sequence("n", ",", inserts: .unicodeName("LATIN SMALL LETTER N WITH RETROFLEX HOOK"))
        sequence("s", ",", inserts: .unicodeName("LATIN SMALL LETTER S WITH HOOK"))
        sequence("z", ",", inserts: .unicodeName("LATIN SMALL LETTER Z WITH RETROFLEX HOOK"))

        sequence("g", "h", inserts: .unicodeName("LATIN SMALL LETTER GAMMA"))
        sequence("h", "'", inserts: .unicodeName("LATIN SMALL LETTER H WITH HOOK"))
        sequence("b", "'", inserts: .unicodeName("LATIN SMALL LETTER B WITH HOOK"))
        sequence("d", "'", inserts: .unicodeName("LATIN SMALL LETTER D WITH HOOK"))
        sequence("g", "'", inserts: .unicodeName("LATIN SMALL LETTER G WITH HOOK"))

        sequence(":", "+", inserts: .unicodeName("MODIFIER LETTER TRIANGULAR COLON"))
        sequence("|", "'", inserts: .unicodeName("MODIFIER LETTER VERTICAL LINE"))
        sequence("|", ",", inserts: .unicodeName("MODIFIER LETTER LOW VERTICAL LINE"))
    }
}