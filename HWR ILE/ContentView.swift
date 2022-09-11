//
//  ContentView.swift
//  HWR ILE
//
//  Created by Sarah Klocke on 11.09.22.
//

import SwiftUI
import Markdown

struct ContentView: View {
    @State var text = ""
    @State var document = Document(parsing: "")
    @State var debug = ""
    
    var body: some View {
        HStack {
            TextEditor(text: $text)
                .frame(width: 400, height: 600)
                .font(.body.monospaced())
                .onChange(of: text) { newValue in
                    document = Document(parsing: text)
                    debug = document.debugDescription()
                }
            ScrollViewReader { reader in
                ScrollView(.vertical, showsIndicators: true) {
                    MarkdownRenderer(element: document)
                        .frame(maxWidth: .infinity)
                        .id("#root")
                }
            }
            .frame(width: 400, height: 600)
            TextEditor(text: $debug)
                .frame(width: 400, height: 600)
        }
        .onAppear {
            let path = Bundle.main.path(forResource: "Test", ofType: "md")!
            let url = URL(fileURLWithPath: path)
            
            text = try! String(contentsOf: url)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
