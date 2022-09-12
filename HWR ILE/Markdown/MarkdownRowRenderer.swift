//
//  MarkdownRowRenderer.swift
//  HWR ILE
//
//  Created by Sarah Klocke on 12.09.22.
//

import SwiftUI
import Markdown

struct MarkdownRowRenderer: View {
    let row: Markup
    let i: Int
    let listItemType: ListItemType?
    
    var body: some View {
        HStack() {
            let cols = parseChildren(children: row.children)
            
            ForEach(cols, id: \.key) { i, col in
                if (i > 0) {
                    Divider()
                }
                
                MarkdownRenderer(element: col, shouldPad: false, listItemType: listItemType)
            }
        }
        .padding(5)
        .background {
            Color.white.opacity(0.1 - 0.05 * Double(i % 2))
        }
    }
}
