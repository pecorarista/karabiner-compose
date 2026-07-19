import Foundation

public enum DefaultProfile {
    public static let profile = try! makeProfile()

    public static func makeProfile() throws -> ComposeProfile {
        let sequences = try ComposeSequenceTSV.loadResource(named: "default-compose-sequences")
        return ComposeProfile(
            title: "Right Command Compose",
            description: "Right Command compose with common Latin and IPA characters"
        ) {
            sequences
        }
    }
}
