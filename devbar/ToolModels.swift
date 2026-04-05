//
//  ToolModels.swift
//  devbar
//
//  Created by John Kent Reynes on 4/5/26.
//

import SwiftUI
import Combine

enum ToolCategory: String, CaseIterable {
    case recent = "Recent"
    case encodingDecoding = "Encoding & Decoding"
    case hashingSecurity = "Hashing & Security"
}

struct DevTool: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let iconColor: Color
    let category: ToolCategory
    let view: ToolType
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DevTool, rhs: DevTool) -> Bool {
        lhs.id == rhs.id
    }
}

enum ToolType {
    // Encoding & Decoding
    case base64Encoder
    case base64Decoder
    case urlEncoder
    case urlDecoder
    case htmlEntityEncoder
    case htmlEntityDecoder
    case jwtDecoder
    case unicodeEncoder
    case binaryHexEncoder
    case morseCodeEncoder
    
    // Hashing & Security
    case md5Hash
    case sha1Hash
    case sha256Hash
    case sha512Hash
    case hmacGenerator
    case pbkdf2Hash
    case uuidGenerator
    case passwordGenerator
}

class DevToolsData: ObservableObject {
    @Published var recentTools: [DevTool] = []
    @Published var searchText: String = ""
    
    let allTools: [DevTool] = [
        // ENCODING & DECODING
        DevTool(name: "Base64 Encoder", icon: "arrow.up.doc", iconColor: .blue, category: .encodingDecoding, view: .base64Encoder),
        DevTool(name: "Base64 Decoder", icon: "arrow.down.doc", iconColor: .blue, category: .encodingDecoding, view: .base64Decoder),
        DevTool(name: "URL Encoder", icon: "link.badge.plus", iconColor: .blue, category: .encodingDecoding, view: .urlEncoder),
        DevTool(name: "URL Decoder", icon: "link.circle", iconColor: .blue, category: .encodingDecoding, view: .urlDecoder),
        DevTool(name: "HTML Entity Encoder", icon: "chevron.left.forwardslash.chevron.right", iconColor: .blue, category: .encodingDecoding, view: .htmlEntityEncoder),
        DevTool(name: "HTML Entity Decoder", icon: "chevron.left.2", iconColor: .blue, category: .encodingDecoding, view: .htmlEntityDecoder),
        DevTool(name: "JWT Decoder", icon: "key.fill", iconColor: .blue, category: .encodingDecoding, view: .jwtDecoder),
        DevTool(name: "Unicode Encoder", icon: "character.cursor.ibeam", iconColor: .blue, category: .encodingDecoding, view: .unicodeEncoder),
        DevTool(name: "Binary / Hex Encoder", icon: "01.square.fill", iconColor: .blue, category: .encodingDecoding, view: .binaryHexEncoder),
        DevTool(name: "Morse Code Encoder", icon: "waveform", iconColor: .blue, category: .encodingDecoding, view: .morseCodeEncoder),
        
        // HASHING & SECURITY
        DevTool(name: "MD5 Hash", icon: "number.square.fill", iconColor: .green, category: .hashingSecurity, view: .md5Hash),
        DevTool(name: "SHA-1 Hash", icon: "lock.shield.fill", iconColor: .green, category: .hashingSecurity, view: .sha1Hash),
        DevTool(name: "SHA-256 Hash", icon: "lock.shield.fill", iconColor: .green, category: .hashingSecurity, view: .sha256Hash),
        DevTool(name: "SHA-512 Hash", icon: "lock.shield.fill", iconColor: .green, category: .hashingSecurity, view: .sha512Hash),
        DevTool(name: "HMAC Generator", icon: "key.horizontal.fill", iconColor: .green, category: .hashingSecurity, view: .hmacGenerator),
        DevTool(name: "PBKDF2 Hash", icon: "lock.rotation", iconColor: .green, category: .hashingSecurity, view: .pbkdf2Hash),
        DevTool(name: "UUID Generator", icon: "number.square", iconColor: .green, category: .hashingSecurity, view: .uuidGenerator),
        DevTool(name: "Password Generator", icon: "key.fill", iconColor: .green, category: .hashingSecurity, view: .passwordGenerator),
    ]
    
    var filteredTools: [DevTool] {
        if searchText.isEmpty {
            return allTools
        }
        return allTools.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    func addToRecent(_ tool: DevTool) {
        recentTools.removeAll { $0.id == tool.id }
        recentTools.insert(tool, at: 0)
        if recentTools.count > 10 {
            recentTools = Array(recentTools.prefix(10))
        }
    }
}
