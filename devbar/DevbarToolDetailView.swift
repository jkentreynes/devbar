//
//  DevbarToolDetailView.swift
//  devbar
//
//  Created by John Kent Reynes on 4/5/26.
//

import SwiftUI

struct DevbarToolDetailView: View {
    let tool: DevTool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: tool.icon)
                    .foregroundStyle(tool.iconColor)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(tool.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text(tool.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
            
            // Tool content
            Group {
                switch tool.view {
                case .cronExpressionParser:
                    CronExpressionParserView()
                case .base64Encoder:
                    Base64EncoderView()
                case .base64Decoder:
                    Base64DecoderView()
                case .urlEncoder:
                    URLEncoderView()
                case .urlDecoder:
                    URLDecoderView()
                case .htmlEntityEncoder:
                    HTMLEntityEncoderView()
                case .htmlEntityDecoder:
                    HTMLEntityDecoderView()
                case .jwtDecoder:
                    JWTDecoderView()
                case .unicodeEncoder:
                    UnicodeEncoderView()
                case .binaryHexEncoder:
                    BinaryHexEncoderView()
                case .morseCodeEncoder:
                    MorseCodeEncoderView()
                case .md5Hash:
                    MD5HashView()
                case .sha1Hash:
                    SHA1HashView()
                case .sha256Hash:
                    SHA256HashView()
                case .sha512Hash:
                    SHA512HashView()
                case .hmacGenerator:
                    HMACGeneratorView()
                case .pbkdf2Hash:
                    PBKDF2HashView()
                case .uuidGenerator:
                    UUIDGeneratorView()
                case .passwordGenerator:
                    PasswordGeneratorView()
                case .jsonFormatter:
                    JSONFormatterView()
                case .jsonMinifier:
                    JSONMinifierView()
                case .xmlFormatter:
                    XMLFormatterView()
                case .yamlFormatter:
                    YAMLFormatterView()
                case .sqlFormatter:
                    SQLFormatterView()
                case .graphqlFormatter:
                    GraphQLFormatterView()
                case .tomlFormatter:
                    TOMLFormatterView()
                case .csvFormatter:
                    CSVFormatterView()
                case .markdownPreview:
                    MarkdownPreviewView()
                case .htmlFormatter:
                    HTMLFormatterView()
                case .cssFormatter:
                    CSSFormatterView()
                case .jsonYamlConverter:
                    JSONYAMLConverterView()
                case .xmlJsonConverter:
                    XMLJSONConverterView()
                case .jsonCsvConverter:
                    JSONCSVConverterView()
                case .numberBaseConverter:
                    NumberBaseConverterView()
                case .unixTimestampConverter:
                    UnixTimestampConverterView()
                case .colorConverter:
                    ColorConverterView()
                case .cssUnitsConverter:
                    CSSUnitsConverterView()
                case .csvMarkdownConverter:
                    CSVMarkdownConverterView()
                case .caseConverter:
                    CaseConverterView()
                case .lineSorter:
                    LineSorterView()
                case .duplicateLineRemover:
                    DuplicateLineRemoverView()
                case .regexTester:
                    RegexTesterView()
                case .wordCharCounter:
                    WordCharCounterView()
                case .textDiffViewer:
                    TextDiffView()
                case .loremIpsumGenerator:
                    LoremIpsumGeneratorView()
                case .slugGenerator:
                    SlugGeneratorView()
                case .jsonEscapeUnescape:
                    JSONEscapeUnescapeView()
                }
            }
        }
    }
}
