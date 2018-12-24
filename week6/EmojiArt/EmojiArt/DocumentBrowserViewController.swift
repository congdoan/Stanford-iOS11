//
//  DocumentBrowserViewController.swift
//  EmojiArt
//
//  Created by Cong Doan on 12/24/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        allowsPickingMultipleItems = false
        templateURL = try? FileManager.default.url(for: .applicationSupportDirectory,
                                                   in: .userDomainMask,
                                                   appropriateFor: nil,
                                                   create: true).appendingPathComponent("Untitled.json",
                                                                                        isDirectory: false)
        if let templatePath = templateURL?.path {
            allowsDocumentCreation = FileManager.default.createFile(atPath: templatePath, contents: Data())
        } else {
            allowsDocumentCreation = false
        }
    }
    
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    private var templateURL: URL?
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController,
                         didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        importHandler(templateURL, .copy)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
        guard let error = error else { return }
        let alert = UIAlertController(title: "Document Import Error",
                                      message: "Faile to import the document at '\(documentURL)': \(error)",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default) { (action) in
            alert.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let documentVC = storyBoard.instantiateViewController(withIdentifier: "DocumentMVC")
        let emojiArtViewController = documentVC.contents as! EmojiArtViewController
        emojiArtViewController.document = EmojiArtDocument(fileURL: documentURL)
        present(documentVC, animated: true, completion: nil)
    }
    
}

