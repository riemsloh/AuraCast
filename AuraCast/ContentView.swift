// Copyright by Olaf Lueg

import SwiftUI
import Foundation // Für URL, URLSession, JSONDecoder


// MARK: - ContentView
/// Die Hauptansicht deiner macOS-App, die Wetterdaten anzeigt.
struct ContentView: View {
    // Erstellt eine Instanz des ViewModels und verwaltet deren Lebenszyklus.
    @ObservedObject var viewModel: WeatherViewModel // <-- Diese Zeile MUSS vorhanden sein!
        var body: some View {
        // VStack für vertikale Anordnung der Elemente.
        VStack(spacing: 20) {
            Text("Aktuelle Wetterdaten")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            // Hauptanzeigebereich für Wetterdaten. Dieser Block bleibt immer in der Hierarchie.
            VStack(alignment: .leading, spacing: 10) {
                // Die Textfelder verwenden optionale Verkettung und Nil-Coalescing,
                // um "N/A" anzuzeigen, wenn Daten noch nicht geladen sind oder fehlen.
                Text("Station: \(viewModel.observation?.stationID ?? "N/A")")
                    .font(.title2)
                Text("Ort: \(viewModel.observation?.neighborhood ?? "N/A"), \(viewModel.observation?.country ?? "N/A")")
                    .font(.title3)
                Text("Lokale Zeit: \(viewModel.observation?.obsTimeLocal ?? "N/A")")
                    .font(.subheadline)
                
                // Aktuelles Datum hinzufügen
                Text("Datum: \(Date().formatted(date: .long, time: .omitted))")
                    .font(.subheadline)
                
                Divider()
                
                // Metrische Daten anzeigen.
                // Dieser Block wird nur angezeigt, wenn metrische Daten verfügbar sind.
                // Die Werte innerhalb werden aktualisiert, ohne den gesamten Block neu zu laden.
                if let metricData = viewModel.observation?.metric {
                    Text("Temperatur: \(metricData.temp?.formatted(.number.precision(.fractionLength(1))) ?? "N/A") °C")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Luftfeuchtigkeit: \(viewModel.observation?.humidity?.formatted(.number) ?? "N/A") %")
                    Text("Windgeschwindigkeit: \(metricData.windSpeed?.formatted(.number.precision(.fractionLength(1))) ?? "N/A") m/s")
                    
                    // Weitere metrische Daten nach Bedarf hinzufügen
                    if let windGust = metricData.windGust {
                        Text("Windböe: \(windGust.formatted(.number.precision(.fractionLength(1)))) m/s")
                    }
                    if let pressure = metricData.pressure {
                        Text("Druck: \(pressure.formatted(.number.precision(.fractionLength(2)))) hPa")
                    }
                    if let precipRate = metricData.precipRate {
                        Text("Niederschlagsrate: \(precipRate.formatted(.number.precision(.fractionLength(2)))) mm/h")
                    }
                    if let precipTotal = metricData.precipTotal {
                        Text("Gesamtniederschlag heute: \(precipTotal.formatted(.number.precision(.fractionLength(2)))) mm")
                    }
                } else {
                    // Wenn keine metrischen Daten verfügbar sind, zeige eine Meldung an.
                    // Dieser Text ist ebenfalls immer Teil der Hierarchie.
                    Text("Metrische Daten nicht verfügbar.")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 15).fill(Color.blue.opacity(0.1)))
            .shadow(radius: 5)
            // Ladeindikator und Fehlermeldung als Overlay, um das Flackern zu minimieren.
            // Sie überlagern den Inhalt, anstatt ihn zu ersetzen.
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Lade Wetterdaten...")
                        .progressViewStyle(.circular)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Fehler: \(errorMessage)")
                        .foregroundColor(.red)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                }
            }
            
            // Button zum manuellen Abrufen der Daten.
            Button("Laden") {
                Task {
                    await viewModel.fetchWeatherData(units: "m")
                }
            }
            .buttonStyle(.borderedProminent) // Moderner Button-Stil für macOS
            .controlSize(.large)
            .padding(.top, 20)
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300) // Mindestgröße für das Fenster
    }
}

// MARK: - ContentView_Previews
/// Vorschau für die ContentView in Xcode.
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: WeatherViewModel())
    }
}
