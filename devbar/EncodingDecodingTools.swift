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
