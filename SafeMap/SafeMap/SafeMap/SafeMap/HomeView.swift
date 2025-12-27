import SwiftUI
import MapKit
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @Binding var isLoggedIn: Bool
    @EnvironmentObject var lm: LocalizationManager

    // Map region (default İstanbul)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.015, longitude: 29.000),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @State private var goSettings = false

    // Search UI
    @State private var showSearch = false
    @State private var searchText = ""

    // Autocomplete
    @StateObject private var searchVM = MapSearchViewModel()

    // Firestore reports
    @StateObject private var reportsVM = ReportsViewModel()

    // Location
    @StateObject private var locationManager = AppLocationManager()

    // Add report sheet
    @State private var showAddReport = false
    @State private var selectedCoordinateForReport: CLLocationCoordinate2D?

    // Selected cluster (pin tapped)
    @State private var selectedCluster: ReportCluster?
    @State private var showClusterSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                // MAP
                Map(coordinateRegion: $region, annotationItems: reportsVM.clusters) { cluster in
                    MapAnnotation(coordinate: cluster.coordinate) {
                        Button {
                            selectedCluster = cluster
                            showClusterSheet = true
                        } label: {
                            ClusterPinView(color: cluster.color, scoreText: cluster.scoreText)
                        }
                    }
                }
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        searchVM.suggestions = []
                    }
                    hideKeyboard()
                }

                VStack(spacing: 0) {

                    // 🔝 TOP BAR
                    HStack(spacing: 10) {

                        Text("SafeMap")
                            .font(.headline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)

                        Spacer()

                        // 📍 MY LOCATION
                        Button {
                            centerToMyLocation()
                        } label: {
                            Image(systemName: "location.fill")
                                .font(.system(size: 18))
                                .padding(10)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }

                        // 🔍 SEARCH ICON
                        Button {
                            withAnimation(.spring()) {
                                showSearch.toggle()
                            }
                            if !showSearch {
                                clearSearch()
                            }
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 18))
                                .padding(10)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }

                        // ⚙️ SETTINGS
                        Button {
                            goSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18))
                                .padding(10)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // 🔽 SEARCH AREA
                    if showSearch {
                        VStack(spacing: 10) {

                            // SEARCH BAR
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)

                                TextField(lm.text("home_search_placeholder"), text: $searchText)
                                    .submitLabel(.search)
                                    .onChange(of: searchText) { newValue in
                                        searchVM.updateQuery(newValue, region: region)
                                    }
                                    .onSubmit {
                                        Task { await searchByText(searchText) }
                                    }

                                // ❌ CLEAR / CLOSE
                                Button {
                                    if searchText.isEmpty {
                                        withAnimation { showSearch = false }
                                        hideKeyboard()
                                    } else {
                                        searchText = ""
                                        searchVM.suggestions = []
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(.ultraThinMaterial)
                            .cornerRadius(22)
                            .padding(.horizontal, 16)
                            .padding(.top, 10)

                            // 📍 AUTOCOMPLETE LIST
                            if !searchVM.suggestions.isEmpty {
                                ScrollView {
                                    VStack(spacing: 0) {
                                        ForEach(searchVM.suggestions, id: \.self) { suggestion in
                                            Button {
                                                Task { await selectSuggestion(suggestion) }
                                            } label: {
                                                HStack(spacing: 12) {
                                                    Image(systemName: "magnifyingglass")
                                                        .foregroundColor(.blue)

                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(suggestion.title)
                                                            .foregroundColor(.primary)
                                                            .lineLimit(1)

                                                        if !suggestion.subtitle.isEmpty {
                                                            Text(suggestion.subtitle)
                                                                .font(.caption)
                                                                .foregroundColor(.secondary)
                                                                .lineLimit(1)
                                                        }
                                                    }

                                                    Spacer()
                                                }
                                                .padding(.vertical, 10)
                                                .padding(.horizontal, 12)
                                            }

                                            if suggestion != searchVM.suggestions.last {
                                                Divider()
                                            }
                                        }
                                    }
                                }
                                .frame(maxHeight: 260)
                                .background(.ultraThinMaterial)
                                .cornerRadius(18)
                                .padding(.horizontal, 16)
                            }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Spacer()

                    // ➕ ADD REPORT
                    Button {
                        // “Seçtiğin bölge” = ekrana bakılan bölgenin merkezi
                        selectedCoordinateForReport = region.center
                        showAddReport = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 8)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationDestination(isPresented: $goSettings) {
                SettingsView(isLoggedIn: $isLoggedIn)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)

            // Add Report Sheet
            .sheet(isPresented: $showAddReport) {
                AddReportSheet(
                    lm: lm,
                    coordinate: selectedCoordinateForReport ?? region.center
                ) { safety, comment, coordinate in
                    reportsVM.addReport(safety: safety, comment: comment, coordinate: coordinate)
                }
            }

            // Cluster (pin) sheet
            .sheet(isPresented: $showClusterSheet) {
                if let cluster = selectedCluster {
                    ClusterDetailsSheet(
                        lm: lm,
                        cluster: cluster,
                        onDirections: {
                            openInAppleMaps(destination: cluster.coordinate)
                        }
                    )
                }
            }

            .onAppear {
                locationManager.requestWhenInUse()
                reportsVM.startListening()
            }
        }
    }

    // MARK: - SEARCH ACTIONS

    private func clearSearch() {
        searchText = ""
        searchVM.suggestions = []
        hideKeyboard()
    }

    private func searchByText(_ text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        do {
            let item = try await searchVM.search(text: text, region: region)
            await MainActor.run {
                moveToCoordinate(item.placemark.coordinate)
                searchVM.suggestions = []
                hideKeyboard()
            }
        } catch {}
    }

    private func selectSuggestion(_ completion: MKLocalSearchCompletion) async {
        do {
            let item = try await searchVM.search(completion: completion, region: region)
            await MainActor.run {
                moveToCoordinate(item.placemark.coordinate)
                searchVM.suggestions = []
                hideKeyboard()
            }
        } catch {}
    }

    private func moveToCoordinate(_ coordinate: CLLocationCoordinate2D) {
        withAnimation {
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }
    }

    // MARK: - LOCATION

    private func centerToMyLocation() {
        guard let loc = locationManager.lastLocation else {
            locationManager.requestWhenInUse()
            return
        }
        withAnimation {
            region = MKCoordinateRegion(
                center: loc.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }
    }

    // MARK: - APPLE MAPS DIRECTIONS

    private func openInAppleMaps(destination: CLLocationCoordinate2D) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        mapItem.name = "SafeMap Destination"

        // Current location is used automatically
        MKMapItem.openMaps(with: [mapItem], launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

