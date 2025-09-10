import SwiftUI
import ProjectsKit

public struct MergeRequestListRow: View {
    let mergeRequest: MergeRequest
    let style: MergeRequestListStyle

    public init(mergeRequest: MergeRequest, style: MergeRequestListStyle = .default) {
        self.mergeRequest = mergeRequest
        self.style = style
    }

    public var body: some View {
        HStack(spacing: style.spacing) {
            // MR status indicator
            Circle()
                .fill(mergeRequest.status.color)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(mergeRequest.title)
                    .font(style.titleFont)
                    .foregroundColor(style.titleColor)
                    .lineLimit(style.titleLineLimit)

                if style.showMetadata {
                    HStack(spacing: 12) {
                        Text("!\(mergeRequest.number)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(mergeRequest.status.displayName)
                            .font(.caption)
                            .foregroundColor(mergeRequest.status.color)

                        if let author = mergeRequest.author {
                            Text("@\(author.username)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                if style.showBranchInfo {
                    Text("\(mergeRequest.sourceBranch) → \(mergeRequest.targetBranch)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if let pipelineStatus = mergeRequest.pipelineStatus {
                PipelineStatusView(status: pipelineStatus)
            }

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

// MARK: - Supporting Components
public struct PipelineStatusView: View {
    let status: PipelineStatus

    public var body: some View {
        Image(systemName: status.iconName)
            .foregroundColor(status.color)
            .font(.caption)
    }
}

// MARK: - Supporting Types
public enum MergeRequestListStyle {
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

    var showBranchInfo: Bool {
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
private extension MergeRequestStatus {
    var color: Color {
        switch self {
        case .open: return .green
        case .merged: return .purple
        case .closed: return .red
        }
    }

    var displayName: String {
        switch self {
        case .open: return "Open"
        case .merged: return "Merged"
        case .closed: return "Closed"
        }
    }
}

private extension PipelineStatus {
    var color: Color {
        switch self {
        case .success: return .green
        case .failed: return .red
        case .running: return .blue
        case .pending: return .orange
        }
    }

    var iconName: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .running: return "arrow.triangle.2.circlepath"
        case .pending: return "clock"
        }
    }
}

// Note: This assumes you'll add MergeRequest, MergeRequestStatus, PipelineStatus models to ProjectsKit
// The UI package depends on the domain models but provides its own styling and layout

