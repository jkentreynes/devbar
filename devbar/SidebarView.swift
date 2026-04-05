//
//  SidebarView.swift
//  devbar
//
//  Created by John Kent Reynes on 4/5/26.
//

import SwiftUI

struct DevbarSidebarView: View {
    @ObservedObject var toolsData: DevToolsData
    @Binding var selectedTool: DevTool?
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search tools...", text: $toolsData.searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(6)
            .padding()
            
            // Tool list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    // Recent section
                    if !toolsData.recentTools.isEmpty && toolsData.searchText.isEmpty {
                        DevbarSidebarSectionView(title: "Recent") {
                            ForEach(toolsData.recentTools) { tool in
                                DevbarToolRowView(tool: tool, isSelected: selectedTool?.id == tool.id)
                                    .onTapGesture {
                                        selectedTool = tool
                                    }
                            }
                        }
                    }
                    
                    // Category sections
                    if toolsData.searchText.isEmpty {
                        ForEach(ToolCategory.allCases.filter { $0 != .recent }, id: \.self) { category in
                            let categoryTools = toolsData.allTools.filter { $0.category == category }
                            if !categoryTools.isEmpty {
                                DevbarSidebarSectionView(title: category.rawValue) {
                                    ForEach(categoryTools) { tool in
                                        DevbarToolRowView(tool: tool, isSelected: selectedTool?.id == tool.id)
                                            .onTapGesture {
                                                selectedTool = tool
                                                toolsData.addToRecent(tool)
                                            }
                                    }
                                }
                            }
                        }
                    } else {
                        // Search results
                        ForEach(toolsData.filteredTools) { tool in
                            DevbarToolRowView(tool: tool, isSelected: selectedTool?.id == tool.id)
                                .onTapGesture {
                                    selectedTool = tool
                                    toolsData.addToRecent(tool)
                                }
                        }
                        .padding(.horizontal, 8)
                    }
                }
            }
        }
        .frame(width: 280)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
    }
}

struct DevbarSidebarSectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .fontWeight(.semibold)
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 4)
            
            content
        }
    }
}

struct DevbarToolRowView: View {
    let tool: DevTool
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: tool.icon)
                .foregroundStyle(tool.iconColor)
                .frame(width: 18)
                .font(.system(size: 14))
            
            Text(tool.name)
                .font(.system(size: 12))
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
        .cornerRadius(6)
        .padding(.horizontal, 8)
        .contentShape(Rectangle())
    }
}

