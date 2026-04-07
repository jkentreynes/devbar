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
    case formattersValidators = "Formatters & Validators"
    case converters = "Converters"
    case textStringUtilities = "Text & String Utilities"
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
    case cronExpressionParser
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
    
    // Formatters & Validators
    case jsonFormatter
    case jsonMinifier
    case xmlFormatter
    case yamlFormatter
    case sqlFormatter
    case graphqlFormatter
    case tomlFormatter
    case csvFormatter
    case markdownPreview
    case htmlFormatter
    case cssFormatter

    // Text & String Utilities
    case caseConverter
    case lineSorter
    case duplicateLineRemover
    case regexTester
    case wordCharCounter
    case textDiffViewer
    case loremIpsumGenerator
    case slugGenerator
    case jsonEscapeUnescape

    // Converters
    case jsonYamlConverter
    case xmlJsonConverter
    case jsonCsvConverter
    case numberBaseConverter
    case unixTimestampConverter
    case colorConverter
    case cssUnitsConverter
    case csvMarkdownConverter
}

class DevToolsData: ObservableObject {
    @Published var recentTools: [DevTool] = []
    @Published var searchText: String = ""
    
    let allTools: [DevTool] = [
        // ENCODING & DECODING
        DevTool(name: "Cron Expression Parser", icon: "clock.badge.checkmark", iconColor: .blue, category: .encodingDecoding, view: .cronExpressionParser),
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
        
        // TEXT & STRING UTILITIES
        DevTool(name: "Case Converter",          icon: "textformat",                   iconColor: .teal, category: .textStringUtilities, view: .caseConverter),
        DevTool(name: "Line Sorter",             icon: "arrow.up.arrow.down",          iconColor: .teal, category: .textStringUtilities, view: .lineSorter),
        DevTool(name: "Duplicate Line Remover",  icon: "line.3.horizontal.decrease",   iconColor: .teal, category: .textStringUtilities, view: .duplicateLineRemover),
        DevTool(name: "Regex Tester",            icon: "magnifyingglass",              iconColor: .teal, category: .textStringUtilities, view: .regexTester),
        DevTool(name: "Word & Char Counter",     icon: "character.cursor.ibeam",       iconColor: .teal, category: .textStringUtilities, view: .wordCharCounter),
        DevTool(name: "Text Diff Viewer",        icon: "doc.text.magnifyingglass",     iconColor: .teal, category: .textStringUtilities, view: .textDiffViewer),
        DevTool(name: "Lorem Ipsum Generator",   icon: "text.alignleft",               iconColor: .teal, category: .textStringUtilities, view: .loremIpsumGenerator),
        DevTool(name: "Slug Generator",          icon: "link",                         iconColor: .teal, category: .textStringUtilities, view: .slugGenerator),
        DevTool(name: "JSON Escape / Unescape",  icon: "curlybraces",                  iconColor: .teal, category: .textStringUtilities, view: .jsonEscapeUnescape),

        // CONVERTERS
        DevTool(name: "JSON ↔ YAML", icon: "arrow.left.arrow.right", iconColor: .purple, category: .converters, view: .jsonYamlConverter),
        DevTool(name: "XML ↔ JSON", icon: "chevron.left.forwardslash.chevron.right", iconColor: .purple, category: .converters, view: .xmlJsonConverter),
        DevTool(name: "JSON ↔ CSV", icon: "tablecells", iconColor: .purple, category: .converters, view: .jsonCsvConverter),
        DevTool(name: "Number Base Converter", icon: "number.circle.fill", iconColor: .purple, category: .converters, view: .numberBaseConverter),
        DevTool(name: "Unix Timestamp Converter", icon: "clock", iconColor: .purple, category: .converters, view: .unixTimestampConverter),
        DevTool(name: "Color Converter", icon: "paintpalette", iconColor: .purple, category: .converters, view: .colorConverter),
        DevTool(name: "CSS Units Converter", icon: "ruler", iconColor: .purple, category: .converters, view: .cssUnitsConverter),
        DevTool(name: "CSV ↔ Markdown Table", icon: "arrow.left.arrow.right", iconColor: .purple, category: .converters, view: .csvMarkdownConverter),

        // FORMATTERS & VALIDATORS
        DevTool(name: "JSON Formatter", icon: "curlybraces", iconColor: .orange, category: .formattersValidators, view: .jsonFormatter),
        DevTool(name: "JSON Minifier", icon: "arrow.down.right.and.arrow.up.left", iconColor: .orange, category: .formattersValidators, view: .jsonMinifier),
        DevTool(name: "XML Formatter", icon: "chevron.left.forwardslash.chevron.right", iconColor: .orange, category: .formattersValidators, view: .xmlFormatter),
        DevTool(name: "YAML Formatter", icon: "doc.text", iconColor: .orange, category: .formattersValidators, view: .yamlFormatter),
        DevTool(name: "SQL Formatter", icon: "cylinder", iconColor: .orange, category: .formattersValidators, view: .sqlFormatter),
        DevTool(name: "GraphQL Formatter", icon: "arrow.triangle.branch", iconColor: .orange, category: .formattersValidators, view: .graphqlFormatter),
        DevTool(name: "TOML Formatter", icon: "doc.plaintext", iconColor: .orange, category: .formattersValidators, view: .tomlFormatter),
        DevTool(name: "CSV Formatter", icon: "tablecells", iconColor: .orange, category: .formattersValidators, view: .csvFormatter),
        DevTool(name: "Markdown Preview", icon: "doc.richtext", iconColor: .orange, category: .formattersValidators, view: .markdownPreview),
        DevTool(name: "HTML Formatter", icon: "globe", iconColor: .orange, category: .formattersValidators, view: .htmlFormatter),
        DevTool(name: "CSS Formatter", icon: "paintbrush", iconColor: .orange, category: .formattersValidators, view: .cssFormatter),
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
