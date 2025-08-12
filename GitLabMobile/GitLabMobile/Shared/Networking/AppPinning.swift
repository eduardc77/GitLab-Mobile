import Foundation

/// Loads SPKI pin hashes from Info.plist top-level key `GitLabSPKIPins` (Array<String>).
/// Each entry can be either the raw Base64 hash or prefixed with `sha256//`.
public enum AppPinning {
    public static func loadPinsFromInfoPlist() -> Set<String> {
        guard let pins = Bundle.main.object(forInfoDictionaryKey: "GitLabSPKIPins") as? [String] else {
            return []
        }
        return Set(pins)
    }
}

// trailing newline intentional
