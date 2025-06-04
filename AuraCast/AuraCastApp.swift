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

    @State var currentNumber: String = "1" // Dies ist ein Beispiel-Status, der im Menüleisten-Icon angezeigt wird
    
    // API-Informationen direkt in der App-Struktur für den Start des ViewModels
    // Diese werden nun an MenuContentView übergeben, wo der Timer gestartet wird.
    private let stationId = "IMELLE143" // Beispiel: "KMAHANOV10"
    private let apiKey = "50ca47653ab440628a47653ab47062a3" // Dein persönlicher API-Schlüssel

    // Der init()-Block wurde entfernt, da der Datenabruf nun im MenuContentView.onAppear gestartet wird.
    // init() { ... }

    var body: some Scene {
        MenuBarExtra(currentNumber, systemImage: "\(currentNumber).circle") {
            // Verwende das neue MenuContentView hier und übergebe das ViewModel und die API-Infos.
            MenuContentView(viewModel: weatherViewModel, stationId: stationId, apiKey: apiKey)
        }
        .menuBarExtraStyle(.window) // Setzt den Stil auf .window
        
        // Das Hauptfenster der App. Gib ihm eine ID, damit es programmatisch geöffnet werden kann.
        WindowGroup(id: "mainWindow") {
            // Übergebe die weatherViewModel-Instanz an ContentView.
            ContentView(viewModel: weatherViewModel)
        }
        // Optional: Standardgröße für das Hauptfenster festlegen
        .defaultSize(width: 800, height: 600)
    }
}
