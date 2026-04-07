//
//  EncodingDecodingTools.swift
//  devbar
//
//  Created by John Kent Reynes on 4/5/26.
//

import SwiftUI

// MARK: - Base64 Encoder
struct Base64EncoderView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    
    var body: some View {
        EncodingToolTemplate(
            title: "Base64 Encoder",
            inputText: $inputText,
            outputText: $outputText,
            processAction: {
                if let data = inputText.data(using: .utf8) {
                    outputText = data.base64EncodedString()
                } else {
                    outputText = ""
                }
            }
        )
    }
}

// MARK: - Base64 Decoder
struct Base64DecoderView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    
    var body: some View {
        EncodingToolTemplate(
            title: "Base64 Decoder",
            inputText: $inputText,
            outputText: $outputText,
            processAction: {
                if let data = Data(base64Encoded: inputText),
                   let decoded = String(data: data, encoding: .utf8) {
                    outputText = decoded
                } else {
                    outputText = "❌ Invalid Base64 string"
                }
            }
        )
    }
}

// MARK: - URL Encoder
struct URLEncoderView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    
    var body: some View {
        EncodingToolTemplate(
            title: "URL Encoder",
            inputText: $inputText,
            outputText: $outputText,
            processAction: {
                outputText = inputText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? inputText
            }
        )
    }
}

// MARK: - URL Decoder
struct URLDecoderView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    
    var body: some View {
        EncodingToolTemplate(
            title: "URL Decoder",
            inputText: $inputText,
            outputText: $outputText,
            processAction: {
                outputText = inputText.removingPercentEncoding ?? "❌ Invalid URL encoded string"
            }
        )
    }
}

// MARK: - HTML Entity Encoder
struct HTMLEntityEncoderView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    
    var body: some View {
        EncodingToolTemplate(
            title: "HTML Entity Encoder",
            inputText: $inputText,
            outputText: $outputText,
            processAction: {
                var result = inputText
                result = result.replacingOccurrences(of: "&", with: "&amp;")
                result = result.replacingOccurrences(of: "<", with: "&lt;")
                result = result.replacingOccurrences(of: ">", with: "&gt;")
                result = result.replacingOccurrences(of: "\"", with: "&quot;")
                result = result.replacingOccurrences(of: "'", with: "&#39;")
                outputText = result
            }
        )
    }
}

// MARK: - HTML Entity Decoder
struct HTMLEntityDecoderView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    
    var body: some View {
        EncodingToolTemplate(
            title: "HTML Entity Decoder",
            inputText: $inputText,
            outputText: $outputText,
            processAction: {
                var result = inputText
                result = result.replacingOccurrences(of: "&lt;", with: "<")
                result = result.replacingOccurrences(of: "&gt;", with: ">")
                result = result.replacingOccurrences(of: "&quot;", with: "\"")
                result = result.replacingOccurrences(of: "&#39;", with: "'")
                result = result.replacingOccurrences(of: "&amp;", with: "&")
                outputText = result
            }
        )
    }
}

// MARK: - JWT Decoder
struct JWTDecoderView: View {
    @State private var jwtToken: String = ""
    @State private var header: String = ""
    @State private var payload: String = ""
    @State private var signature: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("JWT Token", systemImage: "key.fill")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(jwtToken.count) chars")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                TextEditor(text: $jwtToken)
                    .font(.system(.caption, design: .monospaced))
                    .frame(height: 100)
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .onChange(of: jwtToken) { _, _ in decode() }
            }
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    JWTDecodedSection(title: "Header", content: header, icon: "1.circle.fill")
                    JWTDecodedSection(title: "Payload", content: payload, icon: "2.circle.fill")
                    JWTDecodedSection(title: "Signature", content: signature, icon: "3.circle.fill")
                }
                .padding()
            }
        }
    }
    
    func decode() {
        let parts = jwtToken.components(separatedBy: ".")
        guard parts.count == 3 else {
            header = "Invalid JWT format"
            payload = ""
            signature = ""
            return
        }
        
        header = decodeBase64(parts[0])
        payload = decodeBase64(parts[1])
        signature = parts[2]
    }
    
    func decodeBase64(_ input: String) -> String {
        var base64 = input
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        while base64.count % 4 != 0 {
            base64.append("=")
        }
        
        guard let data = Data(base64Encoded: base64),
              let decoded = String(data: data, encoding: .utf8) else {
            return "Decode error"
        }
        
        return decoded
    }
}

struct JWTDecodedSection: View {
    let title: String
    let content: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(content, forType: .string)
                }) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.plain)
                .disabled(content.isEmpty)
            }
            
            Text(content.isEmpty ? "—" : content)
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(nsColor: .textBackgroundColor))
                .cornerRadius(6)
        }
    }
}

// MARK: - Unicode Encoder
struct UnicodeEncoderView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    
    var body: some View {
        EncodingToolTemplate(
            title: "Unicode Encoder",
            inputText: $inputText,
            outputText: $outputText,
            processAction: {
                outputText = inputText.unicodeScalars.map {
                    String(format: "\\u%04X", $0.value)
                }.joined()
            }
        )
    }
}

// MARK: - Binary/Hex Encoder
struct BinaryHexEncoderView: View {
    @State private var textInput: String = ""
    @State private var binaryOutput: String = ""
    @State private var hexOutput: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Label("Text Input", systemImage: "square.and.pencil")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                TextEditor(text: $textInput)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 150)
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .onChange(of: textInput) { _, _ in encode() }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                EncodedOutputRow(label: "Binary", icon: "01.square", value: binaryOutput)
                EncodedOutputRow(label: "Hexadecimal", icon: "number.square", value: hexOutput)
            }
            .padding()
        }
    }
    
    func encode() {
        guard !textInput.isEmpty else {
            binaryOutput = ""
            hexOutput = ""
            return
        }
        
        let data = Data(textInput.utf8)
        binaryOutput = data.map {
            String($0, radix: 2).leftPadding(toLength: 8, withPad: "0")
        }.joined(separator: " ")
        hexOutput = data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }
}

struct EncodedOutputRow: View {
    let label: String
    let icon: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                Text(label)
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(value, forType: .string)
                }) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.plain)
                .disabled(value.isEmpty)
            }
            
            ScrollView(.horizontal) {
                Text(value.isEmpty ? "Enter text to encode..." : value)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
                    .foregroundStyle(value.isEmpty ? .secondary : .primary)
                    .padding(8)
            }
            .frame(height: 40)
            .background(Color(nsColor: .textBackgroundColor))
            .cornerRadius(6)
        }
    }
}

extension String {
    func leftPadding(toLength: Int, withPad: String) -> String {
        guard self.count < toLength else { return self }
        return String(repeating: withPad, count: toLength - self.count) + self
    }
}

// MARK: - Morse Code Encoder
struct MorseCodeEncoderView: View {
    @State private var inputText: String = ""
    @State private var outputText: String = ""
    @State private var isEncoding: Bool = true
    
    let morseCode: [Character: String] = [
        "A": ".-", "B": "-...", "C": "-.-.", "D": "-..", "E": ".",
        "F": "..-.", "G": "--.", "H": "....", "I": "..", "J": ".---",
        "K": "-.-", "L": ".-..", "M": "--", "N": "-.", "O": "---",
        "P": ".--.", "Q": "--.-", "R": ".-.", "S": "...", "T": "-",
        "U": "..-", "V": "...-", "W": ".--", "X": "-..-", "Y": "-.--",
        "Z": "--..", "0": "-----", "1": ".----", "2": "..---", "3": "...--",
        "4": "....-", "5": ".....", "6": "-....", "7": "--...", "8": "---..",
        "9": "----.", " ": "/"
    ]
    
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
                    .frame(height: 150)
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .onChange(of: inputText) { _, _ in process() }
            }
            
            Divider()
            
            VStack(spacing: 12) {
                Picker("Mode", selection: $isEncoding) {
                    Text("Encode to Morse").tag(true)
                    Text("Decode from Morse").tag(false)
                }
                .pickerStyle(.segmented)
                .frame(width: 300)
                .onChange(of: isEncoding) { _, _ in process() }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Output", systemImage: "waveform")
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
    
    func process() {
        guard !inputText.isEmpty else {
            outputText = ""
            return
        }
        
        if isEncoding {
            outputText = inputText.uppercased().compactMap { morseCode[$0] }.joined(separator: " ")
        } else {
            let reverseMorse = Dictionary(uniqueKeysWithValues: morseCode.map { ($1, $0) })
            outputText = inputText.split(separator: " ").compactMap { reverseMorse[String($0)] }.map(String.init).joined()
        }
    }
}

// MARK: - Reusable Template
struct EncodingToolTemplate: View {
    let title: String
    @Binding var inputText: String
    @Binding var outputText: String
    let processAction: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Input section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Input", systemImage: "square.and.pencil")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(inputText.count) chars")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button(action: { inputText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
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
                    .onChange(of: inputText) { _, _ in
                        processAction()
                    }
            }
            
            Divider()
            
            // Output section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Output", systemImage: "doc.text")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(outputText.count) chars")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Button(action: {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(outputText, forType: .string)
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .disabled(outputText.isEmpty)
                    
                    Button(action: {
                        outputText = ""
                        inputText = ""
                    }) {
                        Label("Clear All", systemImage: "trash")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .disabled(outputText.isEmpty && inputText.isEmpty)
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

// MARK: - Cron Expression Parser

struct CronExpressionParserView: View {
    @State private var expression = "*/5 * * * *"
    @State private var result: CronParseResult? = nil
    @State private var error = ""
    @State private var nextDates: [Date] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Input
                VStack(alignment: .leading, spacing: 8) {
                    Label("Cron Expression", systemImage: "clock.badge.checkmark")
                        .font(.subheadline).fontWeight(.medium)

                    HStack(spacing: 8) {
                        TextField("e.g.  */5 * * * *", text: $expression)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                        Button("Parse", action: parse)
                            .buttonStyle(.borderedProminent)
                    }

                    // Field labels
                    HStack(spacing: 0) {
                        ForEach(["Minute", "Hour", "Day", "Month", "Weekday"], id: \.self) { label in
                            Text(label)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 4)

                    if !error.isEmpty {
                        Text(error).font(.caption).foregroundStyle(.red)
                    }
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))

                Divider()

                // Quick presets
                VStack(alignment: .leading, spacing: 8) {
                    Text("Presets").font(.caption).foregroundStyle(.secondary)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                        ForEach(CronExpressionParserView.presets, id: \.0) { label, expr in
                            Button {
                                expression = expr
                                parse()
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(label).font(.caption).fontWeight(.medium)
                                    Text(expr).font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                .padding()

                if let r = result {
                    Divider()

                    // Human-readable description
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Description", systemImage: "text.bubble")
                            .font(.subheadline).fontWeight(.medium)
                        Text(r.description)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(nsColor: .textBackgroundColor))
                            .cornerRadius(8)
                    }
                    .padding()

                    Divider()

                    // Field breakdown
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Field Breakdown", systemImage: "list.bullet.rectangle")
                            .font(.subheadline).fontWeight(.medium)

                        VStack(spacing: 0) {
                            ForEach(r.fields, id: \.name) { field in
                                HStack(spacing: 12) {
                                    Text(field.name)
                                        .font(.caption).foregroundStyle(.secondary)
                                        .frame(width: 72, alignment: .trailing)
                                    Text(field.raw)
                                        .font(.system(.body, design: .monospaced))
                                        .frame(width: 80, alignment: .leading)
                                    Text(field.meaning)
                                        .font(.caption)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal).padding(.vertical, 8)
                                Divider()
                            }
                        }
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(8)
                    }
                    .padding()

                    Divider()

                    // Next 10 scheduled runs
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Next 10 Scheduled Runs  (from now, UTC)", systemImage: "calendar.badge.clock")
                            .font(.subheadline).fontWeight(.medium)

                        VStack(spacing: 0) {
                            ForEach(Array(nextDates.enumerated()), id: \.offset) { i, date in
                                HStack {
                                    Text("#\(i + 1)")
                                        .font(.caption).foregroundStyle(.secondary)
                                        .frame(width: 28, alignment: .trailing)
                                    Text(formatDate(date))
                                        .font(.system(.body, design: .monospaced))
                                    Spacer()
                                    Text(relativeTime(date))
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                .padding(.horizontal).padding(.vertical, 7)
                                Divider()
                            }
                        }
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(8)
                    }
                    .padding()
                }
            }
        }
        .onAppear { parse() }
    }

    // MARK: - Parse

    func parse() {
        error = ""
        result = nil
        nextDates = []
        let parts = expression.trimmingCharacters(in: .whitespaces)
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }

        guard parts.count == 5 else {
            error = "❌ A cron expression needs exactly 5 fields: minute hour day month weekday"
            return
        }

        let fieldDefs: [(String, ClosedRange<Int>, String)] = [
            ("Minute",  0...59,  "0–59"),
            ("Hour",    0...23,  "0–23"),
            ("Day",     1...31,  "1–31"),
            ("Month",   1...12,  "1–12"),
            ("Weekday", 0...6,   "0–6 (Sun–Sat)"),
        ]
        let monthNames = ["","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
        let dayNames   = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]

        var fields: [CronField] = []
        for (i, (name, range, hint)) in fieldDefs.enumerated() {
            let raw = parts[i]
            do {
                let meaning = try describeField(raw, range: range, names: i == 3 ? monthNames : i == 4 ? dayNames : [], hint: hint)
                fields.append(CronField(name: name, raw: raw, meaning: meaning))
            } catch {
                self.error = "❌ \(name): \(error.localizedDescription)"
                return
            }
        }

        let description = buildDescription(fields)
        result = CronParseResult(description: description, fields: fields)
        nextDates = computeNextDates(parts: parts, count: 10)
    }

    // MARK: - Field description

    func describeField(_ raw: String, range: ClosedRange<Int>, names: [String], hint: String) throws -> String {
        if raw == "*" { return "Every \(hint.components(separatedBy: " ").first ?? "value")" }
        if raw == "?" { return "Any" }

        // List: a,b,c
        if raw.contains(",") {
            let items = try raw.components(separatedBy: ",").map { v -> String in
                guard let n = Int(v), range.contains(n) else { throw NSError(domain: "Invalid value '\(v)' for range \(hint)", code: 0) }
                return names.isEmpty ? v : (n < names.count ? names[n] : v)
            }
            return items.joined(separator: ", ")
        }

        // Step: */n or a-b/n
        if raw.contains("/") {
            let sides = raw.components(separatedBy: "/")
            guard sides.count == 2, let step = Int(sides[1]), step > 0 else {
                throw NSError(domain: "Invalid step in '\(raw)'", code: 0)
            }
            let base = sides[0] == "*" ? "every \(step) (starting \(range.lowerBound))" : "every \(step) from \(sides[0])"
            return base
        }

        // Range: a-b
        if raw.contains("-") {
            let sides = raw.components(separatedBy: "-")
            guard sides.count == 2,
                  let lo = Int(sides[0]), let hi = Int(sides[1]),
                  range.contains(lo), range.contains(hi) else {
                throw NSError(domain: "Invalid range '\(raw)' for \(hint)", code: 0)
            }
            let loStr = !names.isEmpty && lo < names.count ? names[lo] : "\(lo)"
            let hiStr = !names.isEmpty && hi < names.count ? names[hi] : "\(hi)"
            return "\(loStr) – \(hiStr)"
        }

        // Plain number
        guard let n = Int(raw), range.contains(n) else {
            throw NSError(domain: "Value '\(raw)' out of range \(hint)", code: 0)
        }
        return !names.isEmpty && n < names.count && !names[n].isEmpty ? names[n] : "\(n)"
    }

    // MARK: - Human description

    func buildDescription(_ fields: [CronField]) -> String {
        let min = fields[0].raw, hr = fields[1].raw
        let day = fields[2].raw, mon = fields[3].raw, wd = fields[4].raw

        var parts: [String] = []

        // Time part
        if min == "*" && hr == "*" {
            parts.append("every minute")
        } else if min.contains("/") && hr == "*" {
            let step = min.components(separatedBy: "/").last ?? "?"
            parts.append("every \(step) minute\(step == "1" ? "" : "s")")
        } else if hr == "*" {
            parts.append("at minute \(fields[0].meaning) of every hour")
        } else {
            parts.append("at \(fields[1].meaning):\(min == "*" ? "00" : min.count == 1 ? "0\(min)" : min)")
        }

        // Day/month part
        let dayAny = day == "*" || day == "?"
        let monAny = mon == "*" || mon == "?"
        let wdAny  = wd  == "*" || wd  == "?"

        if !monAny { parts.append("in \(fields[3].meaning)") }
        if !dayAny { parts.append("on day \(fields[2].meaning)") }
        if !wdAny  { parts.append("on \(fields[4].meaning)") }
        if dayAny && monAny && wdAny { parts.append("every day") }

        return parts.joined(separator: ", ").prefix(1).uppercased() + parts.joined(separator: ", ").dropFirst()
    }

    // MARK: - Next dates

    func computeNextDates(parts: [String], count: Int) -> [Date] {
        guard parts.count == 5 else { return [] }
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!

        var dates: [Date] = []
        var current = Date().addingTimeInterval(60) // start from next minute

        let maxIterations = 200_000
        var iterations = 0

        while dates.count < count && iterations < maxIterations {
            iterations += 1
            let comps = cal.dateComponents([.minute, .hour, .day, .month, .weekday], from: current)
            guard let minute  = comps.minute,
                  let hour    = comps.hour,
                  let day     = comps.day,
                  let month   = comps.month,
                  let weekday = comps.weekday else { break }

            let wd = weekday - 1 // Calendar uses 1=Sun..7=Sat; cron uses 0=Sun..6=Sat

            if matchField(parts[0], value: minute,  range: 0...59) &&
               matchField(parts[1], value: hour,    range: 0...23) &&
               matchField(parts[2], value: day,     range: 1...31) &&
               matchField(parts[3], value: month,   range: 1...12) &&
               matchField(parts[4], value: wd,      range: 0...6) {
                dates.append(current)
                current = current.addingTimeInterval(60)
            } else {
                current = current.addingTimeInterval(60)
            }
        }

        return dates
    }

    func matchField(_ field: String, value: Int, range: ClosedRange<Int>) -> Bool {
        if field == "*" || field == "?" { return true }

        // List
        if field.contains(",") {
            return field.components(separatedBy: ",").contains { matchSingle($0, value: value, range: range) }
        }
        return matchSingle(field, value: value, range: range)
    }

    func matchSingle(_ part: String, value: Int, range: ClosedRange<Int>) -> Bool {
        // Step
        if part.contains("/") {
            let sides = part.components(separatedBy: "/")
            guard sides.count == 2, let step = Int(sides[1]), step > 0 else { return false }
            let start: Int
            if sides[0] == "*" { start = range.lowerBound }
            else if let s = Int(sides[0]) { start = s }
            else { return false }
            return value >= start && (value - start) % step == 0
        }
        // Range
        if part.contains("-") {
            let sides = part.components(separatedBy: "-")
            guard sides.count == 2, let lo = Int(sides[0]), let hi = Int(sides[1]) else { return false }
            return value >= lo && value <= hi
        }
        // Plain
        return Int(part) == value
    }

    // MARK: - Formatting

    func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd  HH:mm"
        f.timeZone = TimeZone(identifier: "UTC")
        return f.string(from: date)
    }

    func relativeTime(_ date: Date) -> String {
        let secs = Int(date.timeIntervalSinceNow)
        if secs < 60 { return "in \(secs)s" }
        let mins = secs / 60
        if mins < 60 { return "in \(mins)m" }
        let hrs = mins / 60
        if hrs < 24 { return "in \(hrs)h \(mins % 60)m" }
        return "in \(hrs / 24)d"
    }

    func copy(_ s: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(s, forType: .string)
    }

    // MARK: - Presets

    static let presets: [(String, String)] = [
        ("Every minute",         "* * * * *"),
        ("Every 5 minutes",      "*/5 * * * *"),
        ("Every 15 minutes",     "*/15 * * * *"),
        ("Every 30 minutes",     "*/30 * * * *"),
        ("Every hour",           "0 * * * *"),
        ("Every day at midnight","0 0 * * *"),
        ("Every day at noon",    "0 12 * * *"),
        ("Every Sunday",         "0 0 * * 0"),
        ("Every weekday (9 am)", "0 9 * * 1-5"),
        ("Every month (1st)",    "0 0 1 * *"),
        ("Every year (Jan 1st)", "0 0 1 1 *"),
        ("Every 6 hours",        "0 */6 * * *"),
    ]
}

// MARK: - Cron model types

struct CronField {
    let name: String
    let raw: String
    let meaning: String
}

struct CronParseResult {
    let description: String
    let fields: [CronField]
}
