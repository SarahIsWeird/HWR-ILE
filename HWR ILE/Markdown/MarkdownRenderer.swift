//
//  MarkdownRenderer.swift
//  HWR ILE
//
//  Created by Sarah Klocke on 11.09.22.
//

import SwiftUI
import Markdown
import WebKit
import OSLog

func parseParagraph(paragraph: Paragraph) -> [(key: Int, value: Markup)] {
    var elementList: [Int: Markup] = [:]
    var i = 0
    
    for child in paragraph.children {
        switch child {
        case let text as Markdown.Text:
            if elementList[i - 1] is Markdown.Text {
                let last = elementList.removeValue(forKey: i - 1) as! Markdown.Text
                elementList[i - 1] = Markdown.Text(last.plainText + text.plainText)
                
                continue
            } else {
                elementList[i] = text
            }
        case let link as Markdown.Link:
            let linkString = "[\(link.plainText)](\(link.destination ?? ""))"
            
            if elementList[i - 1] is Markdown.Text {
                let last = elementList.removeValue(forKey: i - 1) as! Markdown.Text
                elementList[i - 1] = Markdown.Text(last.plainText + linkString)
                
                continue
            } else {
                elementList[i] = Markdown.Text(linkString)
            }
        case let inlineCode as InlineCode:
            let codeString = "`\(inlineCode.plainText)`"
            
            if elementList[i - 1] is Markdown.Text {
                let last = elementList.removeValue(forKey: i - 1) as! Markdown.Text
                elementList[i - 1] = Markdown.Text(last.plainText + codeString)
                
                continue
            } else {
                elementList[i] = Markdown.Text(codeString)
            }
        case is SoftBreak:
            if elementList[i - 1] is Markdown.Text {
                let last = elementList.removeValue(forKey: i - 1) as! Markdown.Text
                elementList[i - 1] = Markdown.Text(last.plainText + " ")
                
                continue
            }
        case let strong as Strong:
            let codeString = "**\(strong.plainText)**"
            
            if elementList[i - 1] is Markdown.Text {
                let last = elementList.removeValue(forKey: i - 1) as! Markdown.Text
                elementList[i - 1] = Markdown.Text(last.plainText + codeString)
                
                continue
            } else {
                elementList[i] = Markdown.Text(codeString)
            }
        case let emphasis as Emphasis:
            let codeString = "*\(emphasis.plainText)*"
            
            if elementList[i - 1] is Markdown.Text {
                let last = elementList.removeValue(forKey: i - 1) as! Markdown.Text
                elementList[i - 1] = Markdown.Text(last.plainText + codeString)
                
                continue
            } else {
                elementList[i] = Markdown.Text(codeString)
            }
        case let strikethrough as Markdown.Strikethrough:
            let codeString = "~\(strikethrough.plainText)~"
            
            if elementList[i - 1] is Markdown.Text {
                let last = elementList.removeValue(forKey: i - 1) as! Markdown.Text
                elementList[i - 1] = Markdown.Text(last.plainText + codeString)
                
                continue
            } else {
                elementList[i] = Markdown.Text(codeString)
            }
        default:
            elementList[i] = child
        }
        
        i += 1
    }
    
    return elementList.sorted(by: { a, b in a.key < b.key })
}

func parseChildren(children: MarkupChildren) -> [(key: Int, value: Markup)] {
    var elementList: [Int: Markup] = [:]
    var i = 0
    
    for child in children {
        elementList[i] = child
        i += 1
    }
    
    return elementList.sorted(by: { a, b in a.key < b.key })
}

struct MarkdownRenderer: View {
    let element: Markup
    let shouldPad: Bool
    let listItemType: ListItemType?
    let index: String?
    
    init(element: Markup, shouldPad: Bool, listItemType: ListItemType?, index: String? = nil) {
        self.element = element
        self.shouldPad = shouldPad
        self.listItemType = listItemType
        self.index = index
    }
    
    func getFontSizeForHeading(heading: Heading) -> CGFloat {
        return CGFloat(40.0 - 4.0 * Float(heading.level))
    }
    
    func getFontForHeading(heading: Heading) -> Font {
        return .system(size: CGFloat(getFontSizeForHeading(heading: heading)))
    }
    
    func parseHeadingText(heading: Heading) -> LocalizedStringKey {
        var headingText = ""
        
        for child in heading.children {
            switch child {
            case let text as Markdown.Text:
                headingText += text.plainText
            case let link as Markdown.Link:
                headingText += "[\(link.plainText)](\(link.destination ?? "")"
            case let inlineCode as InlineCode:
                headingText += "`\(inlineCode.plainText)`"
            default:
                continue
            }
        }
        
        return LocalizedStringKey(headingText)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            switch element {
            case let heading as Heading:
                let headingText = parseHeadingText(heading: heading)
                
                SwiftUI.Text(headingText)
                    .font(getFontForHeading(heading: heading))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, shouldPad ? 12 : 0)
            case let paragraph as Paragraph:
                let paragraphElements = parseParagraph(paragraph: paragraph)
                
                ForEach(paragraphElements, id: \.key) { _, element in
                    MarkdownRenderer(element: element, shouldPad: shouldPad, listItemType: listItemType, index: index)
                }
                .padding(.bottom, shouldPad ? 12 : 0)
            case let text as Markdown.Text:
                SwiftUI.Text(LocalizedStringKey(text.plainText))
                    .frame(maxWidth: .infinity, alignment: .leading)
            case let image as Markdown.Image:
                MarkdownImageRenderer(image: image)
            case let codeBlock as CodeBlock:
                SwiftUI.Text(LocalizedStringKey("```\(codeBlock.code.trimmingCharacters(in: .newlines))```"))
                    .padding(.bottom, shouldPad ? 12 : 0)
                    .frame(maxWidth: .infinity, alignment: .leading)
            case let list as UnorderedList:
                let children = parseChildren(children: list.children)
                
                ForEach(children, id: \.key) { _, element in
                    MarkdownRenderer(element: element, shouldPad: shouldPad, listItemType: .unordered)
                }
            case let list as OrderedList:
                let children = parseChildren(children: list.children)
                
                ForEach(children, id: \.key) { i, element in
                    MarkdownRenderer(element: element, shouldPad: shouldPad, listItemType: .ordered, index: (index ?? "") + "\(i + 1).")
                }
            case let listItem as ListItem:
                MarkdownListItemRenderer(listItem: listItem, shouldPad: shouldPad, type: listItemType ?? .unordered, index: index)
            case is ThematicBreak:
                Divider()
            case let blockQuote as BlockQuote:
                let children = parseChildren(children: blockQuote.children)
                
                ForEach(children, id: \.key) { i, element in
                    HStack {
                        Divider()
                        MarkdownRenderer(element: element, shouldPad: false, listItemType: listItemType, index: index)
                    }
                    .padding(.bottom, blockQuote.child(at: i + 1) != nil || blockQuote.parent is BlockQuote ? 0 : 12)
                }
            case let mdTable as Markdown.Table:
                let head = mdTable.child(at: 0)!
                let body = mdTable.child(at: 1)!
                
                VStack(alignment: .center, spacing: .zero) {
                    MarkdownRowRenderer(row: head, i: 1, listItemType: listItemType)
                        .font(.title3)

                    let rows = parseChildren(children: body.children)

                    ForEach(rows, id: \.key) { i, row in
                        MarkdownRowRenderer(row: row, i: i, listItemType: listItemType)
                    }
                }
                .padding(.bottom, shouldPad ? 12 : 0)
            default:
                let children = parseChildren(children: element.children)
                
                ForEach(children, id: \.key) { _, element in
                    MarkdownRenderer(element: element, shouldPad: shouldPad, listItemType: listItemType, index: index)
                }
            }
        }
    }
}

struct MarkdownRenderer_Previews: PreviewProvider {
    static var previews: some View {
        let element = UnorderedList(ListItem(Paragraph(Text("Some text")), BlockQuote(Paragraph(Text("And a block quote")))))
        
        MarkdownRenderer(element: element, shouldPad: false, listItemType: nil)
            .frame(maxWidth: 200, maxHeight: 50)
    }
}
