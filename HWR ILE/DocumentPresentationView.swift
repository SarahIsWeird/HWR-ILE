//
//  DocumentPresentationView.swift
//  HWR ILE
//
//  Created by Sarah Klocke on 12.09.22.
//

import SwiftUI
import Markdown

struct DocumentPresentationView: View {
    var documentName: String
    
    @Binding var isOpen: Bool
    
    @State var text = ""
    @State var document = Document(parsing: "")
    
    var body: some View {
        NavigationLink(documentName, isActive: $isOpen) {
            GeometryReader { geometry in
                HStack {
                    ScrollViewReader { reader in
                        ScrollView(.vertical, showsIndicators: true) {
                            MarkdownRenderer(element: document, shouldPad: true, listItemType: nil)
                                .textSelection(.enabled)
                        }
                    }
                    .onAppear {
                        document = Document(parsing: text)
                    }
                    .onChange(of: text) { newValue in
                        document = Document(parsing: text)
                    }
                    .padding(.all, 10)
                    .frame(width: geometry.size.width - 20, height: geometry.size.height - 20)
                }
            }
        }
        .onChange(of: isOpen) { opened in
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let ileDocuments = paths[0].appendingPathComponent("HWR ILE/")
            let file = ileDocuments.appendingPathComponent("\(documentName).md")
            
            if opened == true {
                if !FileManager.default.fileExists(atPath: file.path) {
                    DispatchQueue.main.async {
                        text = ""
                    }
                } else {
                    DispatchQueue.main.async {
                        text = try! String(contentsOf: file)
                    }
                }
            }
        }
    }
}
