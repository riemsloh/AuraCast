//
//  WeatherViewModel.swift
//  AuraCast
//
//  Created by Olaf Lueg on 04.06.25.
//


// Copyright by Olaf Lueg

import Foundation // Für URL, URLSession, JSONDecoder
import SwiftUI // Für ObservableObject, @Published, @MainActor

// MARK: - WeatherViewModel
/// Ein ViewModel, das die Logik für den Abruf und die Verwaltung von Wetterdaten kapselt.
/// Es ist ein ObservableObject, damit Views auf Änderungen seiner @Published-Eigenschaften reagieren können.
class WeatherViewModel: ObservableObject {
    // Veröffentlichte Eigenschaften, die die UI aktualisieren, wenn sie sich ändern.
    @Published var observation: Observation? // Das aktuelle Wetterbeobachtungs-Objekt
    @Published var isLoading: Bool = false // Zeigt an, ob Daten geladen werden
    @Published var errorMessage: String? // Speichert Fehlermeldungen
    
    // Timer-Instanz für den automatischen Datenabruf
    private var timer: Timer?
    
    // Die Basis-URL für die Weather Company PWS Observations API.
    private let baseURL = "https://api.weather.com/v2/pws/observations/current"

    /// Ruft Wetterdaten asynchron von der Weather Company API ab.
    ///
    /// - Parameters:
    ///   - stationId: Die ID der Personal Weather Station (PWS).
    ///   - apiKey: Dein API-Schlüssel für die Weather Company API.
    ///   - units: Die gewünschte Maßeinheit (z.B. "m" für metrisch).
    @MainActor // Stellt sicher, dass UI-Updates auf dem Haupt-Thread erfolgen
    func fetchWeatherData(stationId: String, apiKey: String, units: String = "m") async {
        isLoading = true // Ladezustand aktivieren
        errorMessage = nil // Vorherige Fehlermeldungen zurücksetzen
        
        // URL-Komponenten erstellen, um die URL sicher zusammenzusetzen.
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "stationId", value: stationId),
            URLQueryItem(name: "format", value: "json"), // Wir erwarten JSON-Format
            URLQueryItem(name: "units", value: units), // Metrische Einheiten
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        
        // Überprüfen, ob die URL gültig ist.
        guard let url = components?.url else {
            errorMessage = "Ungültige URL-Konfiguration."
            isLoading = false
            return
        }
        
        do {
            // Daten von der URL abrufen.
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // HTTP-Antwort überprüfen.
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                errorMessage = "Serverfehler oder ungültige Antwort. Statuscode: \(statusCode)"
                isLoading = false
                return
            }
            
            // JSON-Daten decodieren.
            let decoder = JSONDecoder()
            let weatherResponse = try decoder.decode(WeatherObservationResponse.self, from: data)
            
            // Die erste Beobachtung (falls vorhanden) speichern.
            // Die API liefert ein Array, auch wenn es meist nur eine aktuelle Beobachtung ist.
            observation = weatherResponse.observations?.first
            
            // Wenn keine Beobachtungen gefunden wurden, eine entsprechende Meldung setzen.
            if observation == nil {
                errorMessage = "Keine Wetterdaten für die angegebene Station gefunden."
            }
            
        } catch let decodingError as DecodingError {
            // Spezifische Fehler beim Decodieren abfangen.
            print("Decodierungsfehler: \(decodingError)")
            errorMessage = "Fehler beim Decodieren der Wetterdaten. Bitte überprüfen Sie das Datenformat."
        } catch {
            // Allgemeine Netzwerk- oder andere Fehler abfangen.
            print("Netzwerkfehler: \(error)")
            errorMessage = "Fehler beim Abrufen der Wetterdaten: \(error.localizedDescription)"
        }
        
        isLoading = false // Ladezustand deaktivieren
    }
    
    /// Startet einen Timer, der alle 60 Sekunden Wetterdaten abruft.
    /// Ungültig macht jeden zuvor gestarteten Timer.
    func startFetchingDataAutomatically(stationId: String, apiKey: String) {
        // Vorhandenen Timer ungültig machen, um doppelte Timer zu vermeiden
        timer?.invalidate()
        
        // Neuen Timer erstellen, der alle 60 Sekunden feuert
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            // Sicherstellen, dass self noch existiert, bevor fetchWeatherData aufgerufen wird
            Task { @MainActor in
                await self?.fetchWeatherData(stationId: stationId, apiKey: apiKey)
            }
        }
        // Sofortigen ersten Abruf starten
        Task { @MainActor in
            await fetchWeatherData(stationId: stationId, apiKey: apiKey)
        }
    }
    
    /// Stoppt den automatischen Datenabruf-Timer.
    func stopFetchingDataAutomatically() {
        timer?.invalidate()
        timer = nil
    }
    
    // Beim Deinitialisieren des ViewModels den Timer stoppen, um Memory Leaks zu vermeiden
    deinit {
        stopFetchingDataAutomatically()
    }
}
