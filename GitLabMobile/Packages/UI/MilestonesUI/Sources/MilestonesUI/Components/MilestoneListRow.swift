import SwiftUI
import ProjectsKit

public struct MilestoneListRow: View {
    let milestone: Milestone
    let style: MilestoneListStyle

    public init(milestone: Milestone, style: MilestoneListStyle = .default) {
        self.milestone = milestone
        self.style = style
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: style.spacing) {
                // Milestone status indicator
                Circle()
                    .fill(milestone.status.color)
                    .frame(width: 8, height: 8)

                VStack(alignment: .leading, spacing: 2) {
                    Text(milestone.title)
                        .font(style.titleFont)
                        .foregroundColor(style.titleColor)
                        .lineLimit(style.titleLineLimit)

                    if style.showMetadata {
                        HStack(spacing: 8) {
                            Text(milestone.status.displayName)
                                .font(.caption)
                                .foregroundColor(milestone.status.color)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(milestone.status.color.opacity(0.1))
                                )
                        }
                    }
                }

                Spacer()

                if style.showProgress {
                    MilestoneProgressView(milestone: milestone, style: style)
                }

                if style.showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if style.showDates && (milestone.startDate != nil || milestone.dueDate != nil) {
                HStack(spacing: 12) {
                    if let startDate = milestone.startDate {
                        Text("Started \(startDate.formatted(.dateTime.month().day()))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    if let dueDate = milestone.dueDate {
                        Text("Due \(dueDate.formatted(.dateTime.month().day()))")
                            .font(.caption2)
                            .foregroundColor(dueDate < Date() ? .red : .secondary)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

// MARK: - Supporting Components
public struct MilestoneProgressView: View {
    let milestone: Milestone
    let style: MilestoneListStyle

    public var body: some View {
        VStack(spacing: 2) {
            if style.showProgressText {
                Text("\(milestone.completedIssues)/\(milestone.totalIssues)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)

                    Rectangle()
                        .fill(milestone.status.color)
                        .frame(width: geometry.size.width * milestone.progress, height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
        }
        .frame(width: 60)
    }
}

// MARK: - Supporting Types
public enum MilestoneListStyle {
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

    var showProgress: Bool {
        switch self {
        case .compact: return false
        case .detailed: return true
        case .minimal: return false
        }
    }

    var showProgressText: Bool {
        switch self {
        case .compact: return false
        case .detailed: return true
        case .minimal: return false
        }
    }

    var showDates: Bool {
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
private extension MilestoneStatus {
    var color: Color {
        switch self {
        case .active: return .blue
        case .closed: return .green
        }
    }

    var displayName: String {
        switch self {
        case .active: return "Active"
        case .closed: return "Closed"
        }
    }
}

private extension Milestone {
    var progress: Double {
        guard totalIssues > 0 else { return 0 }
        return Double(completedIssues) / Double(totalIssues)
    }
}

// Note: This assumes you'll add Milestone, MilestoneStatus models to ProjectsKit
// The UI package depends on the domain models but provides its own styling and layout

