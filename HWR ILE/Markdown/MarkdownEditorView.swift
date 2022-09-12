//
//  ContentView.swift
//  HWR ILE
//
//  Created by Sarah Klocke on 11.09.22.
//

import SwiftUI
import Markdown

struct MarkdownEditorView: View {
    @Binding var text: String
    
    @State var document = Document(parsing: "")
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                TextEditor(text: $text)
                    .frame(width: geometry.size.width * 0.5, height: geometry.size.height)
                    .font(.body.monospaced())
                    .onAppear {
                        document = Document(parsing: text)
                    }
                    .onChange(of: text) { newValue in
                        document = Document(parsing: text)
                    }
                ScrollViewReader { reader in
                    ScrollView(.vertical, showsIndicators: true) {
                        MarkdownRenderer(element: document, shouldPad: true, listItemType: nil)
                            .textSelection(.enabled)
                    }
                }
                .padding(.all, 10)
                .frame(width: geometry.size.width * 0.5 - 20, height: geometry.size.height - 20)
            }
        }
    }
}
