//
//  ContentView.swift
//  HWR ILE
//
//  Created by Sarah Klocke on 12.09.22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    DocumentsView()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                
                NavigationLink {
                    DocumentsPresentationNavigationView()
                } label: {
                    Label("Review", systemImage: "rectangle.3.group.bubble.left.fill")
                }
            }
        }
        .navigationTitle("Apps")
        .navigationViewStyle(.columns)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
