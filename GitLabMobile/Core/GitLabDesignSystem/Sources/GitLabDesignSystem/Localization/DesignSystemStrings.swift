import Foundation

// Shared, reusable localized strings for UI elements across modules
public extension LocalizedStringResource {
    enum DesignSystem {
        public static let updated = LocalizedStringResource(
            "ds.updated",
            table: "DesignSystem",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        public static let loadingMore = LocalizedStringResource(
            "ds.loading_more",
            table: "DesignSystem",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }
}
