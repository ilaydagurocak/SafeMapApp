import Foundation
import FirebaseAuth
import FirebaseFirestore
import MapKit
import SwiftUI

struct Report: Identifiable {
    let id: String
    let userId: String
    let comment: String
    let safety: Int           // 2 safe, 1 medium, 0 unsafe
    let coordinate: CLLocationCoordinate2D
    let createdAt: Date
}

struct ReportCluster: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let reports: [Report]
    let averageSafety: Double

    var color: Color {
        // avg 0..2
        if averageSafety >= 1.5 { return .green }
        if averageSafety >= 0.75 { return .yellow }
        return .red
    }

    var scoreText: String {
        // 0.0 - 2.0
        String(format: "%.1f", averageSafety)
    }
}

final class ReportsViewModel: ObservableObject {

    @Published var clusters: [ReportCluster] = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // cluster radius in meters (yakın raporlar tek pine toplansın)
    private let clusterRadiusMeters: CLLocationDistance = 120

    deinit {
        listener?.remove()
    }

    func startListening() {
        listener?.remove()

        listener = db.collection("reports")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snap, error in
                guard let self else { return }
                guard let docs = snap?.documents else { return }

                let reports: [Report] = docs.compactMap { d in
                    let data = d.data()
                    let userId = data["userId"] as? String ?? ""
                    let comment = data["comment"] as? String ?? ""
                    let safety = data["safety"] as? Int ?? 1

                    guard let geo = data["coordinate"] as? GeoPoint else { return nil }
                    let ts = data["createdAt"] as? Timestamp
                    let createdAt = ts?.dateValue() ?? Date()

                    return Report(
                        id: d.documentID,
                        userId: userId,
                        comment: comment,
                        safety: safety,
                        coordinate: CLLocationCoordinate2D(latitude: geo.latitude, longitude: geo.longitude),
                        createdAt: createdAt
                    )
                }

                self.clusters = self.makeClusters(from: reports)
            }
    }

    func addReport(safety: Int, comment: String, coordinate: CLLocationCoordinate2D) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let data: [String: Any] = [
            "userId": uid,
            "comment": comment,
            "safety": safety,
            "coordinate": GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude),
            "createdAt": Timestamp(date: Date())
        ]

        db.collection("reports").addDocument(data: data)
    }

    // MARK: - Clustering

    private func makeClusters(from reports: [Report]) -> [ReportCluster] {
        var clusters: [[Report]] = []

        for report in reports {
            var placed = false

            for i in clusters.indices {
                if let first = clusters[i].first {
                    let dist = distanceMeters(a: first.coordinate, b: report.coordinate)
                    if dist <= clusterRadiusMeters {
                        clusters[i].append(report)
                        placed = true
                        break
                    }
                }
            }

            if !placed {
                clusters.append([report])
            }
        }

        return clusters.enumerated().map { idx, group in
            let avg = group.map { Double($0.safety) }.reduce(0, +) / Double(max(group.count, 1))

            // cluster coordinate = group average coordinate
            let lat = group.map { $0.coordinate.latitude }.reduce(0, +) / Double(group.count)
            let lng = group.map { $0.coordinate.longitude }.reduce(0, +) / Double(group.count)

            return ReportCluster(
                id: "cluster_\(idx)",
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                reports: group.sorted(by: { $0.createdAt > $1.createdAt }),
                averageSafety: avg
            )
        }
    }

    private func distanceMeters(a: CLLocationCoordinate2D, b: CLLocationCoordinate2D) -> CLLocationDistance {
        let la = CLLocation(latitude: a.latitude, longitude: a.longitude)
        let lb = CLLocation(latitude: b.latitude, longitude: b.longitude)
        return la.distance(from: lb)
    }
}

