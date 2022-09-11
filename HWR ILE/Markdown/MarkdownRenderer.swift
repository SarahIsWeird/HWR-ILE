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

struct MarkdownRenderer: View {
    let element: Markup
    
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
                    .padding(.bottom, 12)
            case let paragraph as Paragraph:
                let paragraphElements = parseParagraph(paragraph: paragraph)
                
                ForEach(paragraphElements, id: \.key) { _, element in
                    MarkdownRenderer(element: element)
                }
                .padding(.bottom, 12)
            case let text as Markdown.Text:
                SwiftUI.Text(LocalizedStringKey(text.plainText))
                    .frame(maxWidth: .infinity, alignment: .leading)
            case let image as Markdown.Image:
                GeometryReader { geometry in
                    AsyncImage(url: URL(string: image.source ?? "")) { image in
                        image.resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width)
                    } placeholder: {
                        ProgressView()
                    }
                }
            default:
                let children = parseChildren(children: element.children)
                
                ForEach(children, id: \.key) { _, element in
                    MarkdownRenderer(element: element)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct MarkdownRenderer_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownRenderer(element: Markdown.Text(""))
    }
}
