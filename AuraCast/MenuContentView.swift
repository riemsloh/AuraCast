//
//  MenuContentView.swift
//  AuraCast
//
//  Created by Olaf Lueg on 04.06.25.
//
// Copyright by Olaf Lueg

import SwiftUI

/// Ein View, das den Inhalt für das Menüleisten-Extra bereitstellt.
/// Es empfängt das WeatherViewModel und kann Umgebungsvariablen korrekt nutzen.
struct MenuContentView: View {
    // Empfängt das ViewModel von der AuraCastApp.
    @ObservedObject var viewModel: WeatherViewModel
    @ObservedObject var forecastModel: ForecastViewModel
    
    // Empfängt API-Informationen von der AuraCastApp.
    // Diese sind jetzt nicht mehr nötig, da das ViewModel sie direkt aus AppStorage liest.
    // let stationId: String // <-- Entfernt
    // let apiKey: String    // <-- Entfernt
    
    // Zugriff auf die Umgebungsvariable, um Fenster programmatisch zu öffnen.
    @Environment(\.openWindow) var openWindow

    // Eine feste Breite für den Inhalt des Popovers, basierend auf typischen Menüleisten-Popovers.
    let popoverContentWidth: CGFloat = 400

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Dies ist der Inhalt, der erscheint, wenn Sie auf das Menüleisten-Icon klicken.
            // Übergebe die weatherViewModel-Instanz und die feste Breite an WeatherDetailView.
            WeatherDetailView(viewModel: viewModel, contentWidth: popoverContentWidth)
            
            Divider()
                .background(Color.white.opacity(0.5)) // Teiler auch heller machen
            
            // Button, um das Hauptfenster (ContentView) zu öffnen.
            Button {
                openWindow(id: "mainWindow")
            } label: {
                HStack {
                    Image(systemName: "rectangle.split.2x1") // Symbol für Fenster
                        .font(.title2)
                    Text("Hauptfenster öffnen")
                }
            }
            .keyboardShortcut("o", modifiers: .command)
            .foregroundColor(.white) // Text des Buttons weiß färben
            
            // Neuer Button, um das Einstellungsfenster zu öffnen
            Button {
                openWindow(id: "settingsWindow")
            } label: {
                HStack {
                    Image(systemName: "gearshape.fill") // SF Symbol für Einstellungen
                    Text("Einstellungen")
                }
            }
            .keyboardShortcut(",", modifiers: .command) // Cmd+, ist Standard für Einstellungen
            .foregroundColor(.white)
            
            Divider()
                .background(Color.white.opacity(0.5)) // Teiler auch heller machen
            
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                HStack {
                    Image(systemName: "power") // SF Symbol für Beenden
                    Text("AuraCast beenden")
                }
            }
            .keyboardShortcut("q")
            .foregroundColor(.white) // Text des Buttons weiß färben
            
            // WICHTIG: Starte den Datenabruf und den Timer, sobald dieses View erscheint.
            .onAppear {
                // stationId und apiKey Parameter entfernt, da ViewModel sie direkt aus AppStorage liest.
                viewModel.startFetchingDataAutomatically()
                forecastModel.startFetchingDataAutomatically()
            }
            .onDisappear {
                // Stoppe den Timer, wenn das Menüleisten-Pop-over geschlossen wird.
                viewModel.stopFetchingDataAutomatically()
                forecastModel.stopFetchingDataAutomatically()
            }
        }
        .padding()
        .frame(width: popoverContentWidth) // Feste Breite für den VStack
        .background(.ultraThinMaterial) // Transparenter Hintergrund mit Material
        .cornerRadius(10) // Abgerundete Ecken für das Popover
        .colorScheme(.dark) // Setzt das Farbschema des Popovers auf dunkel
    }
}

// MARK: - MenuContentView_Previews
struct MenuContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Für die Vorschau muss nur noch ein Mock-ViewModel übergeben werden.
        MenuContentView(viewModel: WeatherViewModel(), forecastModel: ForecastViewModel()) // <-- stationId und apiKey Parameter entfernt
            .padding()
            .frame(width: 300, height: 400) // Beispielgröße für die Vorschau
    }
}
