//
//  ForecastViewModel.swift
//  AuraCast
//
//  Created by Olaf Lueg on 05.06.25.
//
import Foundation // Für URL, URLSession, JSONDecoder
import SwiftUI // Für ObservableObject, @Published, @MainActor, @AppStorage

// MARK: - ForecastViewModel
/// Ein ViewModel, das die Logik für den Abruf und die Verwaltung der 5 Tage Vorhersage  kapselt.
/// Es ist ein ObservableObject, damit Views auf Änderungen seiner @Published-Eigenschaften reagieren können.
class ForecastViewModel: ObservableObject{
    // Veröffentlichte Eigenschaften, die die UI aktualisieren, wenn sie sich ändern.
    @Published var forecastResponse: ForecastResponse? // Das aktuelle Vorehersage-Objekt
    @Published var isLoading: Bool = false // Zeigt an, on Daten geladen werden
    @Published var errorMessage: String? // Speichert die Fehlermeldungen
    
    // Lese die Konfigurationswerte direkt aus AppStorage
    //Hier wird die Gelolocation benötigt
    //@AppStorage("selectedStationId") private var storedStationId: String = "YOUR_STATION_ID"
    @AppStorage("apiKey") private var storedApiKey: String = "YOUR_WEATHER_API_KEY"
    
    // Die Basis-URL für die Weather Company 5 Day Forecast API.
    private let baseURL = "https://api.weather.com/v3/wx/forecast/daily/5day"
    /// Ruft Wetterdaten asynchron von der Weather Company API ab.
    /// Verwendet die in AppStorage gespeicherten Werte für Geolocation und API-Schlüssel.
    @MainActor // Stellt sicher, dass UI-Updates auf dem Haupt-Thread erfolgen
    func fetchForecastData() async {
        // Verhindert unnötige aufrufe
        guard !isLoading else { return }
        isLoading = true // Ladezustand aktivieren
        errorMessage = nil // Vorherige Fehlermeldungen zurücksetzen
        
        // URL-Momponenten erstellen, um die URL sicher zusammenzusetzen
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            
        ]
    }
}
