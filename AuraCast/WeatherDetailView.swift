// Copyright by Olaf Lueg

import SwiftUI
import AppKit // Benötigt für NSFont, wenn du es in AppKitWhiteText verwendest

/// Ein View, das detaillierte Wetterinformationen anzeigt.
/// Es empfängt das WeatherViewModel als ObservedObject, um auf die Wetterdaten zuzugreifen.
struct WeatherDetailView: View {
    // Empfängt das ViewModel von einem übergeordneten View.
    @ObservedObject var viewModel: WeatherViewModel
    
    // Die vom übergeordneten View übergebene Inhaltsbreite.
    let contentWidth: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "cloud.sun.rain") // Icon für Titel
                    .font(.title)
                AppKitWhiteText(text: "Detaillierte Wetterinformationen", font: .systemFont(ofSize: 18), isBold: true, preferredWidth: contentWidth - (15 * 2) - 25) // Breite anpassen für Icon
            }
            .padding(.bottom, 5)

            // Überprüfen, ob Beobachtungsdaten und metrische Daten verfügbar sind.
            if let obs = viewModel.observation, let metricData = obs.metric {
                Group {
                    HStack {
                        Image(systemName: "location.fill") // Icon für Station
                        AppKitWhiteText(text: "Station ID: \(obs.stationID ?? "N/A")", preferredWidth: contentWidth - (15 * 2) - 25)
                    }
                    HStack {
                        Image(systemName: "map.fill") // Icon für Ort
                        AppKitWhiteText(text: "Ort: \(obs.neighborhood ?? "N/A"), \(obs.country ?? "N/A")", preferredWidth: contentWidth - (15 * 2) - 25)
                    }
                    HStack {
                        Image(systemName: "clock.fill") // Icon für Zeit
                        AppKitWhiteText(text: "Lokale Zeit: \(obs.obsTimeLocal ?? "N/A")", preferredWidth: contentWidth - (15 * 2) - 25)
                    }
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "thermometer.medium") // Icon für Temperatur
                        AppKitWhiteText(text: "Temperatur: \(metricData.temp?.formatted(.number.precision(.fractionLength(1))) ?? "N/A") °C", font: .systemFont(ofSize: 24), isBold: true, preferredWidth: contentWidth - (15 * 2) - 25)
                    }
                    
                    HStack {
                        Image(systemName: "humidity.fill") // Icon für Luftfeuchtigkeit
                        AppKitWhiteText(text: "Luftfeuchtigkeit: \(obs.humidity?.formatted(.number) ?? "N/A") %", preferredWidth: contentWidth - (15 * 2) - 25)
                    }
                    HStack {
                        Image(systemName: "wind") // Icon für Windgeschwindigkeit
                        AppKitWhiteText(text: "Windgeschwindigkeit: \(metricData.windSpeed?.formatted(.number.precision(.fractionLength(1))) ?? "N/A") m/s", preferredWidth: contentWidth - (15 * 2) - 25)
                    }
                    
                    if let windGust = metricData.windGust {
                        HStack {
                            Image(systemName: "wind.gusts") // Icon für Windböe
                            AppKitWhiteText(text: "Windböe: \(windGust.formatted(.number.precision(.fractionLength(1)))) m/s", preferredWidth: contentWidth - (15 * 2) - 25)
                        }
                    }
                    if let pressure = metricData.pressure {
                        HStack {
                            Image(systemName: "gauge.with.needle") // Icon für Druck
                            AppKitWhiteText(text: "Druck: \(pressure.formatted(.number.precision(.fractionLength(2)))) hPa", preferredWidth: contentWidth - (15 * 2) - 25)
                        }
                    }
                    if let precipRate = metricData.precipRate {
                        HStack {
                            Image(systemName: "cloud.rain.fill") // Icon für Niederschlagsrate
                            AppKitWhiteText(text: "Niederschlagsrate: \(precipRate.formatted(.number.precision(.fractionLength(2)))) mm/h", preferredWidth: contentWidth - (15 * 2) - 25)
                        }
                    }
                    if let precipTotal = metricData.precipTotal {
                        HStack {
                            Image(systemName: "cloud.drizzle.fill") // Icon für Gesamtniederschlag
                            AppKitWhiteText(text: "Gesamtniederschlag heute: \(precipTotal.formatted(.number.precision(.fractionLength(2)))) mm", preferredWidth: contentWidth - (15 * 2) - 25)
                        }
                    }
                    if let dewpt = metricData.dewpt {
                        HStack {
                            Image(systemName: "drop.fill") // Icon für Taupunkt
                            AppKitWhiteText(text: "Taupunkt: \(dewpt.formatted(.number.precision(.fractionLength(1)))) °C", preferredWidth: contentWidth - (15 * 2) - 25)
                        }
                    }
                    if let heatIndex = metricData.heatIndex {
                        HStack {
                            Image(systemName: "sun.max.fill") // Icon für Hitzeindex
                            AppKitWhiteText(text: "Hitzeindex: \(heatIndex.formatted(.number.precision(.fractionLength(1)))) °C", preferredWidth: contentWidth - (15 * 2) - 25)
                        }
                    }
                    if let windChill = metricData.windChill {
                        HStack {
                            Image(systemName: "thermometer.snowflake") // Icon für Windchill
                            AppKitWhiteText(text: "Windchill: \(windChill.formatted(.number.precision(.fractionLength(1)))) °C", preferredWidth: contentWidth - (15 * 2) - 25)
                        }
                    }
                    if let elev = metricData.elev {
                        HStack {
                            Image(systemName: "mountain.2.fill") // Icon für Höhe
                            AppKitWhiteText(text: "Höhe: \(elev.formatted(.number.precision(.fractionLength(0)))) m", preferredWidth: contentWidth - (15 * 2) - 25)
                        }
                    }
                    if let solarRadiation = obs.solarRadiation {
                        HStack {
                            Image(systemName: "sun.min.fill") // Icon für Sonnenstrahlung
                            AppKitWhiteText(text: "Sonnenstrahlung: \(solarRadiation.formatted(.number.precision(.fractionLength(1)))) W/m²", preferredWidth: contentWidth - (15 * 2) - 25)
                        }
                    }
                    if let uv = obs.uv {
                        HStack {
                            Image(systemName: "sun.max.fill") // Icon für UV-Index (kann gleich sein wie Hitzeindex)
                            AppKitWhiteText(text: "UV-Index: \(uv.formatted(.number.precision(.fractionLength(1))))", preferredWidth: contentWidth - (15 * 2) - 25)
                        }
                    }
                    if let winddir = obs.winddir {
                        HStack {
                            Image(systemName: "arrow.up.circle.fill") // Icon für Windrichtung
                            AppKitWhiteText(text: "Windrichtung: \(winddir.formatted(.number))°", preferredWidth: contentWidth - (15 * 2) - 25)
                        }
                    }
                    if let qcStatus = obs.qcStatus {
                        HStack {
                            Image(systemName: "checkmark.shield.fill") // Icon für Qualitätsstatus
                            AppKitWhiteText(text: "Qualitätsstatus: \(qcStatus)", preferredWidth: contentWidth - (15 * 2) - 25)
                        }
                    }
                }
            } else if viewModel.isLoading {
                ProgressView("Lade Details...")
                    .foregroundColor(.white)
            } else if let errorMessage = viewModel.errorMessage {
                Text("Fehler beim Laden der Details: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    AppKitWhiteText(text: "Keine detaillierten Wetterdaten verfügbar.", preferredWidth: contentWidth - (15 * 2) - 25)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        // Hintergrund wird jetzt durch MenuContentView gesetzt
        // .background(Color.black.opacity(0.7))
        .cornerRadius(10)
        .foregroundColor(.white) // Sicherstellen, dass die Icons weiß sind
    }
}

// MARK: - WeatherDetailView_Previews
struct WeatherDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = WeatherViewModel()
        mockViewModel.observation = Observation(
            stationID: "MOCK123",
            obsTimeUtc: "2025-06-04T10:00:00Z",
            obsTimeLocal: "2025-06-04 12:00:00",
            neighborhood: "Mock City",
            softwareType: "Mock Software",
            country: "DE",
            solarRadiation: 500.0,
            lon: 10.0,
            realtimeFrequency: 5,
            epoch: 1678886400,
            lat: 52.0,
            uv: 3.5,
            winddir: 270,
            humidity: 65,
            qcStatus: 1,
            metric: UnitsData(
                temp: 22.5,
                heatIndex: 23.0,
                dewpt: 15.0,
                windChill: 22.0,
                windSpeed: 5.2,
                windGust: 7.8,
                pressure: 1012.5,
                precipRate: 0.1,
                precipTotal: 1.2,
                elev: 50.0
            )
        )
        
        return WeatherDetailView(viewModel: mockViewModel, contentWidth: 280)
            .padding()
            .frame(width: 500, height: 600)
            .background(Color.black)
    }
}
