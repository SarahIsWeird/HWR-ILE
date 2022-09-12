//
//  DocumentEditor.swift
//  HWR ILE
//
//  Created by Sarah Klocke on 12.09.22.
//

import SwiftUI
import OSLog

struct DocumentEditor: View {
    var documentName: String
    
    @Binding var isOpen: Bool
    
    @State var text = ""
    
    func getDocumentsFolder() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0].appendingPathComponent("HWR ILE/")
    }
    
    func getFile(folder: URL) -> URL {
        return folder.appendingPathComponent("\(documentName).md")
    }
    
    func save() {
        let ileDocuments = getDocumentsFolder()
        let file = getFile(folder: ileDocuments)
        
        if !FileManager.default.fileExists(atPath: ileDocuments.path) {
            try! FileManager.default.createDirectory(at: ileDocuments, withIntermediateDirectories: true)
        }
        
        try! text.write(to: file, atomically: true, encoding: .utf8)
    }
    
    func dispatchTextUpdate(text: String) {
        DispatchQueue.main.async {
            self.text = text
        }
    }
    
    func load() {
        let ileDocuments = getDocumentsFolder()
        
        if !FileManager.default.fileExists(atPath: ileDocuments.path) {
            dispatchTextUpdate(text: "")
            return
        }
        
        let file = getFile(folder: ileDocuments)
        
        if !FileManager.default.fileExists(atPath: file.path) {
            dispatchTextUpdate(text: "")
            return
        }
        
        let fileContents = try! String(contentsOf: file)
        
        dispatchTextUpdate(text: fileContents)
    }
    
    var body: some View {
        NavigationLink(documentName, isActive: $isOpen) {
            MarkdownEditorView(text: $text)
                .onDisappear {
                    save()
                }
        }
        .onChange(of: isOpen) { documentWasOpened in
            if documentWasOpened {
                load()
            } else {
                save()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
            save()
        }
    }
}
