//
//  ViewsTextStringUtilitiesViews.swift
//  devbar
//
//  Created by John Kent Reynes on 4/7/26.
//

import SwiftUI

// MARK: - Shared types

private enum DiffLineType { case added, removed, unchanged }

private struct DiffResult: Identifiable {
    let id = UUID()
    let type: DiffLineType
    let text: String
}

private struct RegexMatch: Identifiable {
    let id: Int
    let range: String
    let value: String
    let groups: [String]
}

// MARK: - Case Converter

struct CaseConverterView: View {
    @State private var inputText = ""
    @State private var outputText = ""

    private let caseNames = [
        "camelCase", "PascalCase", "snake_case", "kebab-case",
        "SCREAMING_SNAKE", "Title Case", "UPPERCASE", "lowercase", "Sentence case"
    ]

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Label("Input", systemImage: "square.and.pencil")
                    .font(.subheadline).fontWeight(.medium)
                    .padding(.horizontal).padding(.top, 12)
                TextEditor(text: $inputText)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 120)
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal).padding(.bottom, 8)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Label("Convert To", systemImage: "textformat")
                    .font(.subheadline).fontWeight(.medium)
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 6
                ) {
                    ForEach(caseNames, id: \.self) { name in
                        Button(name) { convert(to: name) }
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Output", systemImage: "doc.text")
                        .font(.subheadline).fontWeight(.medium)
                    Spacer()
                    Button { copy(outputText) } label: {
                        Label("Copy", systemImage: "doc.on.doc").font(.caption)
                    }.buttonStyle(.bordered).disabled(outputText.isEmpty)
                }
                .padding(.horizontal).padding(.top, 12)
                TextEditor(text: .constant(outputText))
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal).padding(.bottom, 12)
            }
        }
    }

    func convert(to targetCase: String) {
        guard !inputText.isEmpty else { return }
        switch targetCase {
        case "UPPERCASE":     outputText = inputText.uppercased()
        case "lowercase":     outputText = inputText.lowercased()
        case "Sentence case": outputText = sentenceCase(inputText)
        case "Title Case":
            outputText = inputText.components(separatedBy: " ")
                .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
                .joined(separator: " ")
        default:
            let words = tokenize(inputText)
            switch targetCase {
            case "camelCase":
                outputText = words.isEmpty ? "" :
                    words[0].lowercased() + words.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }.joined()
            case "PascalCase":
                outputText = words.map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }.joined()
            case "snake_case":
                outputText = words.map { $0.lowercased() }.joined(separator: "_")
            case "kebab-case":
                outputText = words.map { $0.lowercased() }.joined(separator: "-")
            case "SCREAMING_SNAKE":
                outputText = words.map { $0.uppercased() }.joined(separator: "_")
            default: break
            }
        }
    }

    func tokenize(_ text: String) -> [String] {
        let rough = text.components(separatedBy: CharacterSet(charactersIn: " \t\n\r_-"))
            .filter { !$0.isEmpty }
        return rough.flatMap { splitCamelCase($0) }.filter { !$0.isEmpty }
    }

    func splitCamelCase(_ word: String) -> [String] {
        var result: [String] = []
        var current = ""
        let chars = Array(word)
        for i in 0..<chars.count {
            let c = chars[i]
            if c.isUppercase && !current.isEmpty {
                let prevIsLower = chars[i - 1].isLowercase || chars[i - 1].isNumber
                let nextIsLower = i + 1 < chars.count && chars[i + 1].isLowercase
                if prevIsLower || nextIsLower {
                    result.append(current)
                    current = String(c)
                } else {
                    current.append(c)
                }
            } else {
                current.append(c)
            }
        }
        if !current.isEmpty { result.append(current) }
        return result
    }

    func sentenceCase(_ text: String) -> String {
        var result = text.lowercased()
        if let first = result.indices.first {
            result.replaceSubrange(first...first, with: result[first].uppercased())
        }
        var i = result.startIndex
        while i < result.endIndex {
            if ".!?".contains(result[i]) {
                var j = result.index(after: i)
                while j < result.endIndex && (result[j] == " " || result[j] == "\n") {
                    j = result.index(after: j)
                }
                if j < result.endIndex && result[j].isLetter {
                    result.replaceSubrange(j...j, with: result[j].uppercased())
                }
            }
            i = result.index(after: i)
        }
        return result
    }

    func copy(_ s: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(s, forType: .string)
    }
}

// MARK: - Line Sorter

struct LineSorterView: View {
    @State private var inputText = ""
    @State private var outputText = ""
    @State private var sortOrder = "asc"
    @State private var sortType = "alpha"
    @State private var caseSensitive = false
    @State private var removeEmpty = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Input", systemImage: "square.and.pencil")
                        .font(.subheadline).fontWeight(.medium)
                    Spacer()
                    Text("\(inputText.components(separatedBy: .newlines).count) lines")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .padding(.horizontal).padding(.top, 12)
                TextEditor(text: $inputText)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 180)
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal).padding(.bottom, 8)
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sort type").font(.caption).foregroundStyle(.secondary)
                        Picker("", selection: $sortType) {
                            Text("Alphabetical").tag("alpha")
                            Text("By length").tag("length")
                            Text("Numeric").tag("numeric")
                        }.frame(width: 150)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Order").font(.caption).foregroundStyle(.secondary)
                        Picker("", selection: $sortOrder) {
                            Text("A → Z  /  ↑").tag("asc")
                            Text("Z → A  /  ↓").tag("desc")
                        }.frame(width: 120)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Options").font(.caption).foregroundStyle(.secondary)
                        HStack(spacing: 12) {
                            Toggle("Case sensitive", isOn: $caseSensitive).toggleStyle(.checkbox)
                            Toggle("Remove empty lines", isOn: $removeEmpty).toggleStyle(.checkbox)
                        }
                    }
                }
                Button(action: sort) {
                    Label("Sort Lines", systemImage: "arrow.up.arrow.down").frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Output", systemImage: "doc.text")
                        .font(.subheadline).fontWeight(.medium)
                    Spacer()
                    Button { copy(outputText) } label: {
                        Label("Copy", systemImage: "doc.on.doc").font(.caption)
                    }.buttonStyle(.bordered).disabled(outputText.isEmpty)
                }
                .padding(.horizontal).padding(.top, 12)
                TextEditor(text: .constant(outputText))
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal).padding(.bottom, 12)
            }
        }
    }

    func sort() {
        var lines = inputText.components(separatedBy: .newlines)
        if removeEmpty { lines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty } }
        switch sortType {
        case "alpha":
            lines.sort {
                let a = caseSensitive ? $0 : $0.lowercased()
                let b = caseSensitive ? $1 : $1.lowercased()
                return sortOrder == "asc" ? a < b : a > b
            }
        case "length":
            lines.sort { sortOrder == "asc" ? $0.count < $1.count : $0.count > $1.count }
        case "numeric":
            lines.sort {
                let a = Double($0.trimmingCharacters(in: .whitespaces)) ?? 0
                let b = Double($1.trimmingCharacters(in: .whitespaces)) ?? 0
                return sortOrder == "asc" ? a < b : a > b
            }
        default: break
        }
        outputText = lines.joined(separator: "\n")
    }

    func copy(_ s: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(s, forType: .string)
    }
}

// MARK: - Duplicate Line Remover

struct DuplicateLineRemoverView: View {
    @State private var inputText = ""
    @State private var outputText = ""
    @State private var caseSensitive = false
    @State private var trimWhitespace = true
    @State private var removedCount: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Input", systemImage: "square.and.pencil")
                        .font(.subheadline).fontWeight(.medium)
                    Spacer()
                    Text("\(inputText.components(separatedBy: .newlines).count) lines")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .padding(.horizontal).padding(.top, 12)
                TextEditor(text: $inputText)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal).padding(.bottom, 8)
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 16) {
                    Toggle("Case sensitive", isOn: $caseSensitive).toggleStyle(.checkbox)
                    Toggle("Trim whitespace before comparing", isOn: $trimWhitespace).toggleStyle(.checkbox)
                }
                Button(action: removeDuplicates) {
                    Label("Remove Duplicates", systemImage: "line.3.horizontal.decrease")
                        .frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Output", systemImage: "doc.text")
                        .font(.subheadline).fontWeight(.medium)
                    if let count = removedCount {
                        Text("\(count) duplicate\(count == 1 ? "" : "s") removed")
                            .font(.caption)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(count > 0 ? Color.green.opacity(0.15) : Color(nsColor: .controlBackgroundColor))
                            .foregroundStyle(count > 0 ? .green : .secondary)
                            .cornerRadius(4)
                    }
                    Spacer()
                    Button { copy(outputText) } label: {
                        Label("Copy", systemImage: "doc.on.doc").font(.caption)
                    }.buttonStyle(.bordered).disabled(outputText.isEmpty)
                }
                .padding(.horizontal).padding(.top, 12)
                TextEditor(text: .constant(outputText))
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal).padding(.bottom, 12)
            }
        }
    }

    func removeDuplicates() {
        let lines = inputText.components(separatedBy: .newlines)
        var seen = Set<String>()
        var result: [String] = []
        var removed = 0
        for line in lines {
            let key = trimWhitespace ? line.trimmingCharacters(in: .whitespaces) : line
            let compareKey = caseSensitive ? key : key.lowercased()
            if seen.insert(compareKey).inserted {
                result.append(line)
            } else {
                removed += 1
            }
        }
        outputText = result.joined(separator: "\n")
        removedCount = removed
    }

    func copy(_ s: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(s, forType: .string)
    }
}

// MARK: - Regex Tester

struct RegexTesterView: View {
    @State private var pattern = ""
    @State private var testText = ""
    @State private var flagCaseInsensitive = false
    @State private var flagMultiline = false
    @State private var matches: [RegexMatch] = []
    @State private var error = ""

    var body: some View {
        VStack(spacing: 0) {
            // Pattern bar
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text("/")
                        .font(.system(.title3, design: .monospaced))
                        .foregroundStyle(.secondary)
                    TextField("regular expression…", text: $pattern)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                        .onChange(of: pattern) { _ in runTest() }
                    Text("/")
                        .font(.system(.title3, design: .monospaced))
                        .foregroundStyle(.secondary)
                    Toggle("i", isOn: $flagCaseInsensitive)
                        .toggleStyle(.checkbox)
                        .help("Case insensitive")
                        .onChange(of: flagCaseInsensitive) { _ in runTest() }
                    Toggle("m", isOn: $flagMultiline)
                        .toggleStyle(.checkbox)
                        .help("Multiline (^ and $ match line starts/ends)")
                        .onChange(of: flagMultiline) { _ in runTest() }
                    Spacer()
                    if !matches.isEmpty {
                        Text("\(matches.count) match\(matches.count == 1 ? "" : "es")")
                            .font(.caption).foregroundStyle(.white)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color.green).cornerRadius(4)
                    } else if !pattern.isEmpty && error.isEmpty {
                        Text("No matches")
                            .font(.caption).foregroundStyle(.white)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color.orange).cornerRadius(4)
                    }
                }
                if !error.isEmpty {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))

            Divider()

            HSplitView {
                // Test string
                VStack(alignment: .leading, spacing: 8) {
                    Label("Test String", systemImage: "square.and.pencil")
                        .font(.subheadline).fontWeight(.medium)
                        .padding(.horizontal).padding(.top, 12)
                    TextEditor(text: $testText)
                        .font(.system(.body, design: .monospaced))
                        .scrollContentBackground(.hidden)
                        .background(Color(nsColor: .textBackgroundColor))
                        .padding(.horizontal).padding(.bottom, 12)
                        .onChange(of: testText) { _ in runTest() }
                }

                // Matches
                VStack(alignment: .leading, spacing: 8) {
                    Label("Matches", systemImage: "list.bullet")
                        .font(.subheadline).fontWeight(.medium)
                        .padding(.horizontal).padding(.top, 12)

                    if matches.isEmpty {
                        Spacer()
                        Text(pattern.isEmpty ? "Enter a pattern to test" : error.isEmpty ? "No matches found" : "Fix the pattern error")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 6) {
                                ForEach(Array(matches.prefix(100))) { match in
                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack {
                                            Text("Match \(match.id + 1)")
                                                .font(.caption).foregroundStyle(.secondary)
                                            Text(match.range)
                                                .font(.system(.caption, design: .monospaced))
                                                .foregroundStyle(.tertiary)
                                            Spacer()
                                        }
                                        Text(match.value)
                                            .font(.system(.body, design: .monospaced))
                                            .textSelection(.enabled)
                                        ForEach(match.groups.indices, id: \.self) { i in
                                            HStack(spacing: 4) {
                                                Text("Group \(i + 1):")
                                                    .font(.caption).foregroundStyle(.secondary)
                                                Text(match.groups[i])
                                                    .font(.system(.caption, design: .monospaced))
                                                    .textSelection(.enabled)
                                            }
                                        }
                                    }
                                    .padding(8)
                                    .background(Color(nsColor: .textBackgroundColor))
                                    .cornerRadius(6)
                                }
                                if matches.count > 100 {
                                    Text("… \(matches.count - 100) more (showing first 100)")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            .padding(.horizontal).padding(.bottom, 12)
                        }
                    }
                }
            }
        }
    }

    func runTest() {
        error = ""
        matches = []
        guard !pattern.isEmpty, !testText.isEmpty else { return }
        var options: NSRegularExpression.Options = []
        if flagCaseInsensitive { options.insert(.caseInsensitive) }
        if flagMultiline       { options.insert(.anchorsMatchLines) }
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: options)
            let nsStr = testText as NSString
            let allMatches = regex.matches(in: testText, range: NSRange(location: 0, length: nsStr.length))
            matches = allMatches.enumerated().map { idx, m in
                let value = nsStr.substring(with: m.range)
                let groups: [String] = (1..<m.numberOfRanges).map { i in
                    let r = m.range(at: i)
                    return r.location != NSNotFound ? nsStr.substring(with: r) : "(no match)"
                }
                return RegexMatch(id: idx, range: "[\(m.range.location)..<\(m.range.location + m.range.length)]",
                                  value: value, groups: groups)
            }
        } catch {
            self.error = "❌ \(error.localizedDescription)"
        }
    }
}

// MARK: - Word & Char Counter

struct WordCharCounterView: View {
    @State private var inputText = ""

    private var wordList: [String] {
        inputText.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
    }
    private var charCount:        Int    { inputText.count }
    private var charsNoSpaces:    Int    { inputText.filter { !$0.isWhitespace }.count }
    private var wordCount:        Int    { wordList.count }
    private var uniqueWordCount:  Int    { Set(wordList.map { $0.lowercased().trimmingCharacters(in: .punctuationCharacters) }).count }
    private var lineCount:        Int    { inputText.isEmpty ? 0 : inputText.components(separatedBy: .newlines).count }
    private var sentenceCount:    Int    { inputText.components(separatedBy: CharacterSet(charactersIn: ".!?")).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count }
    private var paragraphCount:   Int    { inputText.components(separatedBy: "\n\n").filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count }
    private var readingTime:      String {
        guard wordCount > 0 else { return "—" }
        let mins = Double(wordCount) / 200.0
        if mins < 1 { return "<1 min" }
        let m = Int(mins), s = Int((mins - Double(m)) * 60)
        return m >= 60 ? "\(m / 60)h \(m % 60)m" : s == 0 ? "\(m) min" : "\(m) min \(s)s"
    }

    var body: some View {
        VStack(spacing: 0) {
            TextEditor(text: $inputText)
                .font(.system(.body))
                .scrollContentBackground(.hidden)
                .background(Color(nsColor: .textBackgroundColor))
                .padding()

            Divider()

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 0) {
                statCell("Characters",             value: "\(charCount)")
                statCell("Characters (no spaces)", value: "\(charsNoSpaces)")
                statCell("Words",                  value: "\(wordCount)")
                statCell("Unique words",            value: "\(uniqueWordCount)")
                statCell("Lines",                  value: "\(lineCount)")
                statCell("Sentences",              value: "\(sentenceCount)")
                statCell("Paragraphs",             value: "\(paragraphCount)")
                statCell("Reading time",           value: readingTime)
            }
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
        }
    }

    func statCell(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(.title2, design: .monospaced))
                .fontWeight(.semibold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}

// MARK: - Text Diff Viewer

struct TextDiffView: View {
    @State private var originalText = ""
    @State private var modifiedText = ""
    @State private var diffLines: [DiffResult] = []
    @State private var hasDiff = false

    private var addedCount:   Int { diffLines.filter { $0.type == .added }.count }
    private var removedCount: Int { diffLines.filter { $0.type == .removed }.count }

    var body: some View {
        VStack(spacing: 0) {
            // Two input panels
            HSplitView {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Original", systemImage: "doc.text")
                        .font(.subheadline).fontWeight(.medium)
                        .padding(.horizontal).padding(.top, 12)
                    TextEditor(text: $originalText)
                        .font(.system(.body, design: .monospaced))
                        .scrollContentBackground(.hidden)
                        .background(Color(nsColor: .textBackgroundColor))
                        .padding(.horizontal).padding(.bottom, 12)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Label("Modified", systemImage: "doc.text.fill")
                        .font(.subheadline).fontWeight(.medium)
                        .padding(.horizontal).padding(.top, 12)
                    TextEditor(text: $modifiedText)
                        .font(.system(.body, design: .monospaced))
                        .scrollContentBackground(.hidden)
                        .background(Color(nsColor: .textBackgroundColor))
                        .padding(.horizontal).padding(.bottom, 12)
                }
            }
            .frame(maxHeight: 220)

            Divider()

            // Compare button + stats
            HStack(spacing: 16) {
                Button(action: compare) {
                    Label("Compare", systemImage: "doc.text.magnifyingglass")
                        .frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent)

                if hasDiff {
                    Label("+\(addedCount)", systemImage: "plus.circle.fill")
                        .foregroundStyle(.green).font(.callout)
                    Label("-\(removedCount)", systemImage: "minus.circle.fill")
                        .foregroundStyle(.red).font(.callout)
                    Spacer()
                    Button { copyDiff() } label: {
                        Label("Copy diff", systemImage: "doc.on.doc").font(.caption)
                    }.buttonStyle(.bordered)
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))

            Divider()

            // Diff output
            if hasDiff {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(diffLines) { line in
                            HStack(spacing: 0) {
                                Text(line.type == .added ? "+" : line.type == .removed ? "−" : " ")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundStyle(
                                        line.type == .added ? Color.green :
                                        line.type == .removed ? Color.red : Color.secondary
                                    )
                                    .frame(width: 24, alignment: .center)
                                Text(line.text)
                                    .font(.system(.body, design: .monospaced))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .textSelection(.enabled)
                            }
                            .padding(.vertical, 2)
                            .background(
                                line.type == .added   ? Color.green.opacity(0.1) :
                                line.type == .removed ? Color.red.opacity(0.1)   : Color.clear
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .background(Color(nsColor: .textBackgroundColor))
            } else {
                Spacer()
                Text("Paste text in both panels and click Compare")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            }
        }
    }

    func compare() {
        let oldLines = originalText.components(separatedBy: .newlines)
        let newLines = modifiedText.components(separatedBy: .newlines)
        guard oldLines.count <= 500 && newLines.count <= 500 else {
            diffLines = [DiffResult(type: .unchanged, text: "⚠️ Too large for diff (max 500 lines each)")]
            hasDiff = true
            return
        }
        let m = oldLines.count, n = newLines.count
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        for i in 1...m {
            for j in 1...n {
                dp[i][j] = oldLines[i-1] == newLines[j-1]
                    ? dp[i-1][j-1] + 1
                    : max(dp[i-1][j], dp[i][j-1])
            }
        }
        var result: [DiffResult] = []
        var i = m, j = n
        while i > 0 || j > 0 {
            if i > 0 && j > 0 && oldLines[i-1] == newLines[j-1] {
                result.append(DiffResult(type: .unchanged, text: oldLines[i-1]))
                i -= 1; j -= 1
            } else if j > 0 && (i == 0 || dp[i][j-1] >= dp[i-1][j]) {
                result.append(DiffResult(type: .added,   text: newLines[j-1])); j -= 1
            } else {
                result.append(DiffResult(type: .removed, text: oldLines[i-1])); i -= 1
            }
        }
        diffLines = result.reversed()
        hasDiff = true
    }

    func copyDiff() {
        let text = diffLines.map { line in
            let prefix = line.type == .added ? "+ " : line.type == .removed ? "- " : "  "
            return prefix + line.text
        }.joined(separator: "\n")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

// MARK: - Lorem Ipsum Generator

struct LoremIpsumGeneratorView: View {
    @State private var outputType = "paragraphs"
    @State private var count = 3
    @State private var startWithClassic = true
    @State private var outputText = ""

    private let sentences = [
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
        "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
        "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium.",
        "Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit.",
        "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet consectetur adipisci velit.",
        "Ut labore et dolore magnam aliquam quaerat voluptatem enim ad minima veniam.",
        "Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae.",
        "At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium.",
        "Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet.",
        "Nam libero tempore cum soluta nobis est eligendi optio cumque nihil impedit quo minus.",
        "Itaque earum rerum hic tenetur a sapiente delectus ut aut reiciendis voluptatibus maiores.",
        "Quis nostrum exercitationem ullam corporis suscipit laboriosam nisi ut aliquid ex ea commodi.",
        "Praesent in justo consectetur lobortis lobortis rutrum vitae pretium congue.",
        "Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.",
        "Curabitur pretium tincidunt lacus nulla facilisis nibh tincidunt in.",
        "Vivamus eu tortor sed metus malesuada commodo at non nisi.",
        "Aenean luctus lorem ut libero ornare a maximus nisi viverra.",
        "Donec ullamcorper nulla non metus auctor fringilla sed in enim.",
    ]

    private var words: [String] {
        sentences.flatMap { $0.components(separatedBy: .whitespaces) }
            .map { $0.trimmingCharacters(in: .punctuationCharacters).lowercased() }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Generate").font(.caption).foregroundStyle(.secondary)
                        Picker("", selection: $outputType) {
                            Text("Paragraphs").tag("paragraphs")
                            Text("Sentences").tag("sentences")
                            Text("Words").tag("words")
                        }
                        .frame(width: 140)
                        .onChange(of: outputType) { _ in count = outputType == "words" ? 50 : 3; generate() }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Count").font(.caption).foregroundStyle(.secondary)
                        Stepper("\(count)", value: $count, in: 1...(outputType == "words" ? 500 : outputType == "sentences" ? 50 : 20))
                            .onChange(of: count) { _ in generate() }
                    }
                    Toggle("Start with \"Lorem ipsum...\"", isOn: $startWithClassic)
                        .toggleStyle(.checkbox)
                        .onChange(of: startWithClassic) { _ in generate() }
                }
                Button(action: generate) {
                    Label("Generate", systemImage: "text.alignleft").frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Output", systemImage: "doc.text")
                        .font(.subheadline).fontWeight(.medium)
                    Spacer()
                    Button { copy(outputText) } label: {
                        Label("Copy", systemImage: "doc.on.doc").font(.caption)
                    }.buttonStyle(.bordered).disabled(outputText.isEmpty)
                }
                .padding(.horizontal).padding(.top, 12)
                TextEditor(text: .constant(outputText))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .padding(.horizontal).padding(.bottom, 12)
            }
        }
        .onAppear { generate() }
    }

    func generate() {
        let n = max(1, count)
        switch outputType {
        case "paragraphs":
            var paras: [String] = []
            for i in 0..<n {
                let start = (i * 4) % sentences.count
                let para = (0..<5).map { sentences[(start + $0) % sentences.count] }.joined(separator: " ")
                if i == 0 && startWithClassic {
                    paras.append(sentences[0] + " " + sentences[1] + " " + sentences[2] + " " + sentences[3])
                } else {
                    paras.append(para)
                }
            }
            outputText = paras.joined(separator: "\n\n")

        case "sentences":
            var result: [String] = []
            if startWithClassic { result.append(sentences[0]) }
            let offset = startWithClassic ? 1 : 0
            let remaining = max(0, n - (startWithClassic ? 1 : 0))
            for i in 0..<remaining {
                result.append(sentences[(offset + i) % sentences.count])
            }
            outputText = result.joined(separator: " ")

        case "words":
            let pool = words
            var result: [String] = []
            if startWithClassic {
                result = ["Lorem", "ipsum", "dolor", "sit", "amet,", "consectetur", "adipiscing", "elit."]
            }
            let remaining = max(0, n - result.count)
            for i in 0..<remaining {
                result.append(pool[i % pool.count])
            }
            outputText = result.prefix(n).joined(separator: " ")

        default: break
        }
    }

    func copy(_ s: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(s, forType: .string)
    }
}

// MARK: - Slug Generator

struct SlugGeneratorView: View {
    @State private var inputText = ""
    @State private var outputText = ""
    @State private var separator = "-"
    @State private var forceLowercase = true

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Label("Input", systemImage: "square.and.pencil")
                    .font(.subheadline).fontWeight(.medium)
                    .padding(.horizontal).padding(.top, 12)
                TextEditor(text: $inputText)
                    .font(.system(.body))
                    .frame(height: 100)
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal).padding(.bottom, 8)
                    .onChange(of: inputText) { _ in generateSlug() }
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Separator").font(.caption).foregroundStyle(.secondary)
                        Picker("", selection: $separator) {
                            Text("Hyphen  (-)").tag("-")
                            Text("Underscore  (_)").tag("_")
                        }
                        .frame(width: 170)
                        .onChange(of: separator) { _ in generateSlug() }
                    }
                    Toggle("Lowercase", isOn: $forceLowercase)
                        .toggleStyle(.checkbox)
                        .onChange(of: forceLowercase) { _ in generateSlug() }
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Slug", systemImage: "link")
                        .font(.subheadline).fontWeight(.medium)
                    Spacer()
                    Button { copy(outputText) } label: {
                        Label("Copy", systemImage: "doc.on.doc").font(.caption)
                    }.buttonStyle(.bordered).disabled(outputText.isEmpty)
                }
                .padding(.horizontal).padding(.top, 12)

                Text(outputText.isEmpty ? "Slug will appear here…" : outputText)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(outputText.isEmpty ? .secondary : .primary)
                    .textSelection(.enabled)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }

            Spacer()
        }
    }

    func generateSlug() {
        var result = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        // Remove diacritics (é→e, ü→u, etc.)
        result = result.folding(options: .diacriticInsensitive, locale: .current)
        if forceLowercase { result = result.lowercased() }
        // Keep only ASCII alphanumeric + whitespace + existing separators
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 \t_-")
        result = result.unicodeScalars.filter { allowed.contains($0) }.map { String($0) }.joined()
        // Collapse whitespace/separators into the chosen separator
        result = result
            .components(separatedBy: CharacterSet.whitespaces.union(CharacterSet(charactersIn: "_-")))
            .filter { !$0.isEmpty }
            .joined(separator: separator)
        outputText = result
    }

    func copy(_ s: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(s, forType: .string)
    }
}

// MARK: - JSON Escape / Unescape

struct JSONEscapeUnescapeView: View {
    @State private var inputText = ""
    @State private var outputText = ""
    @State private var wrapInQuotes = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Input", systemImage: "square.and.pencil")
                        .font(.subheadline).fontWeight(.medium)
                    Spacer()
                    Text("\(inputText.count) chars").font(.caption).foregroundStyle(.secondary)
                }
                .padding(.horizontal).padding(.top, 12)
                TextEditor(text: $inputText)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal).padding(.bottom, 8)
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Toggle("Wrap escaped output in quotes", isOn: $wrapInQuotes).toggleStyle(.checkbox)
                HStack(spacing: 8) {
                    Button(action: escapeJSON) {
                        Label("Escape →", systemImage: "arrow.right.square").frame(maxWidth: .infinity)
                    }.buttonStyle(.borderedProminent)
                    Button(action: unescapeJSON) {
                        Label("← Unescape", systemImage: "arrow.left.square").frame(maxWidth: .infinity)
                    }.buttonStyle(.bordered)
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Output", systemImage: "doc.text")
                        .font(.subheadline).fontWeight(.medium)
                    Spacer()
                    Text("\(outputText.count) chars").font(.caption).foregroundStyle(.secondary)
                    Button { copy(outputText) } label: {
                        Label("Copy", systemImage: "doc.on.doc").font(.caption)
                    }.buttonStyle(.bordered).disabled(outputText.isEmpty)
                }
                .padding(.horizontal).padding(.top, 12)
                TextEditor(text: .constant(outputText))
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal).padding(.bottom, 12)
            }
        }
    }

    func escapeJSON() {
        var r = inputText
        r = r.replacingOccurrences(of: "\\",    with: "\\\\")
        r = r.replacingOccurrences(of: "\"",    with: "\\\"")
        r = r.replacingOccurrences(of: "\n",    with: "\\n")
        r = r.replacingOccurrences(of: "\r",    with: "\\r")
        r = r.replacingOccurrences(of: "\t",    with: "\\t")
        r = r.replacingOccurrences(of: "\u{08}", with: "\\b")
        r = r.replacingOccurrences(of: "\u{0C}", with: "\\f")
        outputText = wrapInQuotes ? "\"\(r)\"" : r
    }

    func unescapeJSON() {
        var input = inputText
        // Strip surrounding quotes if user pasted a full JSON string literal
        if input.hasPrefix("\"") && input.hasSuffix("\"") && input.count >= 2 {
            input = String(input.dropFirst().dropLast())
        }
        // Let JSONSerialization handle all escape sequences correctly
        let jsonLiteral = "\"\(input)\""
        if let data = jsonLiteral.data(using: .utf8),
           let parsed = try? JSONSerialization.jsonObject(with: data) as? String {
            outputText = parsed
        } else {
            // Fallback: manual character-by-character unescape
            outputText = manualUnescape(input)
        }
    }

    func manualUnescape(_ s: String) -> String {
        var result = ""
        var i = s.startIndex
        while i < s.endIndex {
            if s[i] == "\\" {
                let next = s.index(after: i)
                if next < s.endIndex {
                    switch s[next] {
                    case "n":  result.append("\n")
                    case "r":  result.append("\r")
                    case "t":  result.append("\t")
                    case "b":  result.append("\u{08}")
                    case "f":  result.append("\u{0C}")
                    case "\"": result.append("\"")
                    case "/":  result.append("/")
                    case "\\": result.append("\\")
                    default:   result.append("\\"); result.append(s[next])
                    }
                    i = s.index(after: next)
                } else {
                    result.append(s[i])
                    i = s.index(after: i)
                }
            } else {
                result.append(s[i])
                i = s.index(after: i)
            }
        }
        return result
    }

    func copy(_ s: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(s, forType: .string)
    }
}
