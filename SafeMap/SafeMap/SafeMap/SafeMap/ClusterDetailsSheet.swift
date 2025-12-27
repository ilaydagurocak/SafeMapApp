import SwiftUI
import MapKit

struct ClusterDetailsSheet: View {
    let lm: LocalizationManager
    let cluster: ReportCluster
    let onDirections: () -> Void

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {

                HStack(spacing: 10) {
                    Circle()
                        .fill(cluster.color)
                        .frame(width: 14, height: 14)

                    Text("\(lm.text("cluster_average")): \(cluster.scoreText)")
                        .font(.headline)

                    Spacer()

                    Button {
                        onDirections()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "car.fill")
                            Text(lm.text("cluster_directions"))
                        }
                        .font(.subheadline.bold())
                    }
                }
                .padding(.top, 10)

                Divider()

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(cluster.reports) { r in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(safetyLabel(lm: lm, value: r.safety))
                                        .font(.caption.bold())
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(safetyColor(value: r.safety).opacity(0.15))
                                        .foregroundColor(safetyColor(value: r.safety))
                                        .cornerRadius(10)

                                    Spacer()

                                    Text(r.createdAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Text(r.comment)
                                    .foregroundColor(.primary)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(14)
                        }
                    }
                    .padding(.vertical, 10)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .navigationTitle(lm.text("cluster_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(lm.text("done")) { dismiss() }
                }
            }
        }
    }

    private func safetyLabel(lm: LocalizationManager, value: Int) -> String {
        switch value {
        case 2: return lm.text("report_safe")
        case 1: return lm.text("report_medium")
        default: return lm.text("report_unsafe")
        }
    }

    private func safetyColor(value: Int) -> Color {
        switch value {
        case 2: return .green
        case 1: return .yellow
        default: return .red
        }
    }
}

