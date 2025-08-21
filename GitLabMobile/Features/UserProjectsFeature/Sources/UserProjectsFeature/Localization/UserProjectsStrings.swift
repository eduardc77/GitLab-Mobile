import Foundation

extension LocalizedStringResource {
    enum UserProjectsL10n {
        static let title = LocalizedStringResource(
            "userprojects.title",
            table: "UserProjects",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let loading = LocalizedStringResource(
            "userprojects.loading",
            table: "UserProjects",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let recentSearches = LocalizedStringResource(
            "userprojects.recent_searches",
            table: "UserProjects",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let emptyTitle = LocalizedStringResource(
            "userprojects.empty.title",
            table: "UserProjects",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let emptyDescription = LocalizedStringResource(
            "userprojects.empty.description",
            table: "UserProjects",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let errorTitle = LocalizedStringResource(
            "userprojects.error.title",
            table: "UserProjects",
            bundle: .atURL(Bundle.module.bundleURL)
        )
        static let okButtonTitle = LocalizedStringResource(
            "userprojects.ok",
            table: "UserProjects",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }
}
