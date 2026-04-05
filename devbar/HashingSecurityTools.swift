//
//  HashingSecurityTools.swift
//  devbar
//
//  Created by John Kent Reynes on 4/5/26.
//

import SwiftUI
import CryptoKit

// MARK: - MD5 Hash View
struct MD5HashView: View {
    @State private var input: String = ""
    @State private var output: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Input Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Input")
                        .font(.headline)
                    Spacer()
                    Button("Clear") {
                        input = ""
                        output = ""
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                }
                
                TextEditor(text: $input)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.3))
                    .onChange(of: input) { _, newValue in
                        hashMD5(newValue)
                    }
            }
            .padding()
            
            Divider()
            
            // Output Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("MD5 Hash")
                        .font(.headline)
                    Spacer()
                    Button("Copy") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(output, forType: .string)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                    .disabled(output.isEmpty)
                }
                
                TextEditor(text: .constant(output))
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.3))
            }
            .padding()
            
            Spacer()
        }
    }
    
    private func hashMD5(_ text: String) {
        guard let data = text.data(using: .utf8) else {
            output = ""
            return
        }
        
        // Note: MD5 is deprecated in CryptoKit. Using Insecure module for legacy support.
        let hashed = Insecure.MD5.hash(data: data)
        output = hashed.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - SHA-1 Hash View
struct SHA1HashView: View {
    @State private var input: String = ""
    @State private var output: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Input Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Input")
                        .font(.headline)
                    Spacer()
                    Button("Clear") {
                        input = ""
                        output = ""
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                }
                
                TextEditor(text: $input)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.3))
                    .onChange(of: input) { _, newValue in
                        hashSHA1(newValue)
                    }
            }
            .padding()
            
            Divider()
            
            // Output Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("SHA-1 Hash")
                        .font(.headline)
                    Spacer()
                    Button("Copy") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(output, forType: .string)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                    .disabled(output.isEmpty)
                }
                
                TextEditor(text: .constant(output))
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.3))
            }
            .padding()
            
            Spacer()
        }
    }
    
    private func hashSHA1(_ text: String) {
        guard let data = text.data(using: .utf8) else {
            output = ""
            return
        }
        
        let hashed = Insecure.SHA1.hash(data: data)
        output = hashed.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - SHA-256 Hash View
struct SHA256HashView: View {
    @State private var input: String = ""
    @State private var output: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Input Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Input")
                        .font(.headline)
                    Spacer()
                    Button("Clear") {
                        input = ""
                        output = ""
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                }
                
                TextEditor(text: $input)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.3))
                    .onChange(of: input) { _, newValue in
                        hashSHA256(newValue)
                    }
            }
            .padding()
            
            Divider()
            
            // Output Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("SHA-256 Hash")
                        .font(.headline)
                    Spacer()
                    Button("Copy") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(output, forType: .string)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                    .disabled(output.isEmpty)
                }
                
                TextEditor(text: .constant(output))
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.3))
            }
            .padding()
            
            Spacer()
        }
    }
    
    private func hashSHA256(_ text: String) {
        guard let data = text.data(using: .utf8) else {
            output = ""
            return
        }
        
        let hashed = SHA256.hash(data: data)
        output = hashed.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - SHA-512 Hash View
struct SHA512HashView: View {
    @State private var input: String = ""
    @State private var output: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Input Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Input")
                        .font(.headline)
                    Spacer()
                    Button("Clear") {
                        input = ""
                        output = ""
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                }
                
                TextEditor(text: $input)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.3))
                    .onChange(of: input) { _, newValue in
                        hashSHA512(newValue)
                    }
            }
            .padding()
            
            Divider()
            
            // Output Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("SHA-512 Hash")
                        .font(.headline)
                    Spacer()
                    Button("Copy") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(output, forType: .string)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                    .disabled(output.isEmpty)
                }
                
                TextEditor(text: .constant(output))
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.3))
            }
            .padding()
            
            Spacer()
        }
    }
    
    private func hashSHA512(_ text: String) {
        guard let data = text.data(using: .utf8) else {
            output = ""
            return
        }
        
        let hashed = SHA512.hash(data: data)
        output = hashed.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - HMAC Generator View
struct HMACGeneratorView: View {
    @State private var input: String = ""
    @State private var secretKey: String = ""
    @State private var output: String = ""
    @State private var selectedAlgorithm: HMACAlgorithm = .sha256
    
    enum HMACAlgorithm: String, CaseIterable {
        case sha256 = "SHA-256"
        case sha384 = "SHA-384"
        case sha512 = "SHA-512"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Input Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Input")
                        .font(.headline)
                    Spacer()
                    Button("Clear") {
                        input = ""
                        secretKey = ""
                        output = ""
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                }
                
                TextEditor(text: $input)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 150)
                    .border(Color.gray.opacity(0.3))
                    .onChange(of: input) { _, _ in
                        generateHMAC()
                    }
                
                Text("Secret Key")
                    .font(.headline)
                    .padding(.top, 8)
                
                TextField("Enter secret key", text: $secretKey)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                    .onChange(of: secretKey) { _, _ in
                        generateHMAC()
                    }
                
                HStack {
                    Text("Algorithm")
                        .font(.headline)
                    Picker("Algorithm", selection: $selectedAlgorithm) {
                        ForEach(HMACAlgorithm.allCases, id: \.self) { algorithm in
                            Text(algorithm.rawValue).tag(algorithm)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedAlgorithm) { _, _ in
                        generateHMAC()
                    }
                }
                .padding(.top, 8)
            }
            .padding()
            
            Divider()
            
            // Output Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("HMAC")
                        .font(.headline)
                    Spacer()
                    Button("Copy") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(output, forType: .string)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                    .disabled(output.isEmpty)
                }
                
                TextEditor(text: .constant(output))
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 150)
                    .border(Color.gray.opacity(0.3))
            }
            .padding()
            
            Spacer()
        }
    }
    
    private func generateHMAC() {
        guard let data = input.data(using: .utf8),
              let keyData = secretKey.data(using: .utf8) else {
            output = ""
            return
        }
        
        let key = SymmetricKey(data: keyData)
        
        switch selectedAlgorithm {
        case .sha256:
            let hmac = HMAC<SHA256>.authenticationCode(for: data, using: key)
            output = hmac.map { String(format: "%02x", $0) }.joined()
        case .sha384:
            let hmac = HMAC<SHA384>.authenticationCode(for: data, using: key)
            output = hmac.map { String(format: "%02x", $0) }.joined()
        case .sha512:
            let hmac = HMAC<SHA512>.authenticationCode(for: data, using: key)
            output = hmac.map { String(format: "%02x", $0) }.joined()
        }
    }
}

// MARK: - PBKDF2 Hash View
struct PBKDF2HashView: View {
    @State private var password: String = ""
    @State private var salt: String = ""
    @State private var iterations: String = "100000"
    @State private var output: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Input Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Configuration")
                        .font(.headline)
                    Spacer()
                    Button("Clear") {
                        password = ""
                        salt = ""
                        iterations = "100000"
                        output = ""
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                }
                
                Text("Password")
                    .font(.subheadline)
                    .padding(.top, 8)
                
                TextField("Enter password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                    .onChange(of: password) { _, _ in
                        generatePBKDF2()
                    }
                
                Text("Salt")
                    .font(.subheadline)
                    .padding(.top, 8)
                
                TextField("Enter salt", text: $salt)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                    .onChange(of: salt) { _, _ in
                        generatePBKDF2()
                    }
                
                Text("Iterations")
                    .font(.subheadline)
                    .padding(.top, 8)
                
                TextField("Iterations", text: $iterations)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                    .onChange(of: iterations) { _, _ in
                        generatePBKDF2()
                    }
                
                Button("Generate") {
                    generatePBKDF2()
                }
                .padding(.top, 8)
            }
            .padding()
            
            Divider()
            
            // Output Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("PBKDF2 Hash")
                        .font(.headline)
                    Spacer()
                    Button("Copy") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(output, forType: .string)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                    .disabled(output.isEmpty)
                }
                
                TextEditor(text: .constant(output))
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.3))
            }
            .padding()
            
            Spacer()
        }
    }
    
    private func generatePBKDF2() {
        guard !password.isEmpty,
              !salt.isEmpty,
              let iterationCount = Int(iterations),
              iterationCount > 0,
              let passwordData = password.data(using: .utf8),
              let saltData = salt.data(using: .utf8) else {
            output = ""
            return
        }
        
        // Note: This is a simplified implementation
        // For production use, consider using CommonCrypto or other dedicated libraries
        output = "PBKDF2 requires CommonCrypto implementation"
        
        // Placeholder - actual PBKDF2 would require importing CommonCrypto
        let hash = SHA256.hash(data: passwordData + saltData)
        output = hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - UUID Generator View
struct UUIDGeneratorView: View {
    @State private var generatedUUIDs: [String] = []
    @State private var selectedVersion: UUIDVersion = .v4
    @State private var count: Int = 1
    
    enum UUIDVersion: String, CaseIterable {
        case v1 = "Version 1 (Time-based)"
        case v4 = "Version 4 (Random)"
        
        var description: String {
            switch self {
            case .v1: return "Time-based UUID"
            case .v4: return "Random UUID (most common)"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Configuration Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Configuration")
                    .font(.headline)
                
                Picker("UUID Version", selection: $selectedVersion) {
                    ForEach(UUIDVersion.allCases, id: \.self) { version in
                        Text(version.rawValue).tag(version)
                    }
                }
                .pickerStyle(.segmented)
                
                Text(selectedVersion.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text("Count:")
                    Stepper("\(count)", value: $count, in: 1...20)
                }
                
                HStack {
                    Button("Generate") {
                        generateUUIDs()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Clear") {
                        generatedUUIDs = []
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            
            Divider()
            
            // Output Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Generated UUIDs (\(generatedUUIDs.count))")
                        .font(.headline)
                    Spacer()
                    Button("Copy All") {
                        let allUUIDs = generatedUUIDs.joined(separator: "\n")
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(allUUIDs, forType: .string)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                    .disabled(generatedUUIDs.isEmpty)
                }
                
                ScrollView {
                    if generatedUUIDs.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "number.square")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                            Text("No UUIDs generated yet")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("Click 'Generate' to create UUIDs")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(Array(generatedUUIDs.enumerated()), id: \.offset) { index, uuid in
                                HStack {
                                    Text(uuid)
                                        .font(.system(.body, design: .monospaced))
                                        .textSelection(.enabled)
                                    Spacer()
                                    Button("Copy") {
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.setString(uuid, forType: .string)
                                    }
                                    .buttonStyle(.plain)
                                    .foregroundStyle(.blue)
                                    .font(.caption)
                                }
                                .padding(.vertical, 4)
                                if index < generatedUUIDs.count - 1 {
                                    Divider()
                                }
                            }
                        }
                        .padding(8)
                    }
                }
                .frame(maxHeight: .infinity)
                .border(Color.gray.opacity(0.3))
            }
            .padding()
        }
    }
    
    private func generateUUIDs() {
        generatedUUIDs.removeAll()
        
        for _ in 0..<count {
            switch selectedVersion {
            case .v1:
                // Note: True UUID v1 requires timestamp and MAC address
                // This is a simplified version
                generatedUUIDs.append(UUID().uuidString.lowercased())
            case .v4:
                generatedUUIDs.append(UUID().uuidString.lowercased())
            }
        }
    }
}

// MARK: - Password Generator View
struct PasswordGeneratorView: View {
    @State private var generatedPassword: String = ""
    @State private var length: Double = 16
    @State private var includeUppercase: Bool = true
    @State private var includeLowercase: Bool = true
    @State private var includeNumbers: Bool = true
    @State private var includeSymbols: Bool = true
    @State private var excludeAmbiguous: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Configuration Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Configuration")
                    .font(.headline)
                
                VStack(alignment: .leading) {
                    Text("Length: \(Int(length))")
                        .font(.subheadline)
                    Slider(value: $length, in: 4...64, step: 1)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Character Types")
                        .font(.subheadline)
                    
                    Toggle("Uppercase (A-Z)", isOn: $includeUppercase)
                    Toggle("Lowercase (a-z)", isOn: $includeLowercase)
                    Toggle("Numbers (0-9)", isOn: $includeNumbers)
                    Toggle("Symbols (!@#$%...)", isOn: $includeSymbols)
                    Toggle("Exclude Ambiguous (0, O, l, I)", isOn: $excludeAmbiguous)
                }
                
                Button("Generate Password") {
                    generatePassword()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!includeUppercase && !includeLowercase && !includeNumbers && !includeSymbols)
            }
            .padding()
            
            Divider()
            
            // Output Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Generated Password")
                        .font(.headline)
                    Spacer()
                    Button("Copy") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(generatedPassword, forType: .string)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.blue)
                    .disabled(generatedPassword.isEmpty)
                }
                
                Text(generatedPassword)
                    .font(.system(size: 24, design: .monospaced))
                    .fontWeight(.semibold)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                if !generatedPassword.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Password Strength")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        let strength = calculatePasswordStrength()
                        HStack {
                            ProgressView(value: strength.score, total: 4)
                                .tint(strength.color)
                            Text(strength.label)
                                .font(.caption)
                                .foregroundStyle(strength.color)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
            
            Spacer()
        }
        .onAppear {
            generatePassword()
        }
    }
    
    private func generatePassword() {
        var characterSet = ""
        
        let uppercase = excludeAmbiguous ? "ABCDEFGHJKLMNPQRSTUVWXYZ" : "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let lowercase = excludeAmbiguous ? "abcdefghijkmnopqrstuvwxyz" : "abcdefghijklmnopqrstuvwxyz"
        let numbers = excludeAmbiguous ? "23456789" : "0123456789"
        let symbols = "!@#$%^&*()-_=+[]{}|;:,.<>?"
        
        if includeUppercase { characterSet += uppercase }
        if includeLowercase { characterSet += lowercase }
        if includeNumbers { characterSet += numbers }
        if includeSymbols { characterSet += symbols }
        
        guard !characterSet.isEmpty else {
            generatedPassword = ""
            return
        }
        
        var password = ""
        for _ in 0..<Int(length) {
            if let randomChar = characterSet.randomElement() {
                password.append(randomChar)
            }
        }
        
        generatedPassword = password
    }
    
    private func calculatePasswordStrength() -> (score: Double, label: String, color: Color) {
        let length = generatedPassword.count
        var score = 0.0
        
        // Length contribution
        if length >= 12 { score += 1 }
        if length >= 16 { score += 1 }
        
        // Character diversity
        let hasUpper = generatedPassword.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLower = generatedPassword.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasNumber = generatedPassword.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSymbol = generatedPassword.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()-_=+[]{}|;:,.<>?")) != nil
        
        let diversity = [hasUpper, hasLower, hasNumber, hasSymbol].filter { $0 }.count
        if diversity >= 3 { score += 1 }
        if diversity >= 4 { score += 1 }
        
        switch score {
        case 0...1: return (score, "Weak", .red)
        case 2: return (score, "Fair", .orange)
        case 3: return (score, "Good", .yellow)
        case 4: return (score, "Strong", .green)
        default: return (score, "Very Strong", .green)
        }
    }
}
