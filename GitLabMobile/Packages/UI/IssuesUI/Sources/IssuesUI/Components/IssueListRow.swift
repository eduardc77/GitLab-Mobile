import SwiftUI
import ProjectsKit

public struct IssueListRow: View {
    let issue: Issue
    let style: IssueListStyle

    public init(issue: Issue, style: IssueListStyle = .default) {
        self.issue = issue
        self.style = style
    }

    public var body: some View {
        HStack(spacing: style.spacing) {
            // Issue status indicator
            Circle()
                .fill(issue.state.color)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(issue.title)
                    .font(style.titleFont)
                    .foregroundColor(style.titleColor)
                    .lineLimit(style.titleLineLimit)

                if style.showMetadata {
                    HStack(spacing: 12) {
                        Text("#\(issue.number)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(issue.state.displayName)
                            .font(.caption)
                            .foregroundColor(issue.state.color)

                        if let assignee = issue.assignee {
                            Text("@\(assignee.username)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Spacer()

            if style.showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

// MARK: - Supporting Types
public enum IssueListStyle {
    case compact     // For lists (Home, Profile)
    case detailed    // For project details
    case minimal     // For notifications

    var spacing: CGFloat {
        switch self {
        case .compact: return 8
        case .detailed: return 12
        case .minimal: return 4
        }
    }

    var titleFont: Font {
        switch self {
        case .compact: return .subheadline
        case .detailed: return .headline
        case .minimal: return .caption
        }
    }

    var titleColor: Color {
        .primary
    }

    var titleLineLimit: Int? {
        switch self {
        case .compact: return 2
        case .detailed: return nil
        case .minimal: return 1
        }
    }

    var showMetadata: Bool {
        switch self {
        case .compact: return false
        case .detailed: return true
        case .minimal: return false
        }
    }

    var showChevron: Bool {
        switch self {
        case .compact: return true
        case .detailed: return false
        case .minimal: return false
        }
    }
}

// MARK: - Extensions
private extension IssueState {
    var color: Color {
        switch self {
        case .open: return .green
        case .closed: return .red
        case .reopened: return .orange
        }
    }

    var displayName: String {
        switch self {
        case .open: return "Open"
        case .closed: return "Closed"
        case .reopened: return "Reopened"
        }
    }
}

// Note: This assumes you'll add Issue and IssueState models to ProjectsKit
// The UI package depends on the domain models but provides its own styling and layout

