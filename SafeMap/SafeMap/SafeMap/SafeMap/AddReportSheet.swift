import SwiftUI
import MapKit

struct AddReportSheet: View {
    let lm: LocalizationManager
    let coordinate: CLLocationCoordinate2D
    let onSubmit: (_ safety: Int, _ comment: String, _ coordinate: CLLocationCoordinate2D) -> Void

    @Environment(\.dismiss) var dismiss

    @State private var comment: String = ""
    @State private var selectedSafety: Int = 2  // default safe

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {

                VStack(alignment: .leading, spacing: 8) {
                    Text(lm.text("report_title"))
                        .font(.title3.bold())

                    Text("\(lm.text("report_selected_location")): \(String(format: "%.5f", coordinate.latitude)), \(String(format: "%.5f", coordinate.longitude))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)

                VStack(alignment: .leading, spacing: 10) {
                    Text(lm.text("report_safety_question"))
                        .font(.headline)

                    Picker("", selection: $selectedSafety) {
                        Text(lm.text("report_safe")).tag(2)
                        Text(lm.text("report_medium")).tag(1)
                        Text(lm.text("report_unsafe")).tag(0)
                    }
                    .pickerStyle(.segmented)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(lm.text("report_comment_title"))
                        .font(.headline)

                    TextEditor(text: $comment)
                        .frame(height: 140)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }

                Button {
                    let trimmed = comment.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    onSubmit(selectedSafety, trimmed, coordinate)
                    dismiss()
                } label: {
                    Text(lm.text("report_submit"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(14)
                        .shadow(radius: 6)
                }
                .padding(.top, 6)

                Spacer()
            }
            .padding(.horizontal, 16)
            .navigationTitle(lm.text("report_nav_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(lm.text("cancel")) { dismiss() }
                }
            }
        }
    }
}

