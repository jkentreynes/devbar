//
//  ContentView.swift
//  devbar
//
//  Created by John Kent Reynes on 4/5/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var toolsData = DevToolsData()
    @State private var selectedTool: DevTool?
    
    var body: some View {
        NavigationSplitView {
            DevbarSidebarView(toolsData: toolsData, selectedTool: $selectedTool)
        } detail: {
            if let tool = selectedTool {
                DevbarToolDetailView(tool: tool)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "hammer.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    Text("Select a tool to get started")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("\(toolsData.allTools.count) tools available")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            // Select Base64 Encoder by default
            if let firstTool = toolsData.allTools.first {
                selectedTool = firstTool
            }
        }
    }
}

#Preview {
    ContentView()
}
