import Foundation
import MapKit
import SwiftUI

final class MapSearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {

    // 🔍 Autocomplete results
    @Published var suggestions: [MKLocalSearchCompletion] = []

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }

    // MARK: - UPDATE QUERY (typing)
    func updateQuery(_ query: String, region: MKCoordinateRegion) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            suggestions = []
            return
        }

        completer.region = region
        completer.queryFragment = trimmed
    }

    // MARK: - COMPLETER DELEGATE

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // En fazla 8 öneri
        suggestions = Array(completer.results.prefix(8))
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        suggestions = []
    }

    // MARK: - SEARCH BY AUTOCOMPLETE SELECTION

    func search(
        completion: MKLocalSearchCompletion,
        region: MKCoordinateRegion
    ) async throws -> MKMapItem {

        let request = MKLocalSearch.Request(completion: completion)
        request.region = region

        let search = MKLocalSearch(request: request)

        return try await withCheckedThrowingContinuation { cont in
            search.start { response, error in
                if let item = response?.mapItems.first {
                    cont.resume(returning: item)
                } else {
                    cont.resume(
                        throwing: error ?? NSError(
                            domain: "MapSearch",
                            code: -1,
                            userInfo: nil
                        )
                    )
                }
            }
        }
    }

    // MARK: - SEARCH BY TEXT (Enter key)

    func search(
        text: String,
        region: MKCoordinateRegion
    ) async throws -> MKMapItem {

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        request.region = region

        let search = MKLocalSearch(request: request)

        return try await withCheckedThrowingContinuation { cont in
            search.start { response, error in
                if let item = response?.mapItems.first {
                    cont.resume(returning: item)
                } else {
                    cont.resume(
                        throwing: error ?? NSError(
                            domain: "MapSearch",
                            code: -2,
                            userInfo: nil
                        )
                    )
                }
            }
        }
    }
}

