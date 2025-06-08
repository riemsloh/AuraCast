//
//  AuraCastApp.swift
//  AuraCast
//
//  Created by Olaf Lueg on 03.06.25.
//
// Copyright by Olaf Lueg

import SwiftUI

@main
struct AuraCastApp: App {
    // Erstelle eine einzelne Instanz des WeatherViewModels, die von allen Views geteilt wird.
    // @StateObject stellt sicher, dass das ViewModel über den Lebenszyklus der App persistiert.
    @StateObject private var weatherViewModel = WeatherViewModel()
    @StateObject private var forecastModel = ForecastViewModel()
    
    @State var currentNumber: String = "1" // Dies ist ein Beispiel-Status, der im Menüleisten-Icon angezeigt wird
    
    var body: some Scene {
        MenuBarExtra(currentNumber, systemImage: "\(currentNumber).circle") {
            // Übergebe nur das ViewModel an MenuContentView. API-Infos werden intern verwaltet.
            MenuContentView(viewModel: weatherViewModel, forecastModel: ForecastViewModel()) // <-- stationId und apiKey Parameter entfernt
        }
        .menuBarExtraStyle(.window) // Setzt den Stil auf .window
        
        // Das Hauptfenster der App. Gib ihm eine ID, damit es programmatisch geöffnet werden kann.
        WindowGroup(id: "mainWindow") {
            // Übergebe die weatherViewModel-Instanz an ContentView.
            ContentView(viewModel: weatherViewModel, forecastModel: ForecastViewModel())
        }
        // Optional: Standardgröße für das Hauptfenster festlegen
        .defaultSize(width: 800, height: 600)
        
#if os(macOS)
        Settings {
            SettingsView()
        }
        // Neues Fenster für die Einstellungen, das über openWindow(id: "settingsWindow") geöffnet werden kann
        WindowGroup(id: "settingsWindow") { // <-- Hinzugefügt: WindowGroup für SettingsView
            SettingsView()
        }
        .defaultSize(width: 500, height: 350) // Standardgröße für das Einstellungsfenster
#endif
    }
}
