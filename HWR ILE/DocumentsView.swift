//
//  DocumentsView.swift
//  HWR ILE
//
//  Created by Sarah Klocke on 12.09.22.
//

import SwiftUI
import OSLog

let course = ["Agile Methoden", "Artificial Intelligence", "Graphics", "Multimedia Systems", "Operating Systems", "Projektmanagement"]

struct OpenTab: Equatable {
    var key: String
    var value: Bool

    init(_ key: String) {
        self.key = key
        self.value = false
    }

    var description: String {
        return "[\(key): \(value)]"
    }
}

struct DocumentsView: View {
    @State private var isOpen: [OpenTab] = course.map(OpenTab.init)
    
    var body: some View {
        NavigationView {
            List($isOpen, id: \.key) { $tuple in
                DocumentEditor(documentName: tuple.key, isOpen: $tuple.value)
                    .navigationTitle(tuple.key)
            }
        }
        .navigationTitle("Documents")
    }
}

struct DocumentsPresentationNavigationView: View {
    @State private var isOpen: [OpenTab] = course.map(OpenTab.init)
    
    var body: some View {
        NavigationView {
            List($isOpen, id: \.key) { $tuple in
                DocumentPresentationView(documentName: tuple.key, isOpen: $tuple.value)
                    .navigationTitle(tuple.key)
            }
        }
        .navigationTitle("Documents")
    }
}
