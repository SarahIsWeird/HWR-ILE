//
//  MarkdownListItemRenderer.swift
//  HWR ILE
//
//  Created by Sarah Klocke on 12.09.22.
//

import SwiftUI
import Markdown

enum ListItemType {
    case unordered, ordered
}

struct MarkdownListItemRenderer: View {
    let listItem: ListItem
    let shouldPad: Bool
    let type: ListItemType
    let index: String?
    
    var body: some View {
        let children = parseChildren(children: listItem.children)
        
        ForEach(children, id: \.key) { _, element in
            switch element {
            case let paragraph as Paragraph:
                HStack(alignment: .center) {
                    switch type {
                    case .unordered:
                        SwiftUI.Text("•")
                    case .ordered:
                        SwiftUI.Text(index!)
                    }
                    
                    let paragraphElements = parseParagraph(paragraph: paragraph)
                    VStack {
                        ForEach(paragraphElements, id: \.key) { _, element in
                            MarkdownRenderer(element: element, shouldPad: shouldPad, listItemType: type)
                        }
                    }
                }
                .padding(.bottom, 6)
            case let list as UnorderedList:
                MarkdownRenderer(element: list, shouldPad: shouldPad, listItemType: type)
                    .padding(.leading, shouldPad ? 12 : 0)
            case let list as OrderedList:
                MarkdownRenderer(element: list, shouldPad: shouldPad, listItemType: type)
                    .padding(.leading, shouldPad ? 12 : 0)
            default:
                MarkdownRenderer(element: element, shouldPad: shouldPad, listItemType: type)
            }
        }
    }
}

struct MarkdownListItemRenderer_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownListItemRenderer(listItem: ListItem([]), shouldPad: true, type: .unordered, index: "")
    }
}
