import Foundation

public enum ProjectDetailsL10n {
    public static let error: LocalizedStringResource = .init(
        "pd.error",
        table: "ProjectDetails",
        bundle: .atURL(Bundle.module.bundleURL)
    )
    public static let okButtonTitle: LocalizedStringResource = .init(
        "pd.ok",
        table: "ProjectDetails",
        bundle: .atURL(Bundle.module.bundleURL)
    )
}


