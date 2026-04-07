# Devbar - Developer Tools Menu Bar App

A comprehensive macOS menu bar application providing quick access to 60+ developer helper tools, inspired by Devly.

## ✨ Features

### 🔐 Encoding & Decoding (10 tools)
- **Base64 Encoder/Decoder** - Encode and decode Base64 strings
- **URL Encoder/Decoder** - Encode and decode URL strings
- **HTML Entity Encoder/Decoder** - Convert HTML special characters
- **JWT Decoder** - Decode and inspect JWT tokens (header, payload, signature)
- **Unicode Encoder** - Encode text to Unicode escape sequences
- **Binary / Hex Encoder** - Convert text to binary and hexadecimal
- **Morse Code Encoder** - Encode/decode Morse code

### 🔒 Hashing & Security (8 tools)
- **MD5 Hash** - Generate MD5 hashes
- **SHA-1 Hash** - Generate SHA-1 hashes
- **SHA-256 Hash** - Generate SHA-256 hashes
- **SHA-512 Hash** - Generate SHA-512 hashes
- **HMAC Generator** - Generate HMAC with various algorithms
- **PBKDF2 Hash** - Password-based key derivation
- **UUID Generator (v1–v8)** - Generate UUIDs with customization options
- **Password Generator** - Generate secure passwords with custom rules

### 📝 Formatters & Validators (11 tools)
- **JSON Formatter** - Format, validate, and beautify JSON
- **JSON Minifier** - Minify JSON for production
- **XML Formatter** - Format and indent XML documents
- **YAML Formatter** - Format YAML files
- **SQL Formatter** - Format SQL queries
- **GraphQL Formatter** - Format GraphQL queries
- **TOML Formatter** - Format TOML configuration files
- **CSV Formatter** - Format and clean CSV data
- **Markdown Preview** - Preview Markdown in real-time
- **HTML Formatter** - Format and indent HTML
- **CSS Formatter** - Format and beautify CSS

### 🔄 Converters (8 tools)
- **JSON ↔ YAML** - Convert between JSON and YAML
- **XML ↔ JSON** - Convert between XML and JSON
- **JSON ↔ CSV** - Convert between JSON and CSV
- **Number Base Converter** - Convert between decimal, binary, octal, hex
- **Unix Timestamp Converter** - Convert Unix timestamps to dates
- **Color Converter** - Convert between HEX and RGB
- **CSS Units Converter** - Convert between px, rem, em, pt, %
- **CSV ↔ Markdown Table** - Convert CSV to Markdown tables

### 📄 Text & String Utilities (9 tools)
- **Case Converter** - Convert text between different cases (camelCase, snake_case, etc.)
- **Line Sorter** - Sort lines alphabetically
- **Duplicate Line Remover** - Remove duplicate lines from text
- **Regex Tester** - Test regular expressions with live matching
- **Word & Char Counter** - Count words, characters, lines, and paragraphs
- **Text Diff Viewer** - Compare two text blocks
- **Lorem Ipsum Generator** - Generate placeholder text
- **Slug Generator** - Generate URL-friendly slugs
- **JSON Escape / Unescape** - Escape or unescape JSON strings

### 🌐 Network & Dev Reference (6 tools)
- **HTTP Status Lookup** - Quick reference for HTTP status codes
- **Port Lookup** - Common network ports reference
- **MIME Type Reference** - MIME types and file extensions
- **DNS Record Types** - DNS record types reference
- **Cron Expression Parser** - Parse and explain cron expressions
- **HTML Color Names** - Visual reference for HTML color names

## 🏗️ Project Structure

```
devbar/
├── devbarApp.swift                      # App entry point with menu bar setup
├── ContentView.swift                     # Main view with NavigationSplitView
├── Tool.swift                           # Tool models and data management
├── SidebarView.swift                    # Left sidebar with categories & search
├── ToolDetailView.swift                 # Detail view router for all tools
└── Views/
    ├── EncoderDecoderView.swift         # Encoding/decoding tools
    ├── HashingViews.swift               # Hashing and security tools
    ├── GeneratorViews.swift             # UUID, password, lorem ipsum generators
    ├── FormatterViews.swift             # All formatter tools
    ├── ConverterAndUtilityViews.swift   # Converter tools
    ├── TextUtilityViews.swift           # Text manipulation utilities
    └── ReferenceViews.swift             # Lookup and reference tools
```

## 🚀 How It Works

1. **Menu Bar Integration**: Lives in the macOS menu bar using `NSStatusBar` and `NSPopover`
2. **Popover Interface**: 1100x650 popover window with smooth transitions
3. **Sidebar Navigation**: Tools organized by 7 categories with search
4. **Recent Tools**: Automatically tracks your 10 most recently used tools
5. **Copy Anywhere**: Every tool includes copy-to-clipboard functionality
6. **Real-time Processing**: Most tools process input as you type

## 🎯 Usage

1. **Build and run** the app in Xcode
2. Look for the **hammer icon** (🔨) in your menu bar
3. **Click the icon** to open the tools popover
4. **Search or browse** for the tool you need
5. Use the tool - results update in real-time!

## 💡 Key Features

- ✅ **60+ Developer Tools** - All the tools you need in one place
- ✅ **Offline First** - Everything works locally, no internet required
- ✅ **Fast Search** - Quickly find tools by name or category
- ✅ **Recent Tools** - Quick access to frequently used tools
- ✅ **Copy Everything** - One-click copy for all outputs
- ✅ **Real-time Updates** - See results as you type
- ✅ **Dark Mode** - Beautiful dark theme support
- ✅ **Keyboard Friendly** - Tab through fields efficiently
- ✅ **Persistent** - Stays in menu bar for quick access

## 🔧 Requirements

- **macOS 13.0+** (Ventura or later)
- **Xcode 15.0+**
- **Swift 5.9+**

## 📦 Installation

1. Clone this repository
2. Open `devbar.xcodeproj` in Xcode
3. Build and run (⌘R)
4. The app will appear in your menu bar

## 🎨 Customization

### Adding New Tools

1. Add a new case to `ToolType` enum in `Tool.swift`
2. Add the tool definition to `allTools` array in `ToolsData`
3. Create your view (or use existing templates)
4. Add the case to the switch statement in `ToolDetailView.swift`

### Changing Categories

Edit the `ToolCategory` enum in `Tool.swift` to add or modify categories.

## 🤝 Contributing

This is a personal project, but suggestions and improvements are welcome!

## 📝 License

MIT License - Feel free to use this for your own projects!
## 🙏 Credits

Inspired by [Devly](https://devly.techfixpro.net) - a fantastic developer tools app.

---

**Made with ❤️ for developers by developers**

