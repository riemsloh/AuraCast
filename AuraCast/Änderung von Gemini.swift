//
//  PersonalWeatherStation.swift
//  MeinWetter
//
//  Created by Olaf Lueg on 20.08.24.
//

import SwiftUI

// MARK: - ViewModifier für den geteilten Schatten
// Ein ViewModifier, der einen Divider mit einem Schatten-Effekt versieht.
struct ShadowedDivider: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                Divider() // Der eigentliche Divider
                    .shadow(radius: 5) // Leichter Schatten für den Divider
                    .padding(.horizontal) // Etwas horizontaler Abstand
            )
    }
}

// Eine Erweiterung für View, um den ViewModifier einfach anzuwenden
extension View {
    func shadowedDivider() -> some View {
        modifier(ShadowedDivider())
    }
}

// MARK: - Hauptansicht der persönlichen Wetterstation
struct PersonalWeatherStation: View {
    @Binding var results: [Result]
    @Binding var shortRangeForecast: ShortRangeForecast
    @Binding var fiveDayForecast: forecastResult
    @Binding var halfDayForecastArray: [halfDayForecast]

    var body: some View {
        ScrollView {
            HStack {
                // Temperaturansicht
                TemperaturView(results: $results, shortRangeForecast: $shortRangeForecast, fiveDayForecast: $fiveDayForecast)
                
                // Vertikaler Stapel für Wind und Luftfeuchtigkeit
                VStack {
                    WindView(results: $results)
                    HumidityView(results: $results)
                }
                
                // Vertikaler Stapel für Regen und Luftdruck
                VStack {
                    RainView(results: $results)
                    BarometerView(results: $results)
                }
                
                // Vertikaler Stapel für Taupunkt und UV-Index
                VStack {
                    DewpointView(results: $results)
                    UVIndexView(results: $results)
                }
            }
            .padding(.horizontal) // Etwas Polsterung für den HStack

            // Halbtagesvorhersage-Ansicht
            VStack {
                HalfDayForecastView(halfDayForecastArray: $halfDayForecastArray)
            }
            
            // Kurzfristvorhersage-Ansicht, nur anzeigen, wenn iconCode nicht leer ist
            if !shortRangeForecast.iconCode.isEmpty {
                ShortRangeForecastView(shortRangeForecast: $shortRangeForecast)
            }
        }
    }
}

// MARK: - Vorschau-Provider für PersonalWeatherStation
#Preview {
    // Beispiel-Mock-Daten für die Vorschau
    @State var mockResults: [Result] = [
        Result(stationID: "mock1", metric: Metric(temp: 18.5, windSpeed: 12.3, precipTotal: 0.5, pressure: 1015.2, dewpt: 8.7), humidity: 65, uv: 3)
    ]
    @State var mockShortRangeForecast = ShortRangeForecast(
        validTimeLocal: ["2024-08-20T10:00:00+02:00", "2024-08-20T11:00:00+02:00", "2024-08-20T12:00:00+02:00"],
        iconCode: ["01", "02", "03"],
        wxPhraseLong: ["Klar", "Teilweise bewölkt", "Bewölkt"],
        precipChance: [10, 20, 30],
        precipRate: [0.1, 0.2, 0.3]
    )
    @State var mockFiveDayForecast = forecastResult(
        calendarDayTemperatureMax: [25.0, 22.0, 23.0, 20.0, 19.0],
        calendarDayTemperatureMin: [15.0, 13.0, 14.0, 12.0, 11.0]
    )
    @State var mockHalfDayForecastArray: [halfDayForecast] = [
        halfDayForecast(daypartName: "Morgen", iconCode: "01", narrative: "Klarer Himmel, angenehme Temperaturen."),
        halfDayForecast(daypartName: "Nachmittag", iconCode: "03", narrative: "Teilweise bewölkt, leichter Regen möglich.")
    ]

    return PersonalWeatherStation(
        results: $mockResults,
        shortRangeForecast: $mockShortRangeForecast,
        fiveDayForecast: $mockFiveDayForecast,
        halfDayForecastArray: $mockHalfDayForecastArray
    )
}

// MARK: - Temperaturansicht
struct TemperaturView: View {
    @Binding var results: [Result]
    @Binding var shortRangeForecast: ShortRangeForecast
    @Binding var fiveDayForecast: forecastResult

    // Konstanten für die Ansicht
    private let cardWidth: CGFloat = 200
    private let cardHeight: CGFloat = 310

    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                .frame(width: cardWidth, height: cardHeight)
                .shadow(radius: 10)
                .foregroundColor(.secondary)
                .opacity(0.2)
            
            VStack {
                Label("Aktuell", systemImage: "")
                    .padding(.top, 12.0)
                    .font(.caption2)
                
                // Aktuelles Wetterphänomen
                if let wxPhraseLong = shortRangeForecast.wxPhraseLong.first, !wxPhraseLong.isEmpty {
                    Text(wxPhraseLong)
                        .padding(.top, 10.0)
                } else {
                    Text("N/A") // Platzhalter, wenn keine Daten verfügbar
                        .padding(.top, 10.0)
                }

                // Aktuelles Wettersymbol
                if let iconCode = shortRangeForecast.iconCode.first, !iconCode.isEmpty {
                    Image(iconCode) // Verwenden Sie den tatsächlichen Bildnamen
                        .padding(.top, 5.0)
                        .accessibilityLabel("Wettersymbol: \(shortRangeForecast.wxPhraseLong.first ?? "Unbekannt")")
                } else {
                    // Platzhalterbild oder leere Ansicht, wenn kein Icon verfügbar ist
                    Image(systemName: "questionmark.circle")
                        .padding(.top, 5.0)
                        .foregroundColor(.gray)
                }
                       
                // Aktuelle Temperatur von der Wetterstation
                ForEach(results, id: \.stationID) { result in
                    Label("\(result.metric.temp, specifier: "%.0f")°", systemImage: "")
                        .font(.title)
                }
                
                // Min/Max Temperaturen für den heutigen Tag (erster Tag der 5-Tages-Vorhersage)
                if let minTemp = fiveDayForecast.calendarDayTemperatureMin.first,
                   let maxTemp = fiveDayForecast.calendarDayTemperatureMax.first,
                   !fiveDayForecast.calendarDayTemperatureMin.isEmpty,
                   !fiveDayForecast.calendarDayTemperatureMax.isEmpty {
                    Text("\(minTemp, specifier: "%.0f")°/\(maxTemp, specifier: "%.0f")°")
                        .font(.callout)
                } else {
                    Text("N/A") // Platzhalter, wenn keine Daten verfügbar
                        .font(.callout)
                }
                Spacer()
            }
        }
    }
}

// MARK: - Windansicht
struct WindView: View {
    @Binding var results: [Result]
    private let cardSize: CGFloat = 150

    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                .frame(width: cardSize, height: cardSize)
                .shadow(radius: 10)
                .foregroundColor(.secondary)
                .opacity(0.2)
            
            VStack {
                Label("Wind", systemImage: "wind")
                    .font(.caption2)
                
                Spacer()
                
                ForEach(results, id: \.stationID) { result in
                    if let windSpeed = result.metric.windSpeed {
                        Label("\(windSpeed, specifier: "%.0f") km/h", systemImage: "")
                            .font(.title)
                    } else {
                        Text("N/A") // Zeigt N/A wenn Windgeschwindigkeit nil ist
                            .font(.title)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 6.0) // Angepasstes Padding
            .frame(width: cardSize - 10, height: cardSize - 10) // Innerer Frame
        }
    }
}


// MARK: - Luftfeuchtigkeitsansicht
struct HumidityView: View {
    @Binding var results: [Result]
    private let cardSize: CGFloat = 150

    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                .frame(width: cardSize, height: cardSize)
                .shadow(radius: 10)
                .foregroundColor(.secondary)
                .opacity(0.2)
            
            VStack {
                Label("Luftfeuchtigkeit", systemImage: "humidity")
                    .font(.caption2)
                
                Spacer()
                
                ForEach(results, id: \.stationID) { result in
                    Label("\(result.humidity) %", systemImage: "")
                        .font(.title)
                }
                
                Spacer()
            }
            .padding(.top, 6.0)
            .frame(width: cardSize - 10, height: cardSize - 10)
        }
    }
}

// MARK: - Regenansicht
struct RainView: View {
    @Binding var results: [Result]
    private let cardSize: CGFloat = 150

    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                .frame(width: cardSize, height: cardSize)
                .shadow(radius: 10)
                .foregroundColor(.secondary)
                .opacity(0.2)
            
            VStack {
                Label("Regen Heute", systemImage: "cloud.rain")
                    .font(.caption2)
                
                Spacer()
                
                ForEach(results, id: \.stationID) { result in
                    if let precipTotal = result.metric.precipTotal {
                        Label("\(precipTotal, specifier: "%.1f") l", systemImage: "")
                            .font(.title)
                    } else {
                        Text("N/A") // Zeigt N/A wenn Niederschlag nil ist
                            .font(.title)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 6.0)
            .frame(width: cardSize - 10, height: cardSize - 10)
        }
    }
}

// MARK: - Barometeransicht
struct BarometerView: View {
    @Binding var results: [Result]
    private let cardSize: CGFloat = 150

    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                .frame(width: cardSize, height: cardSize)
                .shadow(radius: 10)
                .foregroundColor(.secondary)
                .opacity(0.2)
            
            VStack {
                Label("Luftdruck", systemImage: "barometer")
                    .font(.caption2)
                
                Spacer()
                
                ForEach(results, id: \.stationID) { result in
                    if let pressure = result.metric.pressure {
                        Label("\(pressure, specifier: "%.0f") mB", systemImage: "")
                            .font(.title)
                    } else {
                        Text("N/A") // Zeigt N/A wenn Druck nil ist
                            .font(.title)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 6.0)
            .frame(width: cardSize - 10, height: cardSize - 10)
        }
    }
}

// MARK: - Taupunktansicht
struct DewpointView: View {
    @Binding var results: [Result]
    private let cardSize: CGFloat = 150

    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                .frame(width: cardSize, height: cardSize)
                .shadow(radius: 10)
                .foregroundColor(.secondary)
                .opacity(0.2)
            
            VStack {
                Label("Taupunkt", systemImage: "humidity") // humidity-Symbol für Taupunkt ist okay
                    .font(.caption2)
                
                Spacer()
                
                ForEach(results, id: \.stationID) { result in
                    if let dewpt = result.metric.dewpt {
                        Label("\(dewpt, specifier: "%.1f") °", systemImage: "")
                            .font(.title)
                    } else {
                        Text("N/A") // Zeigt N/A wenn Taupunkt nil ist
                            .font(.title)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 6.0)
            .frame(width: cardSize - 10, height: cardSize - 10)
        }
    }
}

// MARK: - UV-Index-Ansicht
struct UVIndexView: View {
    @Binding var results: [Result]
    private let cardSize: CGFloat = 150

    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                .frame(width: cardSize, height: cardSize)
                .shadow(radius: 10)
                .foregroundColor(.secondary)
                .opacity(0.2)
            
            VStack {
                Label("UV Index", systemImage: "sun.max.circle")
                    .font(.caption2)
                
                Spacer()
                
                ForEach(results, id: \.stationID) { result in
                    if let uvIndex = result.uv {
                        Label("\(uvIndex, specifier: "%.0f") ", systemImage: "")
                            .font(.title)
                    } else {
                        Text("N/A") // Zeigt N/A wenn UV-Index nil ist
                            .font(.title)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 6.0)
            .frame(width: cardSize - 10, height: cardSize - 10)
        }
    }
}

// MARK: - Kurzfristvorhersage-Ansicht
struct ShortRangeForecastView: View {
    @Binding var shortRangeForecast: ShortRangeForecast
    private let cardWidth: CGFloat = 500
    private let cardHeight: CGFloat = 170
    private let scrollFrameHeight: CGFloat = 200

    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                .frame(width: cardWidth, height: cardHeight)
                .shadow(radius: 10)
                .foregroundColor(.secondary)
                .opacity(0.2)
            
            ScrollView(.horizontal) {
                HStack(spacing: 15) { // Abstand zwischen den Elementen hinzufügen
                    ForEach(0..<min(shortRangeForecast.validTimeLocal.count, 12), id: \.self) { i in
                        VStack {
                            if let date = dateFromISOString(shortRangeForecast.validTimeLocal[i]) {
                                let hour = Calendar.current.component(.hour, from: date)
                                let minute = Calendar.current.component(.minute, from: date)
                                // Zeit mit zweistelligen Minuten formatieren
                                Text(String(format: "%d:%02d", hour, minute))
                                    .font(.subheadline)
                                    .padding(.bottom, 5)
                            } else {
                                Text("Ungültige Zeit")
                                    .font(.subheadline)
                                    .padding(.bottom, 5)
                            }
                            
                            if !shortRangeForecast.iconCode.isEmpty && i < shortRangeForecast.iconCode.count {
                                Image(shortRangeForecast.iconCode[i]) // Verwenden Sie den tatsächlichen Bildnamen
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 65, height: 40)
                                    .accessibilityLabel("Wettersymbol: \(shortRangeForecast.wxPhraseLong[i])")
                            } else {
                                Image(systemName: "questionmark.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 65, height: 40)
                                    .foregroundColor(.gray)
                            }
                            
                            if !shortRangeForecast.precipChance.isEmpty && i < shortRangeForecast.precipChance.count {
                                Label("\(shortRangeForecast.precipChance[i]) %", systemImage: "cloud.rain")
                                    .font(.caption)
                            }
                            
                            if !shortRangeForecast.precipRate.isEmpty && i < shortRangeForecast.precipRate.count {
                                Label("\(shortRangeForecast.precipRate[i], specifier: "%.1f") l", systemImage: "umbrella")
                                    .font(.caption)
                            }
                            Spacer()
                        }
                        .frame(width: 80) // Feste Breite für jedes Vorhersageelement
                    }
                }
                .padding(.vertical) // Vertikale Polsterung für den HStack
            }
            .padding(.top)
            .frame(width: cardWidth, height: scrollFrameHeight) // Anpassung an die Kartenbreite
        }
    }
}

// MARK: - Halbtagesvorhersage-Ansicht
struct HalfDayForecastView: View {
    @Binding var halfDayForecastArray: [halfDayForecast]
    private let cardWidth: CGFloat = 200
    private let cardHeight: CGFloat = 350

    var body: some View {
        ScrollView(.horizontal){
            HStack(spacing: 20){ // Abstand zwischen den Karten hinzufügen
                ForEach(halfDayForecastArray, id: \.daypartName) { result in
                    VStack{
                        ZStack{
                            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                                .frame(width: cardWidth, height: cardHeight)
                                .shadow(radius: 10)
                                .foregroundColor(.gray)
                                .opacity(0.09)
                            VStack(alignment: .leading, spacing: 10){ // Abstand zwischen den Elementen hinzufügen
                                Text(result.daypartName)
                                    .font(.headline)
                                
                                Image(result.iconCode) // Verwenden Sie den tatsächlichen Bildnamen
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80)
                                    .accessibilityLabel("Wettersymbol für \(result.daypartName)")
                                
                                Text(result.narrative)
                                    .font(.body)
                                    .lineLimit(nil) // Unbegrenzte Zeilen
                                    .fixedSize(horizontal: false, vertical: true) // Vertikale Anpassung
                                Spacer()
                            }
                            .padding(.all)
                        }
                    }
                    .frame(width: cardWidth, height: cardHeight)
                }
            }
        }
        .padding(.horizontal, 20.0) // Reduzierte horizontale Polsterung, um mehr Platz zu schaffen
    }
}

// MARK: - ISO String zu Datum Konverter
// Hilfsfunktion zum Konvertieren eines ISO 8601 Strings in ein Date-Objekt
func dateFromISOString(_ isoString: String) -> Date? {
    let isoDateFormatter = ISO8601DateFormatter()
    // isoDateFormatter.formatOptions = [.withFullDate]  // ignoriert die Zeit!
    // Stellt sicher, dass das Format Optionen für die Zeit enthält
    isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return isoDateFormatter.date(from: isoString) // gibt nil zurück, wenn isoString falsch formatiert ist.
}

// MARK: - Dummy-Strukturen für Vorschau/Test (Diese sollten in einer separaten Datei oder Ihrem Datenmodell definiert sein)
// Hier sind Platzhalter für die Datentypen, die Ihre Bindings erwarten.
// Ersetzen Sie diese durch Ihre tatsächlichen Modellstrukturen, wenn Sie den Code integrieren.
struct Result: Identifiable {
    let id = UUID() // Für Identifiable
    var stationID: String
    var metric: Metric
    var humidity: Int
    var uv: Int?
}

struct Metric {
    var temp: Double
    var windSpeed: Double?
    var precipTotal: Double?
    var pressure: Double?
    var dewpt: Double?
}

struct ShortRangeForecast {
    var validTimeLocal: [String]
    var iconCode: [String]
    var wxPhraseLong: [String]
    var precipChance: [Int]
    var precipRate: [Double]
}

struct forecastResult {
    var calendarDayTemperatureMax: [Double]
    var calendarDayTemperatureMin: [Double]
}

struct halfDayForecast: Identifiable {
    let id = UUID() // Für Identifiable
    var daypartName: String
    var iconCode: String
    var narrative: String
}
