//
//  ReferenceViews.swift
//  devbar
//
//  Created by John Kent Reynes on 4/5/26.
//

import SwiftUI

// MARK: - HTTP Status Lookup
struct HTTPStatusLookupView: View {
    @State private var searchText: String = ""
    
    let statusCodes: [(code: Int, text: String, description: String)] = [
        (100, "Continue", "The server has received the request headers"),
        (101, "Switching Protocols", "The requester has asked to switch protocols"),
        (200, "OK", "Standard response for successful HTTP requests"),
        (201, "Created", "The request has been fulfilled and resource created"),
        (202, "Accepted", "The request has been accepted for processing"),
        (204, "No Content", "Server successfully processed but no content to return"),
        (301, "Moved Permanently", "This and all future requests directed to new URI"),
        (302, "Found", "Temporary redirect"),
        (304, "Not Modified", "Resource has not been modified"),
        (400, "Bad Request", "Server cannot process the request due to client error"),
        (401, "Unauthorized", "Authentication is required"),
        (403, "Forbidden", "Server refuses to authorize the request"),
        (404, "Not Found", "The requested resource could not be found"),
        (405, "Method Not Allowed", "Request method not supported"),
        (408, "Request Timeout", "Server timed out waiting for request"),
        (409, "Conflict", "Request conflicts with current state"),
        (429, "Too Many Requests", "User has sent too many requests"),
        (500, "Internal Server Error", "Generic error message"),
        (501, "Not Implemented", "Server does not recognize request method"),
        (502, "Bad Gateway", "Server received invalid response from upstream"),
        (503, "Service Unavailable", "Server is currently unavailable"),
        (504, "Gateway Timeout", "Gateway did not receive timely response"),
    ]
    
    var filteredCodes: [(code: Int, text: String, description: String)] {
        if searchText.isEmpty {
            return statusCodes
        }
        return statusCodes.filter {
            "\($0.code)".contains(searchText) ||
            $0.text.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search status codes...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(6)
            .padding()
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredCodes, id: \.code) { item in
                        HTTPStatusRow(code: item.code, text: item.text, description: item.description)
                    }
                }
                .padding()
            }
        }
    }
}

struct HTTPStatusRow: View {
    let code: Int
    let text: String
    let description: String
    
    var codeColor: Color {
        switch code {
        case 100..<200: return .blue
        case 200..<300: return .green
        case 300..<400: return .orange
        case 400..<500: return .red
        case 500..<600: return .purple
        default: return .gray
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(code)")
                .font(.system(.title3, design: .monospaced))
                .fontWeight(.bold)
                .foregroundStyle(codeColor)
                .frame(width: 60, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(text)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
        .cornerRadius(8)
    }
}

// MARK: - Port Lookup
struct PortLookupView: View {
    @State private var searchText: String = ""
    
    let commonPorts: [(port: Int, service: String, description: String)] = [
        (20, "FTP Data", "File Transfer Protocol (Data)"),
        (21, "FTP Control", "File Transfer Protocol (Control)"),
        (22, "SSH", "Secure Shell"),
        (23, "Telnet", "Telnet protocol"),
        (25, "SMTP", "Simple Mail Transfer Protocol"),
        (53, "DNS", "Domain Name System"),
        (80, "HTTP", "Hypertext Transfer Protocol"),
        (110, "POP3", "Post Office Protocol v3"),
        (143, "IMAP", "Internet Message Access Protocol"),
        (443, "HTTPS", "HTTP Secure"),
        (465, "SMTPS", "SMTP Secure"),
        (587, "SMTP", "SMTP (message submission)"),
        (993, "IMAPS", "IMAP over SSL"),
        (995, "POP3S", "POP3 over SSL"),
        (3306, "MySQL", "MySQL database"),
        (3389, "RDP", "Remote Desktop Protocol"),
        (5432, "PostgreSQL", "PostgreSQL database"),
        (5900, "VNC", "Virtual Network Computing"),
        (6379, "Redis", "Redis database"),
        (8080, "HTTP Alt", "HTTP Alternative"),
        (27017, "MongoDB", "MongoDB database"),
    ]
    
    var filteredPorts: [(port: Int, service: String, description: String)] {
        if searchText.isEmpty {
            return commonPorts
        }
        return commonPorts.filter {
            "\($0.port)".contains(searchText) ||
            $0.service.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search ports...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(6)
            .padding()
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredPorts, id: \.port) { item in
                        PortRow(port: item.port, service: item.service, description: item.description)
                    }
                }
                .padding()
            }
        }
    }
}

struct PortRow: View {
    let port: Int
    let service: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(port)")
                .font(.system(.title3, design: .monospaced))
                .fontWeight(.bold)
                .foregroundStyle(.blue)
                .frame(width: 80, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(service)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
        .cornerRadius(8)
    }
}

// MARK: - MIME Type Reference
struct MIMETypeReferenceView: View {
    @State private var searchText: String = ""
    
    let mimeTypes: [(type: String, extension: String, description: String)] = [
        ("text/plain", ".txt", "Plain text"),
        ("text/html", ".html", "HTML document"),
        ("text/css", ".css", "Cascading Style Sheets"),
        ("text/javascript", ".js", "JavaScript"),
        ("application/json", ".json", "JSON format"),
        ("application/xml", ".xml", "XML document"),
        ("application/pdf", ".pdf", "Adobe PDF"),
        ("application/zip", ".zip", "ZIP archive"),
        ("image/jpeg", ".jpg", "JPEG image"),
        ("image/png", ".png", "PNG image"),
        ("image/gif", ".gif", "GIF image"),
        ("image/svg+xml", ".svg", "SVG vector image"),
        ("image/webp", ".webp", "WebP image"),
        ("video/mp4", ".mp4", "MP4 video"),
        ("video/webm", ".webm", "WebM video"),
        ("audio/mpeg", ".mp3", "MP3 audio"),
        ("audio/wav", ".wav", "WAV audio"),
        ("font/woff", ".woff", "Web Open Font Format"),
        ("font/woff2", ".woff2", "Web Open Font Format 2"),
    ]
    
    var filteredTypes: [(type: String, extension: String, description: String)] {
        if searchText.isEmpty {
            return mimeTypes
        }
        return mimeTypes.filter {
            $0.type.localizedCaseInsensitiveContains(searchText) ||
            $0.extension.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search MIME types...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(6)
            .padding()
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredTypes, id: \.type) { item in
                        MIMETypeRow(type: item.type, extension: item.extension, description: item.description)
                    }
                }
                .padding()
            }
        }
    }
}

struct MIMETypeRow: View {
    let type: String
    let `extension`: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(type)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
                
                HStack(spacing: 8) {
                    Text(`extension`)
                        .font(.caption)
                        .foregroundStyle(.blue)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(type, forType: .string)
            }) {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
        .cornerRadius(8)
    }
}

// MARK: - DNS Record Types
struct DNSRecordTypesView: View {
    let recordTypes: [(type: String, description: String)] = [
        ("A", "Address record - Maps hostname to IPv4 address"),
        ("AAAA", "IPv6 address record - Maps hostname to IPv6 address"),
        ("CNAME", "Canonical name record - Alias of one name to another"),
        ("MX", "Mail exchange record - Maps domain to message transfer agent"),
        ("NS", "Name server record - Delegates DNS zone to authoritative server"),
        ("PTR", "Pointer record - Maps IP address to hostname (reverse DNS)"),
        ("SOA", "Start of authority record - Specifies authoritative info about DNS zone"),
        ("SRV", "Service locator - Generalized service location record"),
        ("TXT", "Text record - Arbitrary text, often used for verification"),
        ("CAA", "Certification authority authorization - Specifies which CAs can issue certs"),
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(recordTypes, id: \.type) { record in
                    DNSRecordRow(type: record.type, description: record.description)
                }
            }
            .padding()
        }
    }
}

struct DNSRecordRow: View {
    let type: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(type)
                .font(.system(.title3, design: .monospaced))
                .fontWeight(.bold)
                .foregroundStyle(.blue)
                .frame(width: 80, alignment: .leading)
            
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
        .cornerRadius(8)
    }
}

// MARK: - HTML Color Names
struct HTMLColorNamesView: View {
    @State private var searchText: String = ""
    
    let colors: [(name: String, hex: String, color: Color)] = [
        ("Red", "#FF0000", .red),
        ("Green", "#008000", .green),
        ("Blue", "#0000FF", .blue),
        ("Yellow", "#FFFF00", .yellow),
        ("Orange", "#FFA500", .orange),
        ("Purple", "#800080", .purple),
        ("Pink", "#FFC0CB", .pink),
        ("Brown", "#A52A2A", .brown),
        ("Black", "#000000", .black),
        ("White", "#FFFFFF", .white),
        ("Gray", "#808080", .gray),
        ("Cyan", "#00FFFF", .cyan),
        ("Magenta", "#FF00FF", Color(red: 1, green: 0, blue: 1)),
        ("Navy", "#000080", Color(red: 0, green: 0, blue: 0.5)),
        ("Teal", "#008080", Color(red: 0, green: 0.5, blue: 0.5)),
        ("Lime", "#00FF00", Color(red: 0, green: 1, blue: 0)),
        ("Olive", "#808000", Color(red: 0.5, green: 0.5, blue: 0)),
        ("Maroon", "#800000", Color(red: 0.5, green: 0, blue: 0)),
    ]
    
    var filteredColors: [(name: String, hex: String, color: Color)] {
        if searchText.isEmpty {
            return colors
        }
        return colors.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.hex.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search colors...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(6)
            .padding()
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(filteredColors, id: \.name) { item in
                        ColorCard(name: item.name, hex: item.hex, color: item.color)
                    }
                }
                .padding()
            }
        }
    }
}

struct ColorCard: View {
    let name: String
    let hex: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            
            VStack(spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                HStack {
                    Text(hex)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Button(action: {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(hex, forType: .string)
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
        .cornerRadius(8)
    }
}
