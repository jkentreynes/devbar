//
//  FormatterViews.swift
//  devbar
//
//  Created by John Kent Reynes on 4/5/26.
//

import SwiftUI

// MARK: - JSON Formatter
struct JSONFormatterView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var indentSpaces: Int = 2
    @State private var sortKeys: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Input", systemImage: "square.and.pencil")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(inputText.count) chars")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                TextEditor(text: $inputText)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            
            Divider()
            
            VStack(spacing: 12) {
                HStack {
                    Text("Indent Spaces:")
                    Stepper("\(indentSpaces)", value: $indentSpaces, in: 1...8)
                        .frame(width: 100)
                    
                    Toggle("Sort keys", isOn: $sortKeys)
                        .toggleStyle(.checkbox)
                    
                    Spacer()
                }
                
                Button(action: format) {
                    Label("Format JSON", systemImage: "curlybraces")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Output", systemImage: "doc.text")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Button(action: copyOutput) {
                        Label("Copy", systemImage: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .disabled(outputText.isEmpty)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                TextEditor(text: .constant(outputText))
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
            }
        }
    }
    
    func format() {
        guard let data = inputText.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data),
              let formatted = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, sortKeys ? .sortedKeys : []]),
              var result = String(data: formatted, encoding: .utf8) else {
            outputText = "❌ Invalid JSON"
            return
        }
        
        if indentSpaces != 2 {
            let lines = result.components(separatedBy: .newlines)
            result = lines.map { line in
                let leadingSpaces = line.prefix(while: { $0 == " " }).count
                let indentLevel = leadingSpaces / 2
                let newIndent = String(repeating: " ", count: indentLevel * indentSpaces)
                return newIndent + line.trimmingCharacters(in: .whitespaces)
            }.joined(separator: "\n")
        }
        
        outputText = result
    }
    
    func copyOutput() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(outputText, forType: .string)
    }
}

// MARK: - JSON Minifier
struct JSONMinifierView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Input JSON", systemImage: "square.and.pencil")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(inputText.count) chars")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                TextEditor(text: $inputText)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            
            Divider()
            
            VStack {
                Button(action: minify) {
                    Label("Minify JSON", systemImage: "arrow.down.right.and.arrow.up.left")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Minified Output", systemImage: "doc.text")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(outputText.count) chars")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button(action: copyOutput) {
                        Label("Copy", systemImage: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .disabled(outputText.isEmpty)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                TextEditor(text: .constant(outputText))
                    .font(.system(.caption, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
            }
        }
    }
    
    func minify() {
        guard let data = inputText.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data),
              let minified = try? JSONSerialization.data(withJSONObject: json, options: []),
              let result = String(data: minified, encoding: .utf8) else {
            outputText = "❌ Invalid JSON"
            return
        }
        outputText = result
    }
    
    func copyOutput() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(outputText, forType: .string)
    }
}

// MARK: - XML Formatter
struct XMLFormatterView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var indentSpaces: Int = 2
    
    var body: some View {
        FormatterTemplate(
            title: "XML Formatter",
            inputText: $inputText,
            outputText: $outputText,
            indentSpaces: $indentSpaces,
            formatAction: formatXML
        )
    }
    
    func formatXML() {
        // Basic XML formatting
        var result = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        result = result.replacingOccurrences(of: "><", with: ">\n<")
        
        var formatted = ""
        var indentLevel = 0
        let indent = String(repeating: " ", count: indentSpaces)
        
        for line in result.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.hasPrefix("</") {
                indentLevel = max(0, indentLevel - 1)
            }
            
            formatted += String(repeating: indent, count: indentLevel) + trimmed + "\n"
            
            if trimmed.hasPrefix("<") && !trimmed.hasPrefix("</") && !trimmed.hasSuffix("/>") {
                indentLevel += 1
            }
        }
        
        outputText = formatted.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - YAML Formatter
struct YAMLFormatterView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    
    var body: some View {
        SimpleFormatterTemplate(
            title: "YAML Formatter",
            inputText: $inputText,
            outputText: $outputText,
            formatAction: { outputText = inputText.trimmingCharacters(in: .whitespacesAndNewlines) }
        )
    }
}

// MARK: - SQL Formatter
struct SQLFormatterView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    
    var body: some View {
        SimpleFormatterTemplate(
            title: "SQL Formatter",
            inputText: $inputText,
            outputText: $outputText,
            formatAction: formatSQL
        )
    }
    
    func formatSQL() {
        var result = inputText
        let keywords = ["SELECT", "FROM", "WHERE", "JOIN", "LEFT JOIN", "RIGHT JOIN", "INNER JOIN", "ON", "GROUP BY", "ORDER BY", "HAVING", "LIMIT", "OFFSET", "INSERT INTO", "VALUES", "UPDATE", "SET", "DELETE FROM"]
        
        for keyword in keywords {
            result = result.replacingOccurrences(of: keyword, with: "\n" + keyword, options: .caseInsensitive)
        }
        
        outputText = result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - GraphQL Formatter
struct GraphQLFormatterView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    
    var body: some View {
        SimpleFormatterTemplate(
            title: "GraphQL Formatter",
            inputText: $inputText,
            outputText: $outputText,
            formatAction: { outputText = inputText.trimmingCharacters(in: .whitespacesAndNewlines) }
        )
    }
}

// MARK: - TOML Formatter
struct TOMLFormatterView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    
    var body: some View {
        SimpleFormatterTemplate(
            title: "TOML Formatter",
            inputText: $inputText,
            outputText: $outputText,
            formatAction: { outputText = inputText.trimmingCharacters(in: .whitespacesAndNewlines) }
        )
    }
}

// MARK: - CSV Formatter
struct CSVFormatterView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    
    var body: some View {
        SimpleFormatterTemplate(
            title: "CSV Formatter",
            inputText: $inputText,
            outputText: $outputText,
            formatAction: formatCSV
        )
    }
    
    func formatCSV() {
        let lines = inputText.components(separatedBy: .newlines)
        let formatted = lines.map { line in
            line.components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .joined(separator: ", ")
        }
        outputText = formatted.joined(separator: "\n")
    }
}

// MARK: - HTML Formatter
struct HTMLFormatterView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var indentSpaces: Int = 2
    
    var body: some View {
        FormatterTemplate(
            title: "HTML Formatter",
            inputText: $inputText,
            outputText: $outputText,
            indentSpaces: $indentSpaces,
            formatAction: formatHTML
        )
    }
    
    func formatHTML() {
        var result = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        result = result.replacingOccurrences(of: "><", with: ">\n<")
        
        var formatted = ""
        var indentLevel = 0
        let indent = String(repeating: " ", count: indentSpaces)
        
        for line in result.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.hasPrefix("</") {
                indentLevel = max(0, indentLevel - 1)
            }
            
            formatted += String(repeating: indent, count: indentLevel) + trimmed + "\n"
            
            if trimmed.hasPrefix("<") && !trimmed.hasPrefix("</") && !trimmed.hasSuffix("/>") && !trimmed.contains("br") && !trimmed.contains("img") && !trimmed.contains("input") {
                indentLevel += 1
            }
        }
        
        outputText = formatted
    }
}

// MARK: - CSS Formatter
struct CSSFormatterView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    
    var body: some View {
        SimpleFormatterTemplate(
            title: "CSS Formatter",
            inputText: $inputText,
            outputText: $outputText,
            formatAction: formatCSS
        )
    }
    
    func formatCSS() {
        var result = inputText
        result = result.replacingOccurrences(of: "{", with: " {\n  ")
        result = result.replacingOccurrences(of: ";", with: ";\n  ")
        result = result.replacingOccurrences(of: "}", with: "\n}\n")
        outputText = result
    }
}

// MARK: - Markdown Preview
struct MarkdownPreviewView: View {
    @State private var inputText: String = "# Markdown Preview\n\nType your markdown here..."
    
    var body: some View {
        HSplitView {
            VStack(alignment: .leading, spacing: 8) {
                Label("Markdown Input", systemImage: "square.and.pencil")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                TextEditor(text: $inputText)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .padding(.horizontal)
                    .padding(.bottom, 12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Preview", systemImage: "doc.richtext")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                ScrollView {
                    Text(inputText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(nsColor: .textBackgroundColor))
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
        }
    }
}

// MARK: - Template Views
struct FormatterTemplate: View {
    let title: String
    @Binding var inputText: String
    @Binding var outputText: String
    @Binding var indentSpaces: Int
    let formatAction: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Input", systemImage: "square.and.pencil")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                TextEditor(text: $inputText)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            
            Divider()
            
            VStack {
                HStack {
                    Text("Indent Spaces:")
                    Stepper("\(indentSpaces)", value: $indentSpaces, in: 1...8)
                        .frame(width: 100)
                    Spacer()
                }
                Button(action: formatAction) {
                    Label("Format", systemImage: "wand.and.stars")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Output", systemImage: "doc.text")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Button(action: {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(outputText, forType: .string)
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                TextEditor(text: .constant(outputText))
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
            }
        }
    }
}

struct SimpleFormatterTemplate: View {
    let title: String
    @Binding var inputText: String
    @Binding var outputText: String
    let formatAction: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Input", systemImage: "square.and.pencil")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                TextEditor(text: $inputText)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            
            Divider()
            
            VStack {
                Button(action: formatAction) {
                    Label("Format", systemImage: "wand.and.stars")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Output", systemImage: "doc.text")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Button(action: {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(outputText, forType: .string)
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                TextEditor(text: .constant(outputText))
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
            }
        }
    }
}
