//
//  AppKitWhiteText.swift
//  AuraCast
//
//  Created by Olaf Lueg on 04.06.25.
//
// Copyright by Olaf Lueg

import SwiftUI
import AppKit // Importiere AppKit für NSTextField

/// Ein SwiftUI View, das einen NSTextField umschließt, um die Textfarbe zuverlässig zu steuern.
struct AppKitWhiteText: NSViewRepresentable {
    let text: String
    var font: NSFont = .systemFont(ofSize: NSFont.systemFontSize)
    var alignment: NSTextAlignment = .left
    var isBold: Bool = false
    
    // WICHTIG: Diese Eigenschaft muss in deiner lokalen Datei vorhanden sein!
    var preferredWidth: CGFloat = 280 // Standardwert, falls nicht explizit übergeben

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField(labelWithString: text)
        textField.isEditable = false // Nicht bearbeitbar
        textField.isSelectable = false // Nicht selektierbar
        textField.drawsBackground = false // Kein Hintergrund
        textField.textColor = NSColor.white // <-- Hier wird die Textfarbe auf Weiß gesetzt!
        textField.alignment = alignment
        
        // WICHTIG: Textumbruch aktivieren
        textField.cell?.wraps = true
        textField.lineBreakMode = .byWordWrapping // Textumbruch an Wortgrenzen
        
        // WICHTIG: Setze die bevorzugte maximale Layout-Breite, damit NSTextField die Höhe korrekt berechnen kann.
        textField.preferredMaxLayoutWidth = preferredWidth
        
        if isBold {
            textField.font = NSFont.boldSystemFont(ofSize: font.pointSize)
        } else {
            textField.font = font
        }
        
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.stringValue = text // Aktualisiere den Text
        nsView.alignment = alignment // Aktualisiere die Ausrichtung
        nsView.preferredMaxLayoutWidth = preferredWidth // Aktualisiere die bevorzugte Breite
        
        if isBold {
            nsView.font = NSFont.boldSystemFont(ofSize: font.pointSize)
        } else {
            nsView.font = font
        }
    }
}

// MARK: - AppKitWhiteText_Previews
struct AppKitWhiteText_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 10) {
            // WICHTIG: Auch hier muss preferredWidth übergeben werden, da es jetzt ein Parameter ist.
            AppKitWhiteText(text: "Hello, White Text! This is a longer sentence to test word wrapping.", font: .systemFont(ofSize: 20), preferredWidth: 200)
            AppKitWhiteText(text: "This is bold.", font: .systemFont(ofSize: 16), isBold: true, preferredWidth: 200)
            AppKitWhiteText(text: "Right aligned.", alignment: .right, preferredWidth: 200)
        }
        .padding()
        .background(Color.black.opacity(0.8)) // Dunkler Hintergrund für die Vorschau
        .previewLayout(.sizeThatFits)
    }
}
