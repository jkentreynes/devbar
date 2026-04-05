//
//  TextUtilityViews.swift
//  devbar
//
//  Created by John Kent Reynes on 4/5/26.
//

import SwiftUI

// MARK: - Case Converter
struct CaseConverterView: View {
    @State private var inputText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Label("Input Text", systemImage: "square.and.pencil")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                TextEditor(text: $inputText)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 100)
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            
            Divider()
            
            ScrollView {
                VStack(spacing: 12) {
                    CaseResultRow(label: "UPPERCASE", value: inputText.uppercased())
                    CaseResultRow(label: "lowercase", value: inputText.lowercased())
                    CaseResultRow(label: "Title Case", value: inputText.capitalized)
                    CaseResultRow(label: "camelCase", value: toCamelCase(inputText))
                    CaseResultRow(label: "PascalCase", value: toPascalCase(inputText))
                    CaseResultRow(label: "snake_case", value: toSnakeCase(inputText))
                    CaseResultRow(label: "kebab-case", value: toKebabCase(inputText))
                }
                .padding()
            }
        }
    }
    
    func toCamelCase(_ text: String) -> String {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        guard !words.isEmpty else { return "" }
        let first = words[0].lowercased()
        let rest = words.dropFirst().map { $0.capitalized }
        return ([first] + rest).joined()
    }
    
    func toPascalCase(_ text: String) -> String {
        text.components(separatedBy: .whitespacesAndNewlines)
            .map { $0.capitalized }
            .joined()
    }
    
    func toSnakeCase(_ text: String) -> String {
        text.components(separatedBy: .whitespacesAndNewlines)
            .joined(separator: "_")
            .lowercased()
    }
    
    func toKebabCase(_ text: String) -> String {
        text.components(separatedBy: .whitespacesAndNewlines)
            .joined(separator: "-")
            .lowercased()
    }
}

struct CaseResultRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Text(value)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(6)
                
                Button(action: {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(value, forType: .string)
                }) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Line Sorter
struct LineSorterView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var ascending: Bool = true
    @State private var caseSensitive: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Label("Input", systemImage: "square.and.pencil")
                    .font(.subheadline)
                    .fontWeight(.medium)
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
                    Toggle("Ascending", isOn: $ascending)
                        .toggleStyle(.checkbox)
                    Toggle("Case Sensitive", isOn: $caseSensitive)
                        .toggleStyle(.checkbox)
                }
                
                Button(action: sort) {
                    Label("Sort Lines", systemImage: "line.3.horizontal.decrease")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Sorted Output", systemImage: "doc.text")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Button(action: copyOutput) {
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
    
    func sort() {
        var lines = inputText.components(separatedBy: .newlines)
        
        if caseSensitive {
            lines.sort()
        } else {
            lines.sort { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        }
        
        if !ascending {
            lines.reverse()
        }
        
        outputText = lines.joined(separator: "\n")
    }
    
    func copyOutput() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(outputText, forType: .string)
    }
}

// MARK: - Duplicate Line Remover
struct DuplicateLineRemoverView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var caseSensitive: Bool = false
    @State private var removedCount: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Label("Input", systemImage: "square.and.pencil")
                    .font(.subheadline)
                    .fontWeight(.medium)
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
                Toggle("Case Sensitive", isOn: $caseSensitive)
                    .toggleStyle(.checkbox)
                
                Button(action: removeDuplicates) {
                    Label("Remove Duplicates", systemImage: "doc.badge.minus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                if removedCount > 0 {
                    Text("Removed \(removedCount) duplicate line(s)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
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
    
    func removeDuplicates() {
        let lines = inputText.components(separatedBy: .newlines)
        let originalCount = lines.count
        
        var seen = Set<String>()
        var unique = [String]()
        
        for line in lines {
            let key = caseSensitive ? line : line.lowercased()
            if !seen.contains(key) {
                seen.insert(key)
                unique.append(line)
            }
        }
        
        outputText = unique.joined(separator: "\n")
        removedCount = originalCount - unique.count
    }
    
    func copyOutput() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(outputText, forType: .string)
    }
}

// MARK: - Regex Tester
struct RegexTesterView: View {
    @State private var pattern: String = ""
    @State private var testString: String = ""
    @State private var matches: [String] = []
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Regular Expression", systemImage: "asterisk.circle")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter regex pattern", text: $pattern)
                        .font(.system(.body, design: .monospaced))
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(6)
                        .onChange(of: pattern) { _, _ in test() }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Label("Test String", systemImage: "text.quote")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextEditor(text: $testString)
                        .font(.system(.body, design: .monospaced))
                        .frame(height: 120)
                        .scrollContentBackground(.hidden)
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(6)
                        .onChange(of: testString) { _, _ in test() }
                }
            }
            .padding()
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Matches", systemImage: "checkmark.circle")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(matches.count) match(es)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(matches.enumerated()), id: \.offset) { index, match in
                            HStack {
                                Text("Match \(index + 1):")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(match)
                                    .font(.system(.caption, design: .monospaced))
                                    .textSelection(.enabled)
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(nsColor: .textBackgroundColor))
                            .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 12)
            }
        }
    }
    
    func test() {
        guard !pattern.isEmpty && !testString.isEmpty else {
            matches = []
            errorMessage = ""
            return
        }
        
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(testString.startIndex..., in: testString)
            let results = regex.matches(in: testString, range: range)
            
            matches = results.compactMap { match in
                guard let range = Range(match.range, in: testString) else { return nil }
                return String(testString[range])
            }
            
            errorMessage = ""
        } catch {
            matches = []
            errorMessage = "Invalid regex pattern: \(error.localizedDescription)"
        }
    }
}

// MARK: - Word & Char Counter
struct WordCharCounterView: View {
    @State private var inputText: String = ""
    
    var charCount: Int { inputText.count }
    var charNoSpaces: Int { inputText.filter { !$0.isWhitespace }.count }
    var wordCount: Int { inputText.split(whereSeparator: \.isWhitespace).count }
    var lineCount: Int { inputText.components(separatedBy: .newlines).count }
    var paragraphCount: Int { inputText.components(separatedBy: "\n\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Label("Text Input", systemImage: "square.and.pencil")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                TextEditor(text: $inputText)
                    .font(.system(.body))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            
            Divider()
            
            VStack(spacing: 16) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    StatCard(label: "Characters", value: "\(charCount)")
                    StatCard(label: "Characters (no spaces)", value: "\(charNoSpaces)")
                    StatCard(label: "Words", value: "\(wordCount)")
                    StatCard(label: "Lines", value: "\(lineCount)")
                    StatCard(label: "Paragraphs", value: "\(paragraphCount)")
                    StatCard(label: "Reading Time", value: "\(wordCount / 200) min")
                }
            }
            .padding()
        }
    }
}

struct StatCard: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
        .cornerRadius(8)
    }
}

// MARK: - Text Diff Viewer
struct TextDiffViewerView: View {
    @State private var text1: String = ""
    @State private var text2: String = ""
    
    var body: some View {
        HSplitView {
            VStack(alignment: .leading, spacing: 8) {
                Label("Original", systemImage: "doc")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                TextEditor(text: $text1)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .padding(.horizontal)
                    .padding(.bottom, 12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Modified", systemImage: "doc.badge.ellipsis")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                TextEditor(text: $text2)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .padding(.horizontal)
                    .padding(.bottom, 12)
            }
        }
    }
}

// MARK: - Slug Generator
struct SlugGeneratorView: View {
    @State private var inputText: String = ""
    @State private var slug: String = ""
    @State private var separator: String = "-"
    @State private var lowercase: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Input Text", systemImage: "square.and.pencil")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Enter text to slugify", text: $inputText)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(6)
                        .onChange(of: inputText) { _, _ in generateSlug() }
                }
                
                HStack {
                    Picker("Separator", selection: $separator) {
                        Text("Hyphen (-)").tag("-")
                        Text("Underscore (_)").tag("_")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                    .onChange(of: separator) { _, _ in generateSlug() }
                    
                    Toggle("Lowercase", isOn: $lowercase)
                        .toggleStyle(.checkbox)
                        .onChange(of: lowercase) { _, _ in generateSlug() }
                }
            }
            .padding()
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Generated Slug", systemImage: "link")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Button(action: copySlug) {
                        Label("Copy", systemImage: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                Text(slug.isEmpty ? "—" : slug)
                    .font(.system(.title3, design: .monospaced))
                    .textSelection(.enabled)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
            }
        }
    }
    
    func generateSlug() {
        var result = inputText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: separator)
            .components(separatedBy: CharacterSet.alphanumerics.union(CharacterSet(charactersIn: separator)).inverted)
            .joined()
        
        if lowercase {
            result = result.lowercased()
        }
        
        slug = result
    }
    
    func copySlug() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(slug, forType: .string)
    }
}

// MARK: - JSON Escape/Unescape
struct JSONEscapeUnescapeView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var isEscaping: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Label("Input", systemImage: "square.and.pencil")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                TextEditor(text: $inputText)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .onChange(of: inputText) { _, _ in process() }
            }
            
            Divider()
            
            VStack {
                Picker("Mode", selection: $isEscaping) {
                    Text("Escape").tag(true)
                    Text("Unescape").tag(false)
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
                .onChange(of: isEscaping) { _, _ in process() }
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
    
    func process() {
        if isEscaping {
            outputText = inputText
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "\n", with: "\\n")
                .replacingOccurrences(of: "\r", with: "\\r")
                .replacingOccurrences(of: "\t", with: "\\t")
        } else {
            outputText = inputText
                .replacingOccurrences(of: "\\\"", with: "\"")
                .replacingOccurrences(of: "\\n", with: "\n")
                .replacingOccurrences(of: "\\r", with: "\r")
                .replacingOccurrences(of: "\\t", with: "\t")
                .replacingOccurrences(of: "\\\\", with: "\\")
        }
    }
    
    func copyOutput() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(outputText, forType: .string)
    }
}
