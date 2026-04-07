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
        var result = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        result = result.replacingOccurrences(of: "><", with: ">\n<")

        var formatted = ""
        var indentLevel = 0
        let indent = String(repeating: " ", count: indentSpaces)

        for line in result.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            if trimmed.hasPrefix("</") {
                // Closing tag: dedent first
                indentLevel = max(0, indentLevel - 1)
                formatted += String(repeating: indent, count: indentLevel) + trimmed + "\n"
            } else if trimmed.hasSuffix("/>") || trimmed.hasPrefix("<?") || trimmed.hasPrefix("<!--") || trimmed.hasPrefix("<!") {
                // Self-closing, declaration, comment: no indent change
                formatted += String(repeating: indent, count: indentLevel) + trimmed + "\n"
            } else if trimmed.hasPrefix("<") && trimmed.contains("</") {
                // Inline element with content and closing tag on same line
                formatted += String(repeating: indent, count: indentLevel) + trimmed + "\n"
            } else if trimmed.hasPrefix("<") {
                // Opening tag: write then indent children
                formatted += String(repeating: indent, count: indentLevel) + trimmed + "\n"
                indentLevel += 1
            } else {
                // Text content
                formatted += String(repeating: indent, count: indentLevel) + trimmed + "\n"
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
            formatAction: formatYAML
        )
    }

    func formatYAML() {
        let lines = inputText.components(separatedBy: .newlines)
        let formatted = lines.map { line -> String in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            // Preserve empty lines and comments as-is
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                return line
            }
            // Normalize spacing around colon in key: value pairs (skip URLs with ://)
            if let colonRange = trimmed.range(of: ":"),
               !trimmed[colonRange.upperBound...].hasPrefix("/") {
                let afterColon = trimmed[colonRange.upperBound...]
                if afterColon.isEmpty || afterColon.first != " " {
                    let leadingSpaces = line.prefix(while: { $0 == " " })
                    let key = String(trimmed[..<colonRange.lowerBound])
                    let value = afterColon.trimmingCharacters(in: .whitespaces)
                    return leadingSpaces + key + ": " + value
                }
            }
            return line
        }
        outputText = formatted.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
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
        // Normalize whitespace first
        var result = inputText.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        // Keywords to place on new lines (order matters: longer phrases first)
        let keywords = [
            "INSERT INTO", "DELETE FROM", "CREATE TABLE", "DROP TABLE", "ALTER TABLE",
            "LEFT OUTER JOIN", "RIGHT OUTER JOIN", "FULL OUTER JOIN",
            "LEFT JOIN", "RIGHT JOIN", "INNER JOIN", "CROSS JOIN",
            "GROUP BY", "ORDER BY", "UNION ALL",
            "SELECT", "FROM", "WHERE", "JOIN", "ON", "SET",
            "HAVING", "LIMIT", "OFFSET", "VALUES", "UPDATE", "UNION"
        ]

        for keyword in keywords {
            let pattern = "(?i)\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let range = NSRange(result.startIndex..., in: result)
                result = regex.stringByReplacingMatches(in: result, range: range, withTemplate: "\n\(keyword.uppercased())")
            }
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
            formatAction: formatGraphQL
        )
    }

    func formatGraphQL() {
        // Normalize all whitespace into single spaces
        let normalized = inputText.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        var result = ""
        var indentLevel = 0
        let indent = "  "

        for char in normalized {
            switch char {
            case "{":
                result += " {\n"
                indentLevel += 1
                result += String(repeating: indent, count: indentLevel)
            case "}":
                // Trim trailing spaces from last line
                while result.hasSuffix(" ") { result = String(result.dropLast()) }
                if !result.hasSuffix("\n") { result += "\n" }
                indentLevel = max(0, indentLevel - 1)
                result += String(repeating: indent, count: indentLevel) + "}"
                result += indentLevel > 0 ? "\n" + String(repeating: indent, count: indentLevel) : "\n"
            case ",":
                while result.hasSuffix(" ") { result = String(result.dropLast()) }
                result += "\n" + String(repeating: indent, count: indentLevel)
            case " ":
                if !result.hasSuffix(" ") && !result.hasSuffix("\n") {
                    result += " "
                }
            default:
                result += String(char)
            }
        }

        outputText = result.trimmingCharacters(in: .whitespacesAndNewlines)
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
            formatAction: formatTOML
        )
    }

    func formatTOML() {
        let lines = inputText.components(separatedBy: .newlines)
        var formatted: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.isEmpty {
                // Collapse multiple blank lines into one
                if formatted.last != "" { formatted.append("") }
                continue
            }

            // Comments: preserve as-is
            if trimmed.hasPrefix("#") {
                formatted.append(trimmed)
                continue
            }

            // Section headers [section] or [[array]]
            if trimmed.hasPrefix("[") {
                if !formatted.isEmpty && formatted.last != "" { formatted.append("") }
                formatted.append(trimmed)
                continue
            }

            // key = value: normalize spacing around =
            if let eqRange = trimmed.range(of: "="), !trimmed.hasPrefix("=") {
                let key = trimmed[..<eqRange.lowerBound].trimmingCharacters(in: .whitespaces)
                let value = trimmed[eqRange.upperBound...].trimmingCharacters(in: .whitespaces)
                formatted.append("\(key) = \(value)")
                continue
            }

            formatted.append(trimmed)
        }

        outputText = formatted.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
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
        let lines = inputText.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard !lines.isEmpty else { outputText = ""; return }

        let rows = lines.map { line -> [String] in
            // Basic CSV parse: split on commas, respect quoted fields
            var fields: [String] = []
            var current = ""
            var inQuotes = false
            for char in line {
                if char == "\"" {
                    inQuotes.toggle()
                } else if char == "," && !inQuotes {
                    fields.append(current.trimmingCharacters(in: .whitespaces))
                    current = ""
                } else {
                    current.append(char)
                }
            }
            fields.append(current.trimmingCharacters(in: .whitespaces))
            return fields
        }

        let maxCols = rows.map { $0.count }.max() ?? 0
        var colWidths = Array(repeating: 0, count: maxCols)
        for row in rows {
            for (i, cell) in row.enumerated() {
                colWidths[i] = max(colWidths[i], cell.count)
            }
        }

        var resultLines = rows.map { row -> String in
            let padded = (0..<maxCols).map { i -> String in
                let cell = i < row.count ? row[i] : ""
                return cell.padding(toLength: colWidths[i], withPad: " ", startingAt: 0)
            }
            return padded.joined(separator: " | ")
        }

        // Insert header separator after first row
        if resultLines.count > 1 {
            let separator = colWidths.map { String(repeating: "-", count: $0) }.joined(separator: "-+-")
            resultLines.insert(separator, at: 1)
        }

        outputText = resultLines.joined(separator: "\n")
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
    
    let voidElements: Set<String> = [
        "area", "base", "br", "col", "embed", "hr", "img", "input",
        "link", "meta", "param", "source", "track", "wbr"
    ]

    func tagName(from line: String) -> String {
        let stripped = line.drop(while: { $0 == "<" || $0 == "/" })
        return String(stripped.prefix(while: { !$0.isWhitespace && $0 != ">" && $0 != "/" })).lowercased()
    }

    func formatHTML() {
        var result = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        result = result.replacingOccurrences(of: "><", with: ">\n<")

        var formatted = ""
        var indentLevel = 0
        let indent = String(repeating: " ", count: indentSpaces)

        for line in result.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            let name = tagName(from: trimmed)
            let isVoid = voidElements.contains(name)

            if trimmed.hasPrefix("</") {
                indentLevel = max(0, indentLevel - 1)
                formatted += String(repeating: indent, count: indentLevel) + trimmed + "\n"
            } else if trimmed.hasSuffix("/>") || isVoid || trimmed.hasPrefix("<!") || trimmed.hasPrefix("<?") {
                formatted += String(repeating: indent, count: indentLevel) + trimmed + "\n"
            } else if trimmed.hasPrefix("<") && trimmed.contains("</") {
                // Inline: <tag>content</tag>
                formatted += String(repeating: indent, count: indentLevel) + trimmed + "\n"
            } else if trimmed.hasPrefix("<") {
                formatted += String(repeating: indent, count: indentLevel) + trimmed + "\n"
                indentLevel += 1
            } else {
                formatted += String(repeating: indent, count: indentLevel) + trimmed + "\n"
            }
        }

        outputText = formatted.trimmingCharacters(in: .whitespacesAndNewlines)
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
        // Normalize whitespace
        var result = inputText.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        // Ensure single space before {
        if let regex = try? NSRegularExpression(pattern: "\\s*\\{") {
            result = regex.stringByReplacingMatches(in: result, range: NSRange(result.startIndex..., in: result), withTemplate: " {")
        }
        // Newline + indent after {
        result = result.replacingOccurrences(of: "{ ", with: "{\n  ")
        result = result.replacingOccurrences(of: "{}", with: "{ }")
        // Newline + indent after each ;
        if let regex = try? NSRegularExpression(pattern: ";\\s*(?!\\s*\\})") {
            result = regex.stringByReplacingMatches(in: result, range: NSRange(result.startIndex..., in: result), withTemplate: ";\n  ")
        }
        // Last property before } — trim trailing spaces and close
        if let regex = try? NSRegularExpression(pattern: ";\\s*\\}") {
            result = regex.stringByReplacingMatches(in: result, range: NSRange(result.startIndex..., in: result), withTemplate: ";\n}")
        }
        // Newline after }
        if let regex = try? NSRegularExpression(pattern: "\\}\\s*") {
            result = regex.stringByReplacingMatches(in: result, range: NSRange(result.startIndex..., in: result), withTemplate: "}\n\n")
        }
        // Normalize space after colon in properties (not pseudo-selectors)
        if let regex = try? NSRegularExpression(pattern: ":\\s+") {
            result = regex.stringByReplacingMatches(in: result, range: NSRange(result.startIndex..., in: result), withTemplate: ": ")
        }

        outputText = result.trimmingCharacters(in: .whitespacesAndNewlines)
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
                    Text((try? AttributedString(markdown: inputText, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .full))) ?? AttributedString(inputText))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
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
