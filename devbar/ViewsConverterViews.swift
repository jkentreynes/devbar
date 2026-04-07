//
//  ViewsConverterViews.swift
//  devbar
//
//  Created by John Kent Reynes on 4/6/26.
//

import SwiftUI

// MARK: - XML Parser Delegate (shared by XML ↔ JSON)

private class XMLJSONDelegate: NSObject, XMLParserDelegate {
    typealias Elem = (tag: String, attrs: [String: String], children: [(String, Any)], text: String)
    var stack: [Elem] = []
    var root: (String, Any)?
    var parseError: Error?

    func parserDidStartDocument(_ parser: XMLParser) { stack = [] }

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName: String?,
                attributes attributeDict: [String: String]) {
        stack.append((tag: elementName, attrs: attributeDict, children: [], text: ""))
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard !stack.isEmpty else { return }
        let s = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !s.isEmpty { stack[stack.count - 1].text += s }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName: String?) {
        guard let top = stack.popLast() else { return }
        let value = buildValue(top)
        if stack.isEmpty {
            root = (elementName, value)
        } else {
            stack[stack.count - 1].children.append((elementName, value))
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred error: Error) {
        parseError = error
    }

    private func buildValue(_ elem: Elem) -> Any {
        // Pure text-only node
        if elem.attrs.isEmpty && elem.children.isEmpty {
            return elem.text.isEmpty ? "" : inferType(elem.text)
        }
        var obj: [String: Any] = [:]
        for (k, v) in elem.attrs { obj["@\(k)"] = v }
        if !elem.text.isEmpty { obj["#text"] = inferType(elem.text) }
        for (childTag, childValue) in elem.children {
            if let existing = obj[childTag] {
                if var arr = existing as? [Any] { arr.append(childValue); obj[childTag] = arr }
                else { obj[childTag] = [existing, childValue] }
            } else {
                obj[childTag] = childValue
            }
        }
        return obj
    }

    private func inferType(_ s: String) -> Any {
        if s.lowercased() == "true" { return true }
        if s.lowercased() == "false" { return false }
        if let i = Int(s) { return i }
        if let d = Double(s) { return d }
        return s
    }
}

// MARK: - JSON ↔ YAML

struct JSONYAMLConverterView: View {
    @State private var jsonText = ""
    @State private var yamlText = ""

    var body: some View {
        HSplitView {
            // JSON side
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("JSON", systemImage: "curlybraces")
                        .font(.subheadline).fontWeight(.medium)
                    Spacer()
                    Button { copy(jsonText) } label: {
                        Label("Copy", systemImage: "doc.on.doc").font(.caption)
                    }.buttonStyle(.bordered).disabled(jsonText.isEmpty)
                }
                .padding(.horizontal).padding(.top, 12)

                TextEditor(text: $jsonText)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .padding(.horizontal)

                Button(action: convertJSONtoYAML) {
                    Label("JSON → YAML", systemImage: "arrow.right").frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent)
                .padding(.horizontal).padding(.bottom, 12)
            }

            // YAML side
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("YAML", systemImage: "doc.plaintext")
                        .font(.subheadline).fontWeight(.medium)
                    Spacer()
                    Button { copy(yamlText) } label: {
                        Label("Copy", systemImage: "doc.on.doc").font(.caption)
                    }.buttonStyle(.bordered).disabled(yamlText.isEmpty)
                }
                .padding(.horizontal).padding(.top, 12)

                TextEditor(text: $yamlText)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .padding(.horizontal)

                Button(action: convertYAMLtoJSON) {
                    Label("← YAML → JSON", systemImage: "arrow.left").frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent)
                .padding(.horizontal).padding(.bottom, 12)
            }
        }
    }

    // MARK: JSON → YAML

    func convertJSONtoYAML() {
        guard let data = jsonText.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) else {
            yamlText = "❌ Invalid JSON"
            return
        }
        yamlText = toYAML(obj)
    }

    func toYAML(_ value: Any, indent: Int = 0) -> String {
        let pad = String(repeating: "  ", count: indent)
        if let dict = value as? [String: Any] {
            guard !dict.isEmpty else { return "{}" }
            return dict.sorted { $0.key < $1.key }.map { k, v in
                if v is [String: Any] || v is [Any] {
                    return "\(pad)\(k):\n\(toYAML(v, indent: indent + 1))"
                }
                return "\(pad)\(k): \(yamlScalar(v))"
            }.joined(separator: "\n")
        }
        if let arr = value as? [Any] {
            guard !arr.isEmpty else { return "\(pad)[]" }
            return arr.map { item -> String in
                if let dict = item as? [String: Any], !dict.isEmpty {
                    let sorted = dict.sorted { $0.key < $1.key }
                    var lines: [String] = []
                    let first = sorted[0]
                    if first.value is [String: Any] || first.value is [Any] {
                        lines.append("\(pad)- \(first.key):")
                        lines.append(toYAML(first.value, indent: indent + 1))
                    } else {
                        lines.append("\(pad)- \(first.key): \(yamlScalar(first.value))")
                    }
                    for pair in sorted.dropFirst() {
                        if pair.value is [String: Any] || pair.value is [Any] {
                            lines.append("\(pad)  \(pair.key):")
                            lines.append(toYAML(pair.value, indent: indent + 1))
                        } else {
                            lines.append("\(pad)  \(pair.key): \(yamlScalar(pair.value))")
                        }
                    }
                    return lines.joined(separator: "\n")
                }
                return "\(pad)- \(yamlScalar(item))"
            }.joined(separator: "\n")
        }
        return yamlScalar(value)
    }

    func yamlScalar(_ value: Any) -> String {
        if value is NSNull { return "null" }
        if let b = value as? Bool { return b ? "true" : "false" }
        if let n = value as? NSNumber { return n.stringValue }
        if let s = value as? String {
            let reserved = ["true", "false", "null", "~", "yes", "no", "on", "off"]
            let needsQuoting = s.isEmpty || reserved.contains(s.lowercased()) ||
                s.hasPrefix(" ") || s.hasSuffix(" ") || s.contains(": ") ||
                s.contains(" #") || s.contains("\n") || s.contains("'") ||
                Double(s) != nil || s.hasPrefix("{") || s.hasPrefix("[")
            return needsQuoting ? "'\(s.replacingOccurrences(of: "'", with: "''"))'" : s
        }
        return "\(value)"
    }

    // MARK: YAML → JSON

    func convertYAMLtoJSON() {
        guard let obj = parseYAML(yamlText) else {
            jsonText = "❌ Could not parse YAML"
            return
        }
        guard let data = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys]),
              let str = String(data: data, encoding: .utf8) else {
            jsonText = "❌ Could not serialize to JSON"
            return
        }
        jsonText = str
    }

    func parseYAML(_ text: String) -> Any? {
        let lines = text.components(separatedBy: .newlines).compactMap { line -> (indent: Int, text: String)? in
            let t = line.trimmingCharacters(in: .whitespaces)
            guard !t.isEmpty, !t.hasPrefix("#") else { return nil }
            return (line.prefix(while: { $0 == " " }).count, t)
        }
        guard !lines.isEmpty else { return nil }
        var idx = 0
        return parseYAMLNode(lines, &idx)
    }

    func parseYAMLNode(_ lines: [(indent: Int, text: String)], _ idx: inout Int) -> Any? {
        guard idx < lines.count else { return nil }
        let line = lines[idx]
        if line.text.hasPrefix("- ") || line.text == "-" {
            return parseYAMLSeq(lines, &idx, line.indent)
        }
        return parseYAMLMap(lines, &idx, line.indent)
    }

    func parseYAMLSeq(_ lines: [(indent: Int, text: String)], _ idx: inout Int, _ seqIndent: Int) -> [Any] {
        var arr: [Any] = []
        while idx < lines.count && lines[idx].indent == seqIndent {
            let t = lines[idx].text
            guard t.hasPrefix("- ") || t == "-" else { break }
            let rest = t == "-" ? "" : String(t.dropFirst(2)).trimmingCharacters(in: .whitespaces)
            idx += 1

            if rest.isEmpty {
                if idx < lines.count && lines[idx].indent > seqIndent {
                    if let val = parseYAMLNode(lines, &idx) { arr.append(val) }
                }
            } else if isKV(rest) {
                var dict: [String: Any] = [:]
                addKV(rest, to: &dict)
                while idx < lines.count && lines[idx].indent > seqIndent {
                    let child = lines[idx]
                    if child.text.hasPrefix("- ") { break }
                    if child.text.hasSuffix(":") {
                        let k = String(child.text.dropLast())
                        idx += 1
                        if idx < lines.count && lines[idx].indent > child.indent {
                            dict[k] = parseYAMLNode(lines, &idx)
                        } else {
                            dict[k] = NSNull()
                        }
                    } else if isKV(child.text) {
                        addKV(child.text, to: &dict)
                        idx += 1
                    } else { break }
                }
                arr.append(dict)
            } else {
                arr.append(yamlVal(rest))
            }
        }
        return arr
    }

    func parseYAMLMap(_ lines: [(indent: Int, text: String)], _ idx: inout Int, _ mapIndent: Int) -> [String: Any] {
        var dict: [String: Any] = [:]
        while idx < lines.count && lines[idx].indent == mapIndent {
            let t = lines[idx].text
            if t.hasPrefix("- ") { break }
            if t.hasSuffix(":") {
                let k = String(t.dropLast())
                idx += 1
                if idx < lines.count && lines[idx].indent > mapIndent {
                    dict[k] = parseYAMLNode(lines, &idx)
                } else {
                    dict[k] = NSNull()
                }
            } else if isKV(t) {
                addKV(t, to: &dict)
                idx += 1
            } else { idx += 1 }
        }
        return dict
    }

    func isKV(_ t: String) -> Bool { t.contains(": ") || t.hasSuffix(":") }

    func addKV(_ t: String, to dict: inout [String: Any]) {
        guard let range = t.range(of: ": ") else { return }
        let k = String(t[..<range.lowerBound])
        let v = String(t[range.upperBound...])
        dict[k] = yamlVal(v)
    }

    func yamlVal(_ s: String) -> Any {
        if s == "null" || s == "~" || s == "" { return NSNull() }
        if s.lowercased() == "true" { return true }
        if s.lowercased() == "false" { return false }
        if let i = Int(s) { return i }
        if let d = Double(s) { return d }
        if (s.hasPrefix("\"") && s.hasSuffix("\"")) || (s.hasPrefix("'") && s.hasSuffix("'")) {
            return String(s.dropFirst().dropLast())
        }
        return s
    }

    func copy(_ s: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(s, forType: .string)
    }
}

// MARK: - XML ↔ JSON

struct XMLJSONConverterView: View {
    @State private var xmlText = ""
    @State private var jsonText = ""
    @State private var rootTagName = "root"

    var body: some View {
        HSplitView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("XML", systemImage: "chevron.left.forwardslash.chevron.right")
                        .font(.subheadline).fontWeight(.medium)
                    Spacer()
                    Button { copy(xmlText) } label: {
                        Label("Copy", systemImage: "doc.on.doc").font(.caption)
                    }.buttonStyle(.bordered).disabled(xmlText.isEmpty)
                }
                .padding(.horizontal).padding(.top, 12)

                TextEditor(text: $xmlText)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .padding(.horizontal)

                Button(action: convertXMLtoJSON) {
                    Label("XML → JSON", systemImage: "arrow.right").frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent)
                .padding(.horizontal).padding(.bottom, 12)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("JSON", systemImage: "curlybraces")
                        .font(.subheadline).fontWeight(.medium)
                    Spacer()
                    HStack(spacing: 4) {
                        Text("Root tag:").font(.caption).foregroundStyle(.secondary)
                        TextField("root", text: $rootTagName)
                            .textFieldStyle(.roundedBorder).frame(width: 80).font(.caption)
                    }
                    Button { copy(jsonText) } label: {
                        Label("Copy", systemImage: "doc.on.doc").font(.caption)
                    }.buttonStyle(.bordered).disabled(jsonText.isEmpty)
                }
                .padding(.horizontal).padding(.top, 12)

                TextEditor(text: $jsonText)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .padding(.horizontal)

                Button(action: convertJSONtoXML) {
                    Label("← JSON → XML", systemImage: "arrow.left").frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent)
                .padding(.horizontal).padding(.bottom, 12)
            }
        }
    }

    func convertXMLtoJSON() {
        guard let data = xmlText.data(using: .utf8) else { jsonText = "❌ Encoding error"; return }
        let delegate = XMLJSONDelegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        guard parser.parse(), let (_, value) = delegate.root else {
            jsonText = "❌ Invalid XML\(delegate.parseError.map { ": \($0.localizedDescription)" } ?? "")"
            return
        }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted]),
              let str = String(data: jsonData, encoding: .utf8) else {
            jsonText = "❌ Could not serialize JSON"
            return
        }
        jsonText = str
    }

    func convertJSONtoXML() {
        guard let data = jsonText.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) else {
            xmlText = "❌ Invalid JSON"
            return
        }
        let tag = rootTagName.isEmpty ? "root" : rootTagName
        xmlText = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + jsonToXML(obj, tag: tag)
    }

    func jsonToXML(_ value: Any, tag: String, indent: Int = 0) -> String {
        let pad = String(repeating: "  ", count: indent)
        let safeTag = tag.isEmpty ? "item" : tag.replacingOccurrences(of: " ", with: "_")

        if let dict = value as? [String: Any] {
            var attrStr = ""
            var childStr = ""
            var textStr = ""
            for (k, v) in dict.sorted(by: { $0.key < $1.key }) {
                if k.hasPrefix("@") {
                    attrStr += " \(k.dropFirst())=\"\(v)\""
                } else if k == "#text" {
                    textStr = "\(v)"
                } else {
                    childStr += jsonToXML(v, tag: k, indent: indent + 1)
                }
            }
            if childStr.isEmpty && textStr.isEmpty { return "\(pad)<\(safeTag)\(attrStr)/>\n" }
            if childStr.isEmpty { return "\(pad)<\(safeTag)\(attrStr)>\(textStr)</\(safeTag)>\n" }
            return "\(pad)<\(safeTag)\(attrStr)>\n\(childStr)\(pad)</\(safeTag)>\n"
        }
        if let arr = value as? [Any] {
            return arr.map { jsonToXML($0, tag: safeTag, indent: indent) }.joined()
        }
        if value is NSNull { return "\(pad)<\(safeTag)/>\n" }
        return "\(pad)<\(safeTag)>\(value)</\(safeTag)>\n"
    }

    func copy(_ s: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(s, forType: .string)
    }
}

// MARK: - JSON ↔ CSV

struct JSONCSVConverterView: View {
    @State private var jsonText = ""
    @State private var csvText = ""

    var body: some View {
        HSplitView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("JSON (array of objects)", systemImage: "curlybraces")
                        .font(.subheadline).fontWeight(.medium)
                    Spacer()
                    Button { copy(jsonText) } label: {
                        Label("Copy", systemImage: "doc.on.doc").font(.caption)
                    }.buttonStyle(.bordered).disabled(jsonText.isEmpty)
                }
                .padding(.horizontal).padding(.top, 12)

                TextEditor(text: $jsonText)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .padding(.horizontal)

                Button(action: convertJSONtoCSV) {
                    Label("JSON → CSV", systemImage: "arrow.right").frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent)
                .padding(.horizontal).padding(.bottom, 12)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("CSV", systemImage: "tablecells")
                        .font(.subheadline).fontWeight(.medium)
                    Spacer()
                    Button { copy(csvText) } label: {
                        Label("Copy", systemImage: "doc.on.doc").font(.caption)
                    }.buttonStyle(.bordered).disabled(csvText.isEmpty)
                }
                .padding(.horizontal).padding(.top, 12)

                TextEditor(text: $csvText)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .padding(.horizontal)

                Button(action: convertCSVtoJSON) {
                    Label("← CSV → JSON", systemImage: "arrow.left").frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent)
                .padding(.horizontal).padding(.bottom, 12)
            }
        }
    }

    func convertJSONtoCSV() {
        guard let data = jsonText.data(using: .utf8),
              let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            csvText = "❌ Input must be a JSON array of objects"
            return
        }
        guard !arr.isEmpty else { csvText = ""; return }

        var headers: [String] = []
        var seen = Set<String>()
        for obj in arr {
            for k in obj.keys where seen.insert(k).inserted { headers.append(k) }
        }

        var rows: [String] = [headers.map(csvEscape).joined(separator: ",")]
        for obj in arr {
            rows.append(headers.map { k -> String in
                guard let v = obj[k] else { return "" }
                return v is NSNull ? "" : csvEscape("\(v)")
            }.joined(separator: ","))
        }
        csvText = rows.joined(separator: "\n")
    }

    func convertCSVtoJSON() {
        let rows = parseCSVRows(csvText)
        guard rows.count > 1 else {
            jsonText = "❌ Need a header row and at least one data row"
            return
        }
        let headers = rows[0]
        let objects: [[String: Any]] = rows.dropFirst().compactMap { row -> [String: Any]? in
            guard !row.allSatisfy({ $0.isEmpty }) else { return nil }
            var obj: [String: Any] = [:]
            for (i, h) in headers.enumerated() {
                let v = i < row.count ? row[i] : ""
                if let n = Int(v) { obj[h] = n }
                else if let d = Double(v) { obj[h] = d }
                else if v.lowercased() == "true" { obj[h] = true }
                else if v.lowercased() == "false" { obj[h] = false }
                else if v.isEmpty { obj[h] = NSNull() }
                else { obj[h] = v }
            }
            return obj
        }
        guard let data = try? JSONSerialization.data(withJSONObject: objects, options: [.prettyPrinted]),
              let str = String(data: data, encoding: .utf8) else {
            jsonText = "❌ Serialization failed"
            return
        }
        jsonText = str
    }

    func csvEscape(_ s: String) -> String {
        guard s.contains(",") || s.contains("\"") || s.contains("\n") else { return s }
        return "\"" + s.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }

    func parseCSVRows(_ csv: String) -> [[String]] {
        var rows: [[String]] = []
        var current: [String] = []
        var cell = ""
        var inQuotes = false
        for char in csv {
            if char == "\"" { inQuotes.toggle() }
            else if char == "," && !inQuotes { current.append(cell.trimmingCharacters(in: .whitespaces)); cell = "" }
            else if char == "\n" && !inQuotes {
                current.append(cell.trimmingCharacters(in: .whitespaces))
                rows.append(current); current = []; cell = ""
            } else { cell.append(char) }
        }
        if !cell.isEmpty || !current.isEmpty {
            current.append(cell.trimmingCharacters(in: .whitespaces))
            rows.append(current)
        }
        return rows.filter { !$0.allSatisfy({ $0.isEmpty }) }
    }

    func copy(_ s: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(s, forType: .string)
    }
}

// MARK: - Number Base Converter

struct NumberBaseConverterView: View {
    @State private var inputValue = ""
    @State private var inputBase = 10
    @State private var results: [(label: String, prefix: String, value: String)] = []
    @State private var error = ""

    private let bases = [("Binary", 2), ("Octal", 8), ("Decimal", 10), ("Hexadecimal", 16)]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Label("Input", systemImage: "number.square")
                    .font(.subheadline).fontWeight(.medium)

                HStack(spacing: 8) {
                    TextField("Enter number…", text: $inputValue)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))

                    Picker("Base", selection: $inputBase) {
                        ForEach(bases, id: \.1) { name, radix in
                            Text(name).tag(radix)
                        }
                    }
                    .frame(width: 140)

                    Button("Convert", action: convert)
                        .buttonStyle(.borderedProminent)
                }

                if !error.isEmpty {
                    Text(error).foregroundStyle(.red).font(.caption)
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))

            Divider()

            if !results.isEmpty {
                VStack(spacing: 0) {
                    ForEach(results, id: \.label) { row in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(row.label).font(.subheadline).foregroundStyle(.secondary)
                                Text(row.prefix).font(.caption2).foregroundStyle(.tertiary)
                            }
                            .frame(width: 140, alignment: .leading)

                            Spacer()

                            Text(row.value)
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.semibold)
                                .textSelection(.enabled)

                            Button { copy(row.prefix + row.value) } label: {
                                Image(systemName: "doc.on.doc").font(.caption)
                            }.buttonStyle(.borderless)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        Divider()
                    }
                }
            }

            Spacer()
        }
    }

    func convert() {
        error = ""
        results = []
        let clean = inputValue.trimmingCharacters(in: .whitespaces)
        guard !clean.isEmpty else { return }

        // Strip common prefixes
        var stripped = clean.lowercased()
        if inputBase == 16 && stripped.hasPrefix("0x") { stripped = String(stripped.dropFirst(2)) }
        if inputBase == 8  && stripped.hasPrefix("0o") { stripped = String(stripped.dropFirst(2)) }
        if inputBase == 2  && stripped.hasPrefix("0b") { stripped = String(stripped.dropFirst(2)) }

        guard let value = UInt64(stripped, radix: inputBase) else {
            let baseName = bases.first(where: { $0.1 == inputBase })?.0 ?? "base-\(inputBase)"
            error = "❌ '\(clean)' is not a valid \(baseName) number"
            return
        }

        results = [
            ("Binary",      "0b", String(value, radix: 2)),
            ("Octal",       "0o", String(value, radix: 8)),
            ("Decimal",     "",   String(value, radix: 10)),
            ("Hexadecimal", "0x", String(value, radix: 16).uppercased()),
        ]
    }

    func copy(_ s: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(s, forType: .string)
    }
}

// MARK: - Unix Timestamp Converter

struct UnixTimestampConverterView: View {
    @State private var timestampInput = ""
    @State private var dateInput = ""
    @State private var dateResults: [String] = []
    @State private var timestampResult = ""
    @State private var tsError = ""
    @State private var dateError = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Current timestamp banner
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Current Unix Timestamp").font(.caption).foregroundStyle(.secondary)
                        Text("\(Int(Date().timeIntervalSince1970))")
                            .font(.system(.body, design: .monospaced)).fontWeight(.semibold)
                    }
                    Spacer()
                    Button("Use Now") {
                        timestampInput = "\(Int(Date().timeIntervalSince1970))"
                        convertTimestamp()
                    }.buttonStyle(.bordered)
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))

                Divider()

                // Timestamp → Date
                VStack(alignment: .leading, spacing: 10) {
                    Label("Unix Timestamp → Date", systemImage: "arrow.right")
                        .font(.subheadline).fontWeight(.medium)

                    HStack {
                        TextField("e.g. 1712345678 or 1712345678000", text: $timestampInput)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                        Button("Convert", action: convertTimestamp).buttonStyle(.borderedProminent)
                    }

                    if !tsError.isEmpty {
                        Text(tsError).foregroundStyle(.red).font(.caption)
                    }

                    if !dateResults.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(dateResults, id: \.self) { line in
                                HStack {
                                    Text(line).font(.system(.caption, design: .monospaced))
                                    Spacer()
                                }
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                Divider()
                            }
                        }
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(6)
                    }
                }
                .padding()

                Divider()

                // Date → Timestamp
                VStack(alignment: .leading, spacing: 10) {
                    Label("Date → Unix Timestamp", systemImage: "arrow.left")
                        .font(.subheadline).fontWeight(.medium)
                    Text("Formats: yyyy-MM-dd HH:mm:ss  •  yyyy-MM-dd  •  ISO 8601")
                        .font(.caption).foregroundStyle(.secondary)

                    HStack {
                        TextField("e.g. 2024-04-05 12:00:00", text: $dateInput)
                            .textFieldStyle(.roundedBorder)
                        Button("Convert", action: convertDate).buttonStyle(.borderedProminent)
                    }

                    if !dateError.isEmpty {
                        Text(dateError).foregroundStyle(.red).font(.caption)
                    }

                    if !timestampResult.isEmpty {
                        HStack {
                            Text(timestampResult)
                                .font(.system(.body, design: .monospaced)).fontWeight(.semibold)
                            Button { copy(timestampResult) } label: {
                                Image(systemName: "doc.on.doc").font(.caption)
                            }.buttonStyle(.borderless)
                        }
                        .padding()
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(6)
                    }
                }
                .padding()
            }
        }
    }

    func convertTimestamp() {
        tsError = ""
        dateResults = []
        let clean = timestampInput.trimmingCharacters(in: .whitespaces)
        guard let ts = Double(clean) else { tsError = "❌ Invalid timestamp"; return }

        // Auto-detect ms vs s (ms timestamps are > ~year 2001 boundary)
        let seconds = ts > 1_000_000_0000 ? ts / 1000 : ts
        let date = Date(timeIntervalSince1970: seconds)
        let isMs = ts > 1_000_000_0000

        let formats: [(String, String, String)] = [
            ("ISO 8601 (UTC)",  "yyyy-MM-dd'T'HH:mm:ss'Z'", "UTC"),
            ("RFC 2822",        "EEE, dd MMM yyyy HH:mm:ss zzz", "UTC"),
            ("Date (UTC)",      "yyyy-MM-dd", "UTC"),
            ("Time (UTC)",      "HH:mm:ss", "UTC"),
            ("Local",           "yyyy-MM-dd HH:mm:ss zzz", TimeZone.current.identifier),
            ("Day of week",     "EEEE", "UTC"),
        ]

        dateResults = formats.map { label, fmt, tz in
            let f = DateFormatter()
            f.dateFormat = fmt
            f.timeZone = TimeZone(identifier: tz)
            return "\(label): \(f.string(from: date))"
        }

        if isMs { dateResults.insert("ℹ️ Detected milliseconds — converted to seconds", at: 0) }
    }

    func convertDate() {
        dateError = ""
        timestampResult = ""
        let clean = dateInput.trimmingCharacters(in: .whitespaces)
        let formats = [
            ("yyyy-MM-dd'T'HH:mm:ssZ",  nil as String?),
            ("yyyy-MM-dd'T'HH:mm:ss",   "UTC"),
            ("yyyy-MM-dd HH:mm:ss",      "UTC"),
            ("yyyy-MM-dd HH:mm",         "UTC"),
            ("yyyy-MM-dd",               "UTC"),
            ("MM/dd/yyyy HH:mm:ss",      "UTC"),
            ("MM/dd/yyyy",               "UTC"),
        ]
        for (fmt, tz) in formats {
            let f = DateFormatter()
            f.dateFormat = fmt
            if let tz { f.timeZone = TimeZone(identifier: tz) }
            if let date = f.date(from: clean) {
                timestampResult = "\(Int(date.timeIntervalSince1970))"
                return
            }
        }
        dateError = "❌ Could not parse date. Try: yyyy-MM-dd HH:mm:ss"
    }

    func copy(_ s: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(s, forType: .string)
    }
}

// MARK: - Color Converter

struct ColorConverterView: View {
    @State private var hexInput = "#3B82F6"
    @State private var rInput = "59"
    @State private var gInput = "130"
    @State private var bInput = "246"
    @State private var hInput = "217"
    @State private var sInput = "91"
    @State private var lInput = "60"
    @State private var previewColor: Color = Color(red: 59/255, green: 130/255, blue: 246/255)
    @State private var error = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Color preview
                RoundedRectangle(cornerRadius: 12)
                    .fill(previewColor)
                    .frame(height: 80)
                    .padding()

                Divider()

                // HEX
                colorRow(label: "HEX", systemImage: "number") {
                    HStack {
                        TextField("#RRGGBB", text: $hexInput)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                        Button("Apply") { fromHEX() }.buttonStyle(.borderedProminent)
                        copyBtn(hexInput)
                    }
                }

                Divider()

                // RGB
                colorRow(label: "RGB", systemImage: "slider.horizontal.3") {
                    HStack(spacing: 8) {
                        numField("R", $rInput)
                        numField("G", $gInput)
                        numField("B", $bInput)
                        Button("Apply") { fromRGB() }.buttonStyle(.borderedProminent)
                        copyBtn("rgb(\(rInput), \(gInput), \(bInput))")
                    }
                }

                Divider()

                // HSL
                colorRow(label: "HSL", systemImage: "paintpalette") {
                    HStack(spacing: 8) {
                        numField("H°", $hInput)
                        numField("S%", $sInput)
                        numField("L%", $lInput)
                        Button("Apply") { fromHSL() }.buttonStyle(.borderedProminent)
                        copyBtn("hsl(\(hInput), \(sInput)%, \(lInput)%)")
                    }
                }

                if !error.isEmpty {
                    Text(error).foregroundStyle(.red).font(.caption).padding()
                }

                Spacer()
            }
        }
    }

    @ViewBuilder
    func colorRow<C: View>(label: String, systemImage: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: systemImage).font(.subheadline).fontWeight(.medium)
            content()
        }
        .padding()
    }

    func numField(_ label: String, _ text: Binding<String>) -> some View {
        VStack(spacing: 2) {
            Text(label).font(.caption2).foregroundStyle(.secondary)
            TextField("0", text: text)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))
                .frame(width: 58)
        }
    }

    func copyBtn(_ text: String) -> some View {
        Button { copy(text) } label: {
            Image(systemName: "doc.on.doc").font(.caption)
        }.buttonStyle(.borderless)
    }

    func fromHEX() {
        error = ""
        var hex = hexInput.trimmingCharacters(in: .whitespaces)
        if hex.hasPrefix("#") { hex = String(hex.dropFirst()) }
        if hex.count == 3 { hex = hex.map { "\($0)\($0)" }.joined() }
        guard hex.count == 6, let v = UInt64(hex, radix: 16) else {
            error = "❌ Invalid HEX. Use #RGB or #RRGGBB"
            return
        }
        let r = Int((v >> 16) & 0xFF), g = Int((v >> 8) & 0xFF), b = Int(v & 0xFF)
        rInput = "\(r)"; gInput = "\(g)"; bInput = "\(b)"
        updateHSL(r: r, g: g, b: b)
        updatePreview(r: r, g: g, b: b)
    }

    func fromRGB() {
        error = ""
        guard let r = Int(rInput), let g = Int(gInput), let b = Int(bInput),
              (0...255).contains(r), (0...255).contains(g), (0...255).contains(b) else {
            error = "❌ RGB values must each be 0–255"
            return
        }
        hexInput = "#" + [r, g, b].map { String(format: "%02X", $0) }.joined()
        updateHSL(r: r, g: g, b: b)
        updatePreview(r: r, g: g, b: b)
    }

    func fromHSL() {
        error = ""
        guard let h = Double(hInput), let s = Double(sInput), let l = Double(lInput),
              (0...360).contains(h), (0...100).contains(s), (0...100).contains(l) else {
            error = "❌ H: 0–360, S/L: 0–100"
            return
        }
        let (r, g, b) = hslToRGB(h: h, s: s / 100, l: l / 100)
        rInput = "\(r)"; gInput = "\(g)"; bInput = "\(b)"
        hexInput = "#" + [r, g, b].map { String(format: "%02X", $0) }.joined()
        updatePreview(r: r, g: g, b: b)
    }

    func updateHSL(r: Int, g: Int, b: Int) {
        let rf = Double(r) / 255, gf = Double(g) / 255, bf = Double(b) / 255
        let mx = max(rf, gf, bf), mn = min(rf, gf, bf)
        let l = (mx + mn) / 2
        var h = 0.0, s = 0.0
        if mx != mn {
            let d = mx - mn
            s = l > 0.5 ? d / (2 - mx - mn) : d / (mx + mn)
            switch mx {
            case rf: h = (gf - bf) / d + (gf < bf ? 6 : 0)
            case gf: h = (bf - rf) / d + 2
            default: h = (rf - gf) / d + 4
            }
            h /= 6
        }
        hInput = String(format: "%.0f", h * 360)
        sInput = String(format: "%.0f", s * 100)
        lInput = String(format: "%.0f", l * 100)
    }

    func hslToRGB(h: Double, s: Double, l: Double) -> (Int, Int, Int) {
        guard s != 0 else { let v = Int(l * 255); return (v, v, v) }
        func hue(_ p: Double, _ q: Double, _ t: Double) -> Double {
            var t = t
            if t < 0 { t += 1 }; if t > 1 { t -= 1 }
            if t < 1/6 { return p + (q - p) * 6 * t }
            if t < 1/2 { return q }
            if t < 2/3 { return p + (q - p) * (2/3 - t) * 6 }
            return p
        }
        let q = l < 0.5 ? l * (1 + s) : l + s - l * s
        let p = 2 * l - q
        return (Int(hue(p, q, h / 360 + 1/3) * 255),
                Int(hue(p, q, h / 360) * 255),
                Int(hue(p, q, h / 360 - 1/3) * 255))
    }

    func updatePreview(r: Int, g: Int, b: Int) {
        previewColor = Color(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }

    func copy(_ s: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(s, forType: .string)
    }
}

// MARK: - CSS Units Converter

struct CSSUnitsConverterView: View {
    @State private var inputValue = "16"
    @State private var inputUnit = "px"
    @State private var rootFontSize = "16"
    @State private var viewportWidth = "1440"
    @State private var viewportHeight = "900"
    @State private var results: [(unit: String, value: String)] = []
    @State private var error = ""

    private let units = ["px", "rem", "em", "pt", "%", "vw", "vh", "vmin", "vmax", "cm", "mm", "in"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Settings
                VStack(alignment: .leading, spacing: 8) {
                    Label("Settings", systemImage: "gearshape")
                        .font(.subheadline).fontWeight(.medium)
                    HStack(spacing: 16) {
                        settingField("Root font (px)", $rootFontSize)
                        settingField("Viewport W (px)", $viewportWidth)
                        settingField("Viewport H (px)", $viewportHeight)
                    }
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.4))

                Divider()

                // Input
                HStack(spacing: 8) {
                    TextField("Value", text: $inputValue)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                        .frame(width: 100)

                    Picker("Unit", selection: $inputUnit) {
                        ForEach(units, id: \.self) { Text($0).tag($0) }
                    }
                    .frame(width: 80)

                    Button("Convert", action: convert).buttonStyle(.borderedProminent)

                    if !error.isEmpty {
                        Text(error).foregroundStyle(.red).font(.caption)
                    }

                    Spacer()
                }
                .padding()

                if !results.isEmpty {
                    VStack(spacing: 0) {
                        Divider()
                        ForEach(results, id: \.unit) { row in
                            HStack {
                                Text(row.unit)
                                    .font(.system(.subheadline, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 55, alignment: .leading)
                                Spacer()
                                Text(row.value)
                                    .font(.system(.body, design: .monospaced))
                                    .fontWeight(.medium)
                                    .textSelection(.enabled)
                                Button { copy(row.value) } label: {
                                    Image(systemName: "doc.on.doc").font(.caption)
                                }.buttonStyle(.borderless)
                            }
                            .padding(.horizontal).padding(.vertical, 9)
                            Divider()
                        }
                    }
                }

                Spacer()
            }
        }
    }

    func settingField(_ label: String, _ text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            TextField("", text: text).textFieldStyle(.roundedBorder).frame(width: 100)
        }
    }

    func convert() {
        error = ""
        results = []
        guard let value = Double(inputValue),
              let rootPx = Double(rootFontSize), rootPx > 0,
              let vpW = Double(viewportWidth), vpW > 0,
              let vpH = Double(viewportHeight), vpH > 0 else {
            error = "❌ Invalid input or settings"
            return
        }

        // Convert input to px first
        let px: Double
        switch inputUnit {
        case "px":   px = value
        case "rem":  px = value * rootPx
        case "em":   px = value * rootPx
        case "pt":   px = value * (96.0 / 72.0)
        case "%":    px = value / 100 * rootPx
        case "vw":   px = value / 100 * vpW
        case "vh":   px = value / 100 * vpH
        case "vmin": px = value / 100 * min(vpW, vpH)
        case "vmax": px = value / 100 * max(vpW, vpH)
        case "cm":   px = value * 37.7953
        case "mm":   px = value * 3.77953
        case "in":   px = value * 96
        default: error = "❌ Unknown unit"; return
        }

        func fmt(_ v: Double) -> String {
            if v.truncatingRemainder(dividingBy: 1) == 0 {
                return String(format: "%.0f", v)
            }
            return String(format: "%.4f", v)
                .replacingOccurrences(of: "\\.?0+$", with: "", options: .regularExpression)
        }

        results = [
            ("px",   "\(fmt(px))px"),
            ("rem",  "\(fmt(px / rootPx))rem"),
            ("em",   "\(fmt(px / rootPx))em"),
            ("pt",   "\(fmt(px * 72.0 / 96.0))pt"),
            ("%",    "\(fmt(px / rootPx * 100))%"),
            ("vw",   "\(fmt(px / vpW * 100))vw"),
            ("vh",   "\(fmt(px / vpH * 100))vh"),
            ("vmin", "\(fmt(px / min(vpW, vpH) * 100))vmin"),
            ("vmax", "\(fmt(px / max(vpW, vpH) * 100))vmax"),
            ("cm",   "\(fmt(px / 37.7953))cm"),
            ("mm",   "\(fmt(px / 3.77953))mm"),
            ("in",   "\(fmt(px / 96))in"),
        ]
    }

    func copy(_ s: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(s, forType: .string)
    }
}

// MARK: - CSV ↔ Markdown Table

struct CSVMarkdownConverterView: View {
    @State private var csvText = ""
    @State private var markdownText = ""

    var body: some View {
        HSplitView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("CSV", systemImage: "tablecells")
                        .font(.subheadline).fontWeight(.medium)
                    Spacer()
                    Button { copy(csvText) } label: {
                        Label("Copy", systemImage: "doc.on.doc").font(.caption)
                    }.buttonStyle(.bordered).disabled(csvText.isEmpty)
                }
                .padding(.horizontal).padding(.top, 12)

                TextEditor(text: $csvText)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .padding(.horizontal)

                Button(action: csvToMarkdown) {
                    Label("CSV → Markdown Table", systemImage: "arrow.right").frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent)
                .padding(.horizontal).padding(.bottom, 12)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Markdown Table", systemImage: "doc.richtext")
                        .font(.subheadline).fontWeight(.medium)
                    Spacer()
                    Button { copy(markdownText) } label: {
                        Label("Copy", systemImage: "doc.on.doc").font(.caption)
                    }.buttonStyle(.bordered).disabled(markdownText.isEmpty)
                }
                .padding(.horizontal).padding(.top, 12)

                TextEditor(text: $markdownText)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .padding(.horizontal)

                Button(action: markdownToCSV) {
                    Label("← Markdown → CSV", systemImage: "arrow.left").frame(maxWidth: .infinity)
                }.buttonStyle(.borderedProminent)
                .padding(.horizontal).padding(.bottom, 12)
            }
        }
    }

    func csvToMarkdown() {
        let rows = parseCSVRows(csvText)
        guard !rows.isEmpty else { markdownText = ""; return }

        let maxCols = rows.map { $0.count }.max() ?? 0
        var colWidths = Array(repeating: 3, count: maxCols)
        for row in rows {
            for (i, cell) in row.enumerated() {
                colWidths[i] = max(colWidths[i], cell.count)
            }
        }

        func formatRow(_ cells: [String]) -> String {
            let padded = (0..<maxCols).map { i -> String in
                let cell = i < cells.count ? cells[i] : ""
                return cell.padding(toLength: colWidths[i], withPad: " ", startingAt: 0)
            }
            return "| " + padded.joined(separator: " | ") + " |"
        }

        var lines = [formatRow(rows[0])]
        lines.append("| " + colWidths.map { String(repeating: "-", count: $0) }.joined(separator: " | ") + " |")
        for row in rows.dropFirst() { lines.append(formatRow(row)) }
        markdownText = lines.joined(separator: "\n")
    }

    func markdownToCSV() {
        let rows = markdownText.components(separatedBy: .newlines)
            .filter { $0.trimmingCharacters(in: .whitespaces).hasPrefix("|") }
            .compactMap { line -> [String]? in
                let parts = line.components(separatedBy: "|")
                    .dropFirst().dropLast()
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                // Skip separator rows (e.g. |---|---|)
                if parts.allSatisfy({ $0.allSatisfy({ $0 == "-" || $0 == ":" || $0 == " " || $0 == "|" }) }) {
                    return nil
                }
                return Array(parts)
            }

        csvText = rows.map { row in
            row.map { cell -> String in
                if cell.contains(",") || cell.contains("\"") {
                    return "\"" + cell.replacingOccurrences(of: "\"", with: "\"\"") + "\""
                }
                return cell
            }.joined(separator: ",")
        }.joined(separator: "\n")
    }

    func parseCSVRows(_ csv: String) -> [[String]] {
        var rows: [[String]] = []
        var current: [String] = []
        var cell = ""
        var inQuotes = false
        for char in csv {
            if char == "\"" { inQuotes.toggle() }
            else if char == "," && !inQuotes {
                current.append(cell.trimmingCharacters(in: .whitespaces)); cell = ""
            } else if char == "\n" && !inQuotes {
                current.append(cell.trimmingCharacters(in: .whitespaces))
                rows.append(current); current = []; cell = ""
            } else { cell.append(char) }
        }
        if !cell.isEmpty || !current.isEmpty {
            current.append(cell.trimmingCharacters(in: .whitespaces))
            rows.append(current)
        }
        return rows.filter { !$0.allSatisfy({ $0.isEmpty }) }
    }

    func copy(_ s: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(s, forType: .string)
    }
}
