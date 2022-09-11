//
//  MarkdownImageRenderer.swift
//  HWR ILE
//
//  Created by Sarah Klocke on 11.09.22.
//
//  Adapted from https://www.hackingwithswift.com/forums/swiftui/loading-images/3292/3299
//

import SwiftUI
import Markdown
import OSLog

struct MarkdownImageRenderer: View {
    let image: Markdown.Image
    
    @StateObject private var loader: Loader
    @State private var availableWidth: CGFloat = 0.0
    @State private var width: CGFloat? = nil
    @State private var height: CGFloat? = nil
    
    private enum LoadState {
        case loading, success, failure
    }
    
    private class Loader: ObservableObject {
        var data = Data()
        var state = LoadState.loading
        
        init(url: String?) {
            if url == nil {
                self.state = .failure
                return
            }
            
            guard let parsedUrl = URL(string: url!) else {
                self.state = .failure
                return
            }
            
            URLSession.shared.dataTask(with: parsedUrl) { data, response, error in
                if let data = data, data.count > 0 {
                    self.data = data
                    self.state = .success
                } else {
                    self.state = .failure
                }
                
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }.resume()
        }
    }
    
    init(image: Markdown.Image) {
        self.image = image
        _loader = StateObject(wrappedValue: Loader(url: image.source))
    }
    
    private func getView() -> some View {
        switch loader.state {
        case .loading:
            return AnyView(ProgressView())
        case .failure:
            return AnyView(SwiftUI.Text("Couldn't load image."))
        default:
            if let image = NSImage(data: loader.data) {
                let scaleFactor = self.availableWidth / image.size.width
                
                DispatchQueue.main.async {
                    self.height = image.size.height * scaleFactor
                }
                
                return AnyView(SwiftUI.Image(nsImage: image).scaleEffect(scaleFactor))
            } else {
                return AnyView(SwiftUI.Text("Couldn't load image."))
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: URL(string: image.source ?? "")) { image in
                image.resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width)
            } placeholder: {
                ProgressView()
            }
        }
        .frame(maxHeight: .infinity)
    }
}
