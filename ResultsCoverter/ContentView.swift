import SwiftUI
import AppKit

struct ContentView: View {
    @State private var emailText: String = ""
    @State private var markdownText: String = ""
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            TextEditor(text: $emailText)
                .border(Color.gray, width: 1)
                .padding()
                .frame(height: 200)
            
            HStack {
                Button(action: {
                    locationManager.requestLocationPermission()
                }) {
                    Text("Add Location Data")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                Button(action: {
                    markdownText = formatAsMarkdown(emailText: emailText)
                }) {
                    Text("Format as Markdown")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }

            TextEditor(text: $markdownText)
                .border(Color.gray, width: 1)
                .padding()
                .frame(height: 200)
            
            Button(action: {
                copyToClipboard(text: markdownText)
            }) {
                Text("Copy to Clipboard")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
        .onAppear {
            locationManager.start()
        }
        .onReceive(locationManager.$locationText) { locationText in
            // Update the markdown text when the location is retrieved
            markdownText = formatAsMarkdown(emailText: emailText)
        }
    }
    
    func formatAsMarkdown(emailText: String) -> String {
        var markdownText = emailText
        
        // Format sections
        markdownText = markdownText.replacingOccurrences(of: "ethernet_green Test", with: "# Ethernet Test")
        markdownText = markdownText.replacingOccurrences(of: "flash_on_green PoE", with: "## PoE")
        markdownText = markdownText.replacingOccurrences(of: "ll_link_green Link", with: "## Link")
        markdownText = markdownText.replacingOccurrences(of: "ll_switch_black Switch", with: "## Switch")
        markdownText = markdownText.replacingOccurrences(of: "ll_dhcp_green DHCP", with: "## DHCP")
        markdownText = markdownText.replacingOccurrences(of: "ll_dns_black DNS", with: "## DNS")
        markdownText = markdownText.replacingOccurrences(of: "ll_gateway_green Gateway", with: "## Gateway")
        markdownText = markdownText.replacingOccurrences(of: "ll_www_green TCP", with: "## TCP")
        
        // Add location data if available
        if !locationManager.locationText.isEmpty {
            markdownText += "\n\n## Location\n\(locationManager.locationText)"
        }
        
        // Use bullet points for key-value pairs
        let lines = markdownText.split(separator: "\n")
        var formattedLines = [String]()
        for line in lines {
            if line.contains("\t") {
                let parts = line.split(separator: "\t")
                if parts.count == 2 {
                    formattedLines.append("- **\(parts[0].trimmingCharacters(in: .whitespacesAndNewlines))**: \(parts[1].trimmingCharacters(in: .whitespacesAndNewlines))")
                } else {
                    formattedLines.append(String(line))
                }
            } else {
                formattedLines.append(String(line))
            }
        }
        markdownText = formattedLines.joined(separator: "\n")
        
        return markdownText
    }
    
    func copyToClipboard(text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
