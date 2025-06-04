//
//  AuraCastApp.swift // <- Überprüfen Sie, ob dies Ihr aktueller Dateiname ist
//  AuraCast        // <- Überprüfen Sie, ob dies Ihr aktueller Produktname ist
//
//  Created by Olaf Lueg on 03.06.25.
//

import SwiftUI
import AppKit // Weiterhin benötigt für NSApplication.shared.terminate

@main
struct AuraCastApp: App { // Haben den Struktur-Namen an Ihr Projekt angepasst
    @State var currentNumber: String = "1" // Dies ist ein Beispiel-Status, der im Menüleisten-Icon angezeigt wird
    
    // Die init()-Methode und der NSApp.setActivationPolicy(.accessory) Aufruf werden hier NICHT mehr benötigt.
    // MenuBarExtra handhabt dies intern.

    var body: some Scene {
        MenuBarExtra(currentNumber, systemImage: "\(currentNumber).circle") {
            // Dies ist der Inhalt, der erscheint, wenn Sie auf das Menüleisten-Icon klicken.
            // Der Inhalt hier ist ein Beispiel von dem Code, den Sie gefunden haben.
            Button("One") {
                currentNumber = "1"
            }
            .keyboardShortcut("1")
            Button("Two") {
                currentNumber = "2"
            }
            .keyboardShortcut("2")
            Button("Three") {
                currentNumber = "3"
            }
            .keyboardShortcut("3")
            Divider()
            Button("Quit AuraCast") { // Den Beenden-Button an den neuen App-Namen angepasst
                NSApplication.shared.terminate(nil)
            }.keyboardShortcut("q")
        }
    }
}
