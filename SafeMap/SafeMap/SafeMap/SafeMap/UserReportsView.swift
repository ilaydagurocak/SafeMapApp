import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct UserReportsView: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var lm: LocalizationManager

    @State private var reports: [UserReport] = []
    @State private var isLoading = true

    @State private var showDeleteDialog = false
    @State private var selectedReport: UserReport?

    private let db = Firestore.firestore()

    var body: some View {
        ZStack {

            // BACKGROUND
            LinearGradient(
                colors: [
                    Color(red: 0.78, green: 0.90, blue: 1.0),
                    Color(red: 0.35, green: 0.65, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    // HEADER
                    ZStack {
                        Text(lm.text("my_reports_title"))
                            .font(.headline)
                            .foregroundColor(.white)

                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // ICON
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 90))
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    // CONTENT
                    if isLoading {

                        Text(lm.text("loading"))
                            .foregroundColor(.white)
                            .padding(.top, 20)

                    } else if reports.isEmpty {

                        // EMPTY STATE
                        SettingsCard {
                            VStack(spacing: 12) {
                                Text(lm.text("my_reports_empty_title"))
                                    .font(.headline)

                                Text(lm.text("my_reports_empty_description"))
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 20)
                        }
                        .padding(.horizontal)

                    } else {

                        // REPORT LIST
                        VStack(spacing: 14) {
                            ForEach(reports) { report in
                                SettingsCard {
                                    HStack(alignment: .center, spacing: 12) {

                                        // LEFT: CONTENT
                                        VStack(alignment: .leading, spacing: 10) {

                                            Text(scoreText(report.safety))
                                                .font(.caption.bold())
                                                .foregroundColor(scoreColor(report.safety))
                                                .padding(.vertical, 4)
                                                .padding(.horizontal, 10)
                                                .background(
                                                    scoreColor(report.safety)
                                                        .opacity(0.15)
                                                )
                                                .cornerRadius(8)

                                            Text(report.comment)
                                                .font(.body)
                                                .foregroundColor(.black)

                                            Text(
                                                report.createdAt.formatted(
                                                    date: .abbreviated,
                                                    time: .shortened
                                                )
                                            )
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                        }

                                        Spacer()

                                        // RIGHT: DELETE (CENTERED)
                                        Button {
                                            selectedReport = report
                                            showDeleteDialog = true
                                        } label: {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                                .padding(10)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            fetchReports()
        }

        // DELETE CONFIRMATION
        .confirmationDialog(
            lm.text("delete_report_title"),
            isPresented: $showDeleteDialog,
            titleVisibility: .visible
        ) {
            Button(lm.text("delete_confirm"), role: .destructive) {
                if let report = selectedReport {
                    deleteReport(report)
                }
            }
            Button(lm.text("cancel"), role: .cancel) {}
        } message: {
            Text(lm.text("delete_report_message"))
        }
    }

    // MARK: - FIREBASE

    private func fetchReports() {
        guard let uid = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }

        db.collection("reports")
            .whereField("userId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .getDocuments { snap, _ in
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.reports = snap?.documents.compactMap {
                        UserReport(from: $0)
                    } ?? []
                }
            }
    }

    private func deleteReport(_ report: UserReport) {
        db.collection("reports")
            .document(report.id)
            .delete { _ in
                fetchReports()
            }
    }

    // MARK: - HELPERS

    private func scoreText(_ safety: Int) -> String {
        switch safety {
        case 0: return lm.text("unsafe")
        case 1: return lm.text("medium_safe")
        default: return lm.text("safe")
        }
    }

    private func scoreColor(_ safety: Int) -> Color {
        switch safety {
        case 0: return .red
        case 1: return .orange
        default: return .green
        }
    }
}

//
// MARK: - MODEL
//
struct UserReport: Identifiable {

    let id: String
    let comment: String
    let safety: Int
    let createdAt: Date

    init?(from doc: QueryDocumentSnapshot) {
        let data = doc.data()

        guard
            let comment = data["comment"] as? String,
            let safety = data["safety"] as? Int,
            let ts = data["createdAt"] as? Timestamp
        else {
            return nil
        }

        self.id = doc.documentID
        self.comment = comment
        self.safety = safety
        self.createdAt = ts.dateValue()
    }
}

